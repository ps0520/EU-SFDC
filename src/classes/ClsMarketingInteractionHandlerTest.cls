@isTest
private class ClsMarketingInteractionHandlerTest {
    
    @isTest 
    private static void testClsMarketingInteractionHandler(){
		//Test the CA Marketing Interactions
		List<Account> accts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'CA Consumer', 'Canada');
        Test.startTest();
        ClsAccountAddressTriggerStaticClass.invokeMILogicOnlyOnce = true;
        //Test the interaction for communication tyep - CA - Customer Onboarding
		accts[0].Number_of_Orders__c = 1;
		//Test the interaction for communication tyep - CA - Reorder Reminder - G6 Starter Kit
		accts[0].G6_Starter_Kit_Ship_Date__c = System.Today();
		//Update Accounts
		//Test the interaction for communication tyep - CA - Product Onboarding - G6
		accts[1].G6_Transmitter_Ship_Date__c = System.Today();
		update accts;
		
		List<Marketing_Interaction__c> insertedMIs = [SELECT Id, Communication_Type__c FROM Marketing_Interaction__c WHERE Account__c IN : accts];
		System.assertEquals(insertedMIs.size(), 1);
		
		//Try to record a new order for an accountId__c
		accts[0].Number_of_Orders__c = 2;
		ClsAccountAddressTriggerStaticClass.invokeMILogicOnlyOnce = true;
		//Update Account, which will set the conversion flag
		update accts[0];
		List<Account> upatedAccount = [SELECT Id, G6_Starter_Kit_Conversion__c FROM Account WHERE Id = : accts[0].Id];
		System.assertEquals(upatedAccount[0].G6_Starter_Kit_Conversion__c, true);
		Test.stopTest();
	}
    
    @isTest 
    private static void testUKMIs(){
        
        List<Account> accountList;
        Set<Id> accountIds = new Set<Id>();
        
        Id gbConsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GB_Consumer').getRecordTypeId();
		Id ieConsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IE_Consumer').getRecordTypeId();
        
        Test.startTest();
        
        Account a = new Account();
        a.FirstName = 'TestGB';
        a.LastName = 'Account';
        a.RecordTypeId = gbConsumerId;

        Account b = new Account();
        b.FirstName = 'TestIE';
        b.LastName = 'Account';
        b.RecordTypeId = ieConsumerId;
        
       	accountList = new List<Account>{a,b};
        insert accountList;
        
        for (Account acc : accountList){
            accountIds.add(acc.Id);
        }
        
        accountList = [SELECT Id, G6_Starter_Kit_Ship_Date__c FROM Account WHERE Id = :accountIds];

        ClsAccountAddressTriggerStaticClass.invokeMILogicOnlyOnce = true;       
        accountList[0].G6_Starter_Kit_Ship_Date__c = Date.today();
        accountList[1].G6_Starter_Kit_Ship_Date__c = Date.today();
        
        accountList = new List<Account>{accountList[0],accountList[1]};
        update accountList;        
        
        //This should not create a new Marketing Interaction
        ClsAccountAddressTriggerStaticClass.invokeMILogicOnlyOnce = true;
        accountList[0].G6_Starter_Kit_Ship_Date__c = Date.today().addDays(1);        
        update accountList[0];
                 
        List<Marketing_Interaction__c> miList = [SELECT Id, Account__c, Communication_Type__c, Country__c 
                                                 FROM Marketing_Interaction__c];
        Test.stopTest();
        
    	System.assertEquals(2, miList.size());
        System.assert((miList[0].Country__c == 'United Kingdom') && (miList[0].Account__c == accountList[0].Id)
                      && (miList[0].Communication_Type__c == 'UKIE - Subscription Upsell - G6'));        
        System.assert((miList[1].Country__c == 'Ireland') && (miList[1].Account__c == accountList[1].Id) 
                      && (miList[1].Communication_Type__c == 'UKIE - Subscription Upsell - G6'));
    }
    
    
}