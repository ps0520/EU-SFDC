/********************************************************************************
@Author         : Jagan Periyakaruppan
@Date Created   : 03/07/2018
@Description    : Test class to test the Order Functionality
*********************************************************************************/
@isTest
private class ClsTestOrderObject {
    @isTest static void TestOrderCreationAndUpdate(){
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Consumer', 'Germany');

        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'DE Netto-Preis Cash'});
        String customPricebookId = customPricebookMap.get('DE Netto-Preis Cash');

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
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntries(productIdToPriceMap, customPricebookId);
		Id deOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DE_Sales_Order').getRecordTypeId();
        //Create Order record
		ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
		newOrder.RecordtypeId = deOrderRecdTypeId;
        newOrder.Type = 'DE STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;
        newOrder.Pricebook2Id = customPricebookId; //added by Shailendra to resolve the issue..
        newOrder.Status = 'Draft';
        insert newOrder;
        
        List<Order> orderList = new List<Order>();
        Pricebook2 newPricebook = new Pricebook2();
        newPricebook.Name = 'DE Netto-Preis';
        newPricebook.IsActive = true;
        newPricebook.CurrencyIsoCode = 'EUR' ; 
        insert newPricebook;
            orderList.add(newOrder);
        
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
     //   BPClsOrderHandler BpCl = new BPClsOrderHandler();
        BPClsOrderHandler.populateSubscriptionOrderItems(newOrder, newPricebook);
        BPClsOrderHandler.autoCreateOppsOnOrderActivation(orderList);
        
        //Update tracking number information
		ClsOrderTriggerStaticClass.isExecuting = false;
        OrderItem newOrderItem = [SELECT Id, Tracking_Number__c,Product_Name__c FROM OrderItem WHERE Id = : orderItemList[0].Id];
        system.debug('********product name is ' +newOrderItem.Product_Name__c);
        newOrderItem.Tracking_Number__c = '123456|10';
        newOrderItem.Serial_Number__c = 'SM1236547';
        update newOrderItem;
        delete orderItemList;
        
        
    }
    
    @isTest static void TestOrderCreationAndUpdateCA(){
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CA Consumer', 'Canada');

        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'CA Cash'});
        String customPricebookId = customPricebookMap.get('CA Cash');

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
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntriesCA(productIdToPriceMap, customPricebookId);
		Id caOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CA_Sales_Order').getRecordTypeId();
        //Create Order record
		ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
		newOrder.RecordtypeId = caOrderRecdTypeId;
        newOrder.Type = 'CA STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;
        newOrder.Pricebook2Id = customPricebookId; 
        newOrder.Status = 'Draft';
        insert newOrder;
        newOrder.Pricebook2Id = customPricebookId; 
        newOrder.Invoice_Date__c = System.today();
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
        Test.startTest();
        Map<id, order> ordernew = new Map<id, order>();
        Map<id, OrderItem> OrderItemMap = new Map<id, OrderItem>();
        ordernew.put(newOrder.id, newOrder) ;
        OrderItemMap.put(newOrder.id, orderItemList[0]) ;
        
        ClsOrderEntryHandler.checkForCreditCard(ordernew);
        ClsOrderEntryHandler.authorizeCreditCard(newOrder.id);
        ClsOrderEntryHandler.CCsettlePayment(newOrder.id);
        
        ClsOrderEntryHandler.captureCCpayment(newOrder.id);
        ClsOrderEntryHandler.ccAuthorizeAndSettlePayment(newOrder.id);
        ClsOrderEntryHandler.handlePendingSubscriptionPayments(newOrder.id);
        ClsOrderHandler.updateInvoiceDetails(OrderItemMap);
        ClsOrderEntryHandler.validateEmail('Test@gmail.com');
        ClsOrderEntryHandler.validatePhone('1234567898');
        
        //Update tracking number information
		ClsOrderTriggerStaticClass.isExecuting = false;
        OrderItem newOrderItem = [SELECT Id, Tracking_Number__c,Product_Name__c FROM OrderItem WHERE Id = : orderItemList[0].Id];
        system.debug('********product name is ' +newOrderItem.Product_Name__c);
        newOrderItem.Tracking_Number__c = '123456|10';
        newOrderItem.Serial_Number__c = 'SM1236547';
        update newOrderItem;
        delete orderItemList;
        Test.stopTest();
        
        
        
    }
    
     @isTest static void TestOrderCreationAndUpdateCH(){
        //Insert 1 consumer account record
        List<Account> consumerAccts = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland');

        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'CH Cash'});
        String customPricebookId = customPricebookMap.get('CH Cash');

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
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntriesCH(productIdToPriceMap, customPricebookId);
		Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        //Create Order record
		ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = consumerAccts[0].Id;
		newOrder.RecordtypeId = chOrderRecdTypeId;
        newOrder.Type = 'CH STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;       
        newOrder.Status = 'Draft';
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
        Test.startTest();
        //Update tracking number information
		ClsOrderTriggerStaticClass.isExecuting = false;
        OrderItem newOrderItem = [SELECT Id, Tracking_Number__c,Product_Name__c FROM OrderItem WHERE Id = : orderItemList[0].Id];
        system.debug('********product name is ' +newOrderItem.Product_Name__c);
        newOrderItem.Tracking_Number__c = '123456|10';
        newOrderItem.Serial_Number__c = 'SM1236547';
        update newOrderItem;
        delete orderItemList;
         Test.stopTest();
        
        
    }
}