@isTest
public class ClsCCAuthAndSettlementServiceTest {
    @testSetup static void setup() {        
        //Map<String, String> mapPriceBook = ClsTestDataFactory.createCustomPricebook(new List<String>{'DE Netto-Preis Cash'}, 'CHF');
        Map<String, String> mapPriceBook = ClsTestDataFactory.createCPB(new List<String>{'DE Netto-Preis Cash', 'DE Return Replace', 'Barmer'}, 'CHF');
        Map<String, Id> mapProduct = ClsTestDataFactory.createProducts(new List<String>{'Product-01', 'DEX-SHIP-01', 'Product-03'});
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>{mapProduct.values()[0] => 10, mapProduct.values()[1] => 10, mapProduct.values()[2] => 10 };
        //Map<Id, Id> mapPBE = ClsTestDataFactory.createCustomPricebookEntries(productIdToPriceMap, mapPriceBook.get('DE Netto-Preis Cash'), 'CHF');
        Map<Id, Id> mapPBE = ClsTestDataFactory.CreateCPBEntries(productIdToPriceMap, mapPriceBook.get('DE Netto-Preis Cash'), 'CHF');
        Account objAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Consumer', 'Germany')[0];
        
        //Query for the Address record types
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Address__c' and isActive=true];
    
        //Create a map between the Record Type Name and Id 
        Map<String,String> addRecordTypes = new Map<String,String>();
        for(RecordType rt: rtypes) {
        	addRecordTypes.put(rt.Name,rt.Id);
        }     	
        String recordTypeId = addRecordTypes.get('DE Address');        
        List<Address__c> lstAddress = new List<Address__c>{
         	new Address__c(Account__c = objAccount.Id,RecordTypeId = recordTypeId,Type__c = 'Bill To', Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
            new Address__c(Account__c = objAccount.Id,RecordTypeId = recordTypeId,Type__c = 'Ship To',Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
        };
        insert lstAddress;
        
        Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=objAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='GBP', Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        
        Id orderRTId=[Select Id from RecordType Where sObjectType='Order' AND RecordType.DeveloperName='DE_Sales_Order' Limit 1].Id;        
        List<PricebookEntry> lstPBE = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2.Name = 'DE Netto-Preis Cash'];
        Order objOrder = new Order(AccountId = objAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Finance_Detail__c = fd1.Id, RecordTypeId=orderRTId, Pricebook2Id = lstPBE[0].Pricebook2Id, CurrencyISOCode='CHF');
        insert objOrder;
        
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
    }
    
    @isTest static void TestAuthorize(){
    	Order o=[Select Id, OrderNumber, AccountId,EffectiveDate, Status, Finance_Detail__c, Total_Gross_Price__c, CC_Auth_Amount__c from Order Limit 1][0];
        System.Debug('**** TPS:EH TestAuthorize Order 1=' + o);
        Account a=[Select Id from Account Where Id=:o.AccountId Limit 1][0];
        /*Order o1 =[Select Id, OrderNumber, TotalAmount, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail, Account.Owner.Email, 
                 Finance_Detail__r.Expiry_Date__c, Finance_Detail__r.Token__c, Finance_Detail__r.CC_Address__r.Address_Line_1__c, 
                 Finance_Detail__r.CC_Address__r.City__c,  Finance_Detail__r.CC_Address__r.State__c, Finance_Detail__r.CC_Address__r.Postal_Code__c, Finance_Detail__r.CC_Address__r.Country__c 
                 from Order Where Id =:o.Id AND Finance_Detail__r.Primary__c=true AND Finance_Detail__r.Token__c != null 
             	 AND Finance_Detail__r.Expiry_Date__c != null AND Finance_Detail__r.CC_Address__c != null];
        System.Debug('*** Orders=' + JSON.serialize(o1));*/
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
        	ClsCCAuthAndSettlementService.authorize(o.Id);
        	System.Debug('**** TPS:EH TestAuthorize Order 2=' + o);
        	ClsCCAuthAndSettlementService.authorize(o.Id);        	
        	ClsCCAuthAndSettlementService.authorize(a.Id);
        Test.stopTest();        
        
    }
    
    @isTest static void TestSettlePayment(){
        Order o=[Select Id, OrderNumber, AccountId,EffectiveDate, Status, Finance_Detail__c,Total_Gross_Price__c, CC_Auth_Amount__c from Order Limit 1][0];
        o.CC_Auth_Amount__c=11.90; update o;
        System.Debug('**** TPS:EH TestSettlePayment Order 1=' + o);
        Account a=[Select Id from Account Where Id=:o.AccountId Limit 1][0];
        o.Payment_Id__c='123456'; update o;
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCSettle());
        
        	ClsCCAuthAndSettlementService.settlePayment(o.Id);
        	System.Debug('**** TPS:EH TestSettlePayment Order 2=' + o);
        	ClsCCAuthAndSettlementService.settlePayment(o.Id);
        	ClsCCAuthAndSettlementService.settlePayment(a.Id);
        Test.stopTest();     
    }
    
    @isTest static void authorizeAndSettlePayment(){
        Order o=[Select Id, OrderNumber, AccountId,EffectiveDate, Status, Finance_Detail__c from Order Limit 1][0];
        Account a=[Select Id from Account Where Id=:o.AccountId Limit 1][0];
    	Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
        	ClsCCAuthAndSettlementService.authorizeAndSettlePayment(o.Id);
        	ClsCCAuthAndSettlementService.authorizeAndSettlePayment(o.Id);
        	ClsCCAuthAndSettlementService.authorizeAndSettlePayment(a.Id);
        Test.stopTest();     
        
    }
}