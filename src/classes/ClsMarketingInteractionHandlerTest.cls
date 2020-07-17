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
}