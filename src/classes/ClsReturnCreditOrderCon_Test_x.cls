/********************************************************************************
@Author         : P Saini
@Date Created   : May/06/2020
@Description    : Test class for ClsReturnCreditOrderCon, return and credit order function.
*********************************************************************************/
@isTest
private class ClsReturnCreditOrderCon_Test_x {
    /*static void setup() {
        Map<String, String> mapAccRT=ClsTestDataFactory.getRecordTypeMap();
        Account a = new Account();
        a.CurrencyIsoCode = 'GBP';
        a.RecordTypeId = mapAccRT.get('GB Consumer');
        a.FirstName='ClsReturnCreditOrderCon_Test';
        a.LastName='ClsReturnCreditOrderCon_Test0';
        a.BillingStreet = '100 King St W';
        a.BillingCity = 'CHERTSEY';
        a.BillingPostalCode = 'KT16 8HL';
        a.BillingCountryCode = 'GB';
        a.PersonEmail = 'ClsReturnCreditOrderCon_Test@gmail.com';
        a.PersonHasOptedOutOfEmail = false;
        insert a;
        
        Pricebook2 pb = new Pricebook2(); pb.Name = 'UK Payer List Price'; pb.IsActive = true; pb.CurrencyIsoCode ='GBP';
        insert pb;
        Map<String, Id> mapProduct = ClsTestDataFactory.createProducts(new List<String>{'STS-GS-003'});
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = mapProduct.get('STS-GS-003'), UnitPrice = 1, IsActive = true, CurrencyIsoCode = 'GBP');
        insert pbe1;
        
        //ClsOrderTriggerStaticClass.isExecuting = false;        
        Id rtGBSalesOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('GB Sales Order').getRecordTypeId();
        Order o1 = new Order(); o1.AccountId = a.Id; o1.RecordtypeId = rtGBSalesOrder; o1.Type = 'GB STANDARD';
        o1.EffectiveDate = System.today(); o1.Price_Book__c = pb.Id; o1.Status = 'Draft'; o1.PriceBook2Id=pb.Id;
        //insert o1;
        
    }*/
    
   @isTest static void TestSaveReturnQty(){
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'International Distributor', 'Netherlands');
        
        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebookDIST(new List <String>{'DIST Pricebook'});
        String customPricebookId = customPricebookMap.get('DIST Pricebook');
        
        //Create Products
        Map<String, Id> products = ClsTestDataFactory.createProducts(new List<String> {'MT21255', 'STS-GS-002', 'DEX-SHIP-01'});
        
        //Create Pricebook EntryPair
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(String productName : products.keySet())
        {
            productIdToPriceMap.put(products.get(productName), 125.00);
            
        }
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntriesDIST(productIdToPriceMap, customPricebookId);
        Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DIST_Sales_Order').getRecordTypeId();
        //Create Order record
        ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
        newOrder.RecordtypeId = chOrderRecdTypeId;
        newOrder.Type = 'DIST STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;
        newOrder.PriceBook2Id = customPricebookId;
        newOrder.Status = 'Draft';
        insert newOrder;        
       
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Id pbeId : productIdToPbeId.values())
        {
            OrderItem oi = new OrderItem();
            oi.OrderId = newOrder.Id;
            oi.PricebookEntryId = pbeId;
            oi.Quantity = 1;
            oi.UnitPrice = 125.00;
            oi.Tracking_Number__c = '12345';
            oi.Product_Name__c = 'STS-GS-002' ;
            orderItemList.add(oi);
        }
        insert orderItemList;
        Test.startTest();
        
        newOrder.Status = 'Closed';
        update newOrder;
        
        
        Order oReturn = new Order();
        oReturn.AccountId = consumerAccts[0].Id;
        oReturn.RecordtypeId = chOrderRecdTypeId;
        oReturn.Parent_Order__c = newOrder.id;
        oReturn.Type = 'DIST RETURN';
        oReturn.EffectiveDate = System.today();
        oReturn.Price_Book__c = customPricebookId;
        oReturn.PriceBook2Id = customPricebookId;
        oReturn.Status = 'Draft';
        insert oReturn;
        
        List<OrderItem> lstOIChild = new List<OrderItem>();
        for(Id pbeId : productIdToPbeId.values())
        {
            OrderItem oi = new OrderItem();
            oi.OrderId = oReturn.Id;
            oi.PricebookEntryId = pbeId;
            oi.Quantity = -1;
            oi.UnitPrice = 125.00;
            oi.Tracking_Number__c = '12345';
            oi.Product_Name__c = 'STS-GS-002' ;
            oi.Return_Reason__c='Discontinuation';
            lstOIChild.add(oi);
        }
        insert lstOIChild;
        
        string srcData='[{"AvailableQty":1,"errorQTY":"No","errorRR":"No","Id":"8021n00000YwouaAAB","OIId":"8020Q000001TNcjQAG","PBEId":"01u1n00000HsfQ2AAJ","ProductCode":"STT-GS-003","ProductId":"01t1n00000B6UjMAAV","ReturnQty":1,"ReturnReason":"Internal Processing Error","UnitPrice":125}]';
        ClsReturnCreditOrderCon.SaveReturnQty(srcData, oReturn.id);
        Test.stopTest();
    }    
   
    
    @isTest static void Test_getReturnReasonsList(){
        System.Assert(ClsReturnCreditOrderCon.getReturnReasonsList('GB') != null);  
    }
}