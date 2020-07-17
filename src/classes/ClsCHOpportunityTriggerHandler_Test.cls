@isTest
public class ClsCHOpportunityTriggerHandler_Test {
	
    @isTest 
    static void InsertTestDataCH(){        
        
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                                   where sObjectType='Account' and isActive=true];
        //Create a map between the Record Type Name and Id 
        Map<String,String> accountRecordTypes = new Map<String,String>();
        for(RecordType rt: rtypes)
            accountRecordTypes.put(rt.Name,rt.Id);
        List<Account> accts = new List<Account>();
         Map<Id, Opportunity> newTriggerOpportunities = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oldTriggerOpportunities = new Map<Id, Opportunity>();
        String recordTypeIdCH = accountRecordTypes.get('CH Consumer');
        Account CHacc = new Account();
        CHacc.CurrencyIsoCode = 'CHF';
        CHacc.RecordTypeId = recordTypeIdCH;
        CHacc.FirstName='TestConsumerFirstName';
        CHacc.LastName='TestConsumerLastName';
        CHacc.BillingStreet = 'Grüner Weg';
        CHacc.BillingCity = 'Friedberg';
        CHacc.BillingPostalCode = '1214';
        CHacc.BillingCountryCode = 'CH';
        //CHacc.PersonEmail = 'Tesdt@gmail.com';
        CHacc.PersonHasOptedOutOfEmail = false;
        insert CHacc; 
        
        String recordTypeIdMed = accountRecordTypes.get('CH Medical Facility');
        Account CHaccMed = new Account();
        CHaccMed.CurrencyIsoCode = 'CHF';
        CHaccMed.RecordTypeId = recordTypeIdMed;
        CHaccMed.name = 'Med';
        CHaccMed.Phone = '1234567891' ;
        CHaccMed.BillingStreet = 'Grüner Weg';
        CHaccMed.BillingCity = 'Friedberg';
        CHaccMed.BillingPostalCode = '1244';
        CHaccMed.BillingCountryCode = 'CH';
        insert CHaccMed; 
        
        String recordTypeIdPres = accountRecordTypes.get('CH Prescriber');
        Account CHaccPres = new Account();
        CHaccPres.CurrencyIsoCode = 'CHF';
        CHaccPres.RecordTypeId = recordTypeIdPres;
        CHaccPres.FirstName='TestPresFirstName';
        CHaccPres.LastName='TestPresrLastName';
        CHaccPres.BillingStreet = 'Grüner Weg';
        CHaccPres.BillingCity = 'Friedberg';
        CHaccPres.BillingPostalCode = '1224';
        CHaccPres.BillingCountryCode = 'CH';
        CHaccPres.PersonEmail = 'TesdtT@gmail.com';
        CHaccPres.PersonHasOptedOutOfEmail = false;
        CHaccPres.Medical_Facility__c = CHaccMed.id ;
        insert CHaccPres;     
        CHacc.Medical_Facility__c = CHaccMed.id;
        CHacc.Prescriber__c = CHaccPres.id ;
        update CHacc ;
 
		//Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCPB(new List <String>{'CH_Pricebook'}, 'CHF');
        String customPricebookId = customPricebookMap.get('CH_Pricebook');
        
        //Create Products
        Map<String, Id> products = ClsTestDataFactory.createProducts(new List<String> {'STK-GF-013', 'STT-GF-004', 'DEX-SHIP-01'});
        
        //Create Pricebook EntryPair
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(String productName : products.keySet())
            productIdToPriceMap.put(products.get(productName), 125.00);

        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntriesCH(productIdToPriceMap, customPricebookId);

        Id oppRecTypeCH = [Select Id from RecordType Where isActive = true AND DeveloperName = 'CH_Opportunity'].id; 
        Opportunity newOppCH = new Opportunity();
        newOppCH.RecordTypeId = oppRecTypeCH;
        newOppCH.Name = 'New Opportunity For Testing';
        newOppCH.CurrencyIsoCode = 'CHF';
        newOppCH.AccountId = CHacc.Id;
        newOppCH.Type = 'Subscription';
        
        newOppCH.Contact_Letter_Sent__c = true;
        newOppCH.Contact_Doc_Received__c = true;
        newOppCH.Insurance_Doc_Received__c = true;
        newOppCH.Hard_Copy_Out__c = true;
        newOppCH.Hard_Copy_In__c = true;
        newOppCH.Training_Letter_Sent__c = true;
        newOppCH.Training_Letter_Sent_Date__c = Date.Today();
        newOppCH.StageName = 'New Opportunity';
        newOppCH.Training_Date__c = Date.today()+3;
        newOppCH.Doc_Collection_Status__c = 'Docs On File - Pending' ;        
        newOppCH.Email_Stage__c = null ; 
        newOppCH.DexTracker_Email__c = 'Yes';
        newOppCH.Consumer_Email__c = 'Tesdt@gmail.com';     
        newOppCH.CloseDate = Date.Today().addDays(30);
        insert newOppCH;
        
        //newOppCH.Type = 'Subscription';
        //update newOppCH;
        
        //Insert Opportunity Products
        List<OpportunityLineItem> lineItemsToBeInserted = new List<OpportunityLineItem>();
        for(String productName : products.keySet())
        {
            OpportunityLineItem newItem = new OpportunityLineItem();
            newItem.OpportunityId = newOppCH.Id;
            newItem.Repeat_Quantity__c = 2;
            newItem.Repeat_after_in_Days__c = 2 ;
			newItem.Quantity  = 1;
			newItem.UnitPrice = 125;
            newItem.PricebookEntryId = productIdToPbeId.get(products.get(productName));
            lineItemsToBeInserted.add(newItem);
        }
        insert lineItemsToBeInserted;
        oldTriggerOpportunities.put(newOppCH.Id,newOppCH);
        ClsCheckRecursive.run = true ;
        newOppCH.Health_Insurance_Approval__c = 'Not Required';
        newOppCH.CA_Customer_Docs_Collection_Status__c = 'Not Required';
        newOppCH.Health_Insurance_Approval__c = 'Not Required';
        newOppCH.Stagename = 'Order Fulfillment'; 
        update newOppCH ;  
       newTriggerOpportunities.put(newOppCH.Id,newOppCH);
        ClsCHOpportunityTriggerHandler.processOpportunityForScheduleShipments(newTriggerOpportunities, oldTriggerOpportunities);
    }
}