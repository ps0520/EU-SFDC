/*******************************************************************************************
@Author        : Kumar Navneet
@Date Created    : 08/13/2019
@Description    : Test class to test the scenarios involved in Fund object
*********************************************************************************************/
@isTest
private class ClsTestFundObject {
    
    @isTest static void TestOrderFundCreationAndUpdate(){
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'GB Consumer', 'United Kingdom');
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'GB Payor', 'United Kingdom')[0];
        
        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'GB Cash'});
        String customPricebookId = customPricebookMap.get('GB Cash');
        
        //Create Products
        Map<String, Id> products = ClsTestDataFactory.createProducts(new List<String> {'STK-GF-013', 'STT-GF-004', 'DEX-SHIP-01'});
        
        //Update the virtual sku productIdToPbeId
        Product2 virtualProd = [SELECT Id, Is_Virtual_Product__c FROM Product2 WHERE NAME = 'DEX-SHIP-01'];
        virtualProd.Is_Virtual_Product__c = true;
        update virtualProd;
        
        //Create Pricebook EntryPair
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(String productName : products.keySet())
        {
            productIdToPriceMap.put(products.get(productName), 125.00);
            
        }
        
        
        Fund__c Fd = new Fund__c();
        Fd.PO_Reference_Number__c ='87666787';
        Fd.Limit_Type__c ='Quantity';        
        Fd.Payor__c = payorAccount.Id;
        Fd.Amount_Limit__c = 100000;
        Fd.Auth_End_Date__c = Date.today().addDays(100);
        Fd.Auth_Start_Date__c = Date.today();
        Fd.Receiver_Qty_Limit__c = 100; 
        Fd.Sensor_Limit__c = 100; 
        Fd.Transmitter_Qty_Limit__c = 100 ;
        
        insert Fd ; 
        
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.CreateCPBEntries(productIdToPriceMap, customPricebookId, 'GBP');
        Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('GB_Sales_Order').getRecordTypeId();
        payorAccount.Price_Book__c = customPricebookId;   
        update payorAccount ;
        
        //Create Order record
        ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
        newOrder.RecordtypeId = chOrderRecdTypeId;
        newOrder.Type = 'GB STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;       
        newOrder.Status = 'Draft';
        newOrder.Payor__c = payorAccount.Id ;
        newOrder.Fund__c = Fd.id; 
        insert newOrder;
        
        newOrder.Pricebook2Id = customPricebookId; 
        update newOrder;
        
        
        //List order line items
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(Id pbeId : productIdToPbeId.values())
        {
            OrderItem oi = new OrderItem();
            oi.OrderId = newOrder.Id;
            oi.PricebookEntryId = pbeId;
            oi.Quantity = 1;
            oi.UnitPrice = 125.00;
            oi.Tracking_Number__c = '12345';
            oi.Product_Name__c = 'STK-GF-109' ;
            orderItemList.add(oi);
        }
        insert orderItemList;
        
        //Update tracking number information
        ClsOrderTriggerStaticClass.isExecuting = false;
        OrderItem newOrderItem = [SELECT Id, Tracking_Number__c,Product_Name__c FROM OrderItem WHERE Id = : orderItemList[0].Id];
        system.debug('********product name is ' +newOrderItem.Product_Name__c);
        newOrderItem.Tracking_Number__c = '123456|10';
        newOrderItem.Serial_Number__c = 'SM1236547';
        update newOrderItem;
        
        //  ClsFundService clsfd =new ClsFundService();
        ClsFundService.getPONumber(Fd.id);
        ClsFundService.checkFundBalance(newOrder.id);
        ClsFundService.chargeFund(newOrder.id);
        
        
        
        
    }
}