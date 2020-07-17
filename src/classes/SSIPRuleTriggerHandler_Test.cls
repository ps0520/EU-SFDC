@isTest()
private class SSIPRuleTriggerHandler_Test { 
	@testSetup static void setup() {
        Map<String, String> mapPriceBook = ClsTestDataFactory.createCPB(new List<String>{'CH Cash','DE Netto-Preis Cash'}, 'CHF');        
        Map<String, Id> mapProduct = ClsTestDataFactory.createProducts(new List<String>{'Product-01', 'Product-02', 'Product-03', 'DEX-SHIP-01'});
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>{mapProduct.values()[0] => 10, mapProduct.values()[1] => 0, mapProduct.values()[2] => 0 };
        Map<Id, Id> mapPBE = ClsTestDataFactory.CreateCPBEntries(productIdToPriceMap, mapPriceBook.get('CH Cash'), 'CHF');
    }
    
    // for Class BClsSSIPSchedule
    @isTest private static void test1(){
		//Id rtId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('CH Sales Order').getRecordTypeId();  
        Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Credit_Hold__c = false;
        update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Credit_Hold__c=false];
        System.debug('lstAccount--'+lstAccount);
        List<PEClsHandleOrderEvents.OrderLineItem> lstOLI = new List<PEClsHandleOrderEvents.OrderLineItem>();
        for(Product2 product : [SELECT Id, Name FROM Product2]){
            lstOLI.add(new PEClsHandleOrderEvents.OrderLineItem(product.Id, 1, 10));
        }
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2];
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
        List<PricebookEntry> lstPBE = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
        Order objOrder = new Order(AccountId = lstAccount[0].Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   //Payor__c = payorAccount.Id,
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, First_Order__c = objOrder.Id, Schedule_Count__c = 1, Frequency_In_Days__c = 30,
                                             First_Repeat_Order_Lead_Days__c = 7, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Product__c = pbe.Product2Id, Quantity__c = 1, Shipping_Address__c = lstAddress[1].Id, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;
        for(SSIP_Rule__c ssipRule : lstSSIPRule){
            ssipRule.First_Shipment_Date__c = Date.today();
            ssipRule.Rule_Re_schedule_Date__c = Date.today()+1;
        }
        //update lstSSIPRule;
        
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
         
        }
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        update lstSSIPSchedule;
        
        test.startTest();
        DataBase.executeBatch(new BClsSSIPSchedule());
        test.stopTest();
    }
    @isTest private static void test2(){
		//Id rtId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('CH Sales Order').getRecordTypeId();  
        Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account];
        System.debug('lstAccount--'+lstAccount);
        List<PEClsHandleOrderEvents.OrderLineItem> lstOLI = new List<PEClsHandleOrderEvents.OrderLineItem>();
        for(Product2 product : [SELECT Id, Name FROM Product2]){
            lstOLI.add(new PEClsHandleOrderEvents.OrderLineItem(product.Id, 1, 10));
        }
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2];
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
        List<PricebookEntry> lstPBE = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
        Order objOrder = new Order(AccountId = lstAccount[0].Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   //Payor__c = payorAccount.Id,
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        // Dont insert the Order
        payorAccount.Credit_Hold__c = true;
        //payorAccount.RecordTypeId = null;
        update payorAccount;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, First_Order__c = objOrder.Id, Schedule_Count__c = 1, Frequency_In_Days__c = 30,
                                             First_Repeat_Order_Lead_Days__c = 7, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Product__c = pbe.Product2Id, Quantity__c = 1, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;
        for(SSIP_Rule__c ssipRule : lstSSIPRule){
            ssipRule.First_Shipment_Date__c = Date.today();
            ssipRule.Rule_Re_schedule_Date__c = Date.today()+1;
        }
       // update lstSSIPRule;
        
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
           ssipSchedule.Payment_Term__c = 'net0';
        }
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        update lstSSIPSchedule;
        
        test.startTest();
        DataBase.executeBatch(new BClsSSIPSchedule());
        test.stopTest();
    }
    @isTest private static void test3(){
		//Id rtId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('CH Sales Order').getRecordTypeId();  
        Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account];
        System.debug('lstAccount--'+lstAccount);
        List<PEClsHandleOrderEvents.OrderLineItem> lstOLI = new List<PEClsHandleOrderEvents.OrderLineItem>();
        for(Product2 product : [SELECT Id, Name FROM Product2]){
            lstOLI.add(new PEClsHandleOrderEvents.OrderLineItem(product.Id, 1, 10));
        }
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2];
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
        List<PricebookEntry> lstPBE = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
        Order objOrder = new Order(AccountId = lstAccount[0].Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   //Payor__c = payorAccount.Id,
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, First_Order__c = objOrder.Id, Schedule_Count__c = 1, Frequency_In_Days__c = 30,
                                             First_Repeat_Order_Lead_Days__c = 7, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Product__c = pbe.Product2Id, Quantity__c = 1, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;
        for(SSIP_Rule__c ssipRule : lstSSIPRule){
            ssipRule.First_Shipment_Date__c = Date.today();
            ssipRule.Rule_Re_schedule_Date__c = Date.today()+1;
        }
       // update lstSSIPRule;
        
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
           ssipSchedule.Payment_Term__c = 'net0';
        }
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        update lstSSIPSchedule;
        
        test.startTest();
        DataBase.executeBatch(new BClsSSIPSchedule());
        test.stopTest();
    }
    //For class SSIPScheduleJobUtiltiy
    @isTest private static void test4(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net0',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net0';
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
       test.startTest();            
       System.enqueueJob(new SSIPScheduleJobUtiltiy.CalculateTaxQueueable(objOrder.Id, objOrder.Payment_Terms__c,
                                                                          'CH',//objOrder.Account.RecordType.Name.substring(0,2)
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
        test.stopTest();
    }
    @isTest private static void testSheduleException(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net0',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net0',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net0';
            ssipSchedule.Order__c = objOrder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
       
       	
	   test.startTest();            
       System.enqueueJob(new SSIPScheduleJobUtiltiy.CalculateTaxQueueable(objOrder.Id, objOrder.Payment_Terms__c,
                                                                          'CH',//objOrder.Account.RecordType.Name.substring(0,2)
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
        test.stopTest();
    }
    //For AuthorizeAndSettlePaymentQueueable
    @isTest private static void testAuthirizeSettle(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net30',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net30';
            ssipSchedule.Order__c = objorder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CH',
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
         
         test.stopTest();
    }
    @isTest private static void testAuthirizeSettleException(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   //Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net30',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net30';
            ssipSchedule.Order__c = objorder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CH',
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
         
         test.stopTest();
                   
		
    }
    @isTest private static void testAuthirizeSettleFinanceException(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c=null, Primary__c=true, CC_Address__c=null, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net30',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net30';
            ssipSchedule.Order__c = objorder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CH',1,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
         
         test.stopTest();
                   
		
    }
    @isTest private static void testAcccUpdateException(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c=null, Primary__c=true, CC_Address__c=null, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net30',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net30';
            ssipSchedule.Order__c = objorder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CH',1,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          null, true));
         
         test.stopTest();
                   
		
    }
    @isTest private static void testOrderUpdateException(){ 
         
         
         Id chOrderRecdTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CH_Sales_Order').getRecordTypeId();
        
		Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'CH Consumer', 'Switzerland')[0];
        payorAccount.Subscription_Pending_Payments__c = 1;
         update payorAccount;
        List<Account> lstAccount = [SELECT Id, Name,Credit_Hold__c FROM Account where Subscription_Pending_Payments__c >0];
       
        List<Product2> lstProduct = [SELECT Id, Name FROM Product2]; 
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = lstAccount[0].Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Bill To', Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = 'W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg'),
                                                            new Address__c(Account__c = payorAccount.Id,Type__c = 'Ship To',Country__c = 'Switzerland', City__c = 'Rosemont', Address_Line_1__c = ' W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true, System_Of_Origin__c = '12345', System_Of_Origin_Id__c = 'abcdefg')
                                                          };
        insert lstAddress;
         
         Id rtIdFDCC = Schema.SObjectType.Finance_Detail__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Finance_Detail__c fd1= new Finance_Detail__c(Account__c=payorAccount.Id,Token__c='1111', Card_Type__c='Mastercard',CC_CUR__c='CHF',
                                                     Expiry_Date__c='1112/21', Primary__c=true, CC_Address__c=lstAddress[0].id, RecordTypeId=rtIdFDCC);
        insert fd1;
        List<PricebookEntry> lstPBE = [SELECT Id,Name, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'CH Cash'];
       Order objOrder = new Order(AccountId = payorAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'CH STANDARD', 
                                   Pricebook2Id = lstPBE[0].Pricebook2Id,
                                   Payment_Terms__c = 'net30',
                                   Finance_Detail__c = fd1.Id,
                                   RecordTypeId = chOrderRecdTypeId, CurrencyISOCode = 'CHF');
        insert objOrder;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        lstOrderItem.add(new OrderItem(PricebookEntryId = lstPBE[0].Id, OrderId = objOrder.Id, Quantity = 1, UnitPrice = 10));
        insert lstOrderItem;
        
        List<SSIP_Rule__c> lstSSIPRule = new List<SSIP_Rule__c>();
        for(PricebookEntry pbe : lstPBE){ // First_Order__c = objOrder.Id,
            System.debug('***pbe--'+pbe.Name);
            Integer fr = 0;
            Integer Ld = 0;
            Integer Quant = 0;
            if(pbe.Name == 'Product-01'){
                fr = 30;
                Ld = 0;
                Quant = 1;
                
            }else if(pbe.Name == 'Product-02'){
                fr = 90;
                Ld = 10;
                Quant = 3;
            }else{
                fr = 90;
                Ld = 10;
                Quant = 1;
            }
            lstSSIPRule.add(new SSIP_Rule__c(Account__c = lstAccount[0].Id, Schedule_Count__c = 1, Frequency_In_Days__c = fr,Payment_term__c ='net30',
                                             First_Repeat_Order_Lead_Days__c = Ld, Price_Book__c = pbe.Pricebook2Id, PriceBookEntryId__c = pbe.Id,
                                             Product__c = pbe.Product2Id,First_Shipment_Date__c = Date.today(),Rule_Re_schedule_Date__c = Date.today()+1,
                                             Quantity__c = Quant, Shipping_Address__c = null, Status__c = 'Active'));
        }
        
        insert lstSSIPRule;      
       
        List<SSIP_Schedule__c> lstSSIPSchedule = [SELECT Id,Account__c FROM SSIP_Schedule__c where Account__c=: payorAccount.Id];
        for(SSIP_Schedule__c ssipSchedule : lstSSIPSchedule){
            ssipSchedule.Rescheduled_Shipment_Date__c = Date.today();
            ssipSchedule.Payment_Term__c = 'net30';
            ssipSchedule.Order__c = objorder.Id;
        }
        
        update lstSSIPSchedule;
        System.debug('====lstSSIPSchedule===='+lstSSIPSchedule);
        
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ClsMockHttpResponseGenCCAuthorize());
		 System.enqueueJob(new SSIPScheduleJobUtiltiy.AuthorizeAndSettlePaymentQueueable(objOrder.Id,'CHSD',
                                                                          (Integer) objOrder.Count_of_Order_Line_Items__c,
                                                                          (Integer) objOrder.Account.Subscription_Pending_Payments__c,
                                                                          objOrder.AccountId, true));
         
         test.stopTest();
    }
    
}