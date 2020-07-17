@isTest
public class CtrlOrderAuditTest_v1 {

    
    	 public static id TestOrderCreationAndUpdate(){
         
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                                   where sObjectType='Account' and isActive=true];
        //Create a map between the Record Type Name and Id 
        Map<String,String> accountRecordTypes = new Map<String,String>();
        for(RecordType rt: rtypes)
            accountRecordTypes.put(rt.Name,rt.Id);
        List<Account> accts = new List<Account>();
        
        String recordTypeIdCA = accountRecordTypes.get('AT Consumer');
        Account CHacc = new Account();
        CHacc.CurrencyIsoCode = 'EUR';
        CHacc.RecordTypeId = recordTypeIdCA;
        CHacc.FirstName='TestConsumerFirstName';
        CHacc.LastName='TestConsumerLastName';
        CHacc.BillingStreet = 'Grüner Weg';
        CHacc.BillingCity = 'Friedberg';
        CHacc.BillingPostalCode = '1234';
        CHacc.BillingCountryCode = 'AT';
        CHacc.PersonEmail = 'Tesdt@gmail.com';
        CHacc.PersonHasOptedOutOfEmail = false;
        insert CHacc;
        //Create Pricebook
        Map<String, Id> customPricebookMap = ClsTestDataFactory.createCustomPricebook(new List <String>{'AT Cash'});
        String customPricebookId = customPricebookMap.get('AT Cash');

        //Create Products
        Map<String, Id> products = ClsTestDataFactory.createProducts(new List<String> {'STK-GF-013', 'STT-GF-004', 'VIRTUAL_SKU', 'DEX-SHIP-01'});
        
        //Update the virtual sku productIdToPbeId
        Product2 virtualProd = [SELECT Id, Is_Virtual_Product__c FROM Product2 WHERE NAME = 'DEX-SHIP-01'];
        virtualProd.Is_Virtual_Product__c = true;
        update virtualProd;
        
        //Update the virtual sku productIdToPbeId
        virtualProd = [SELECT Id, Is_Virtual_Product__c FROM Product2 WHERE NAME = 'VIRTUAL_SKU'];
        virtualProd.Is_Virtual_Product__c = true;
        update virtualProd;
        
        //Create Pricebook EntryPair
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(String productName : products.keySet())
        {
            productIdToPriceMap.put(products.get(productName), 125.00);
            
        }
        Map<Id, Id> productIdToPbeId = ClsTestDataFactory.createCustomPricebookEntries(productIdToPriceMap, customPricebookId);
        
        //Create Order record
		ClsOrderTriggerStaticClass.isExecuting = false;
        Order newOrder = new Order();
        newOrder.AccountId = CHacc.Id;
        newOrder.Type = 'AT STANDARD';
        newOrder.EffectiveDate = System.today();
        newOrder.Price_Book__c = customPricebookId;
        //newOrder.Pricebook2Id = customPricebookId;//added by Shailendra to resolve the issue..
        newOrder.Status = 'Draft';
        newOrder.CurrencyIsoCode = 'EUR';
        insert newOrder;
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

         return newOrder.Id;
        
    }
    
   
}