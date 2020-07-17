/****************************************************************************************************************
@Author         : Shailendra Singh Lodhi
@Date Created   : 5/22/2019
@Description    : Creating class for process builder relatd to Order object 
****************************************************************************************************************/

@isTest
private class BPTestClsOrder {

	private static testMethod void test() {
        Map<String, String> mapPriceBook = ClsTestDataFactory.createCustomPricebook(new List<String>{'DE Netto-Preis Cash', 'DE Return Replace', 'Barmer'});
        Map<String, Id> mapProduct = ClsTestDataFactory.createProducts(new List<String>{'Product-01', 'Product-02', 'DEX-SHIP-01'});
        Map<Id, Decimal> productIdToPriceMap = new Map<Id, Decimal>();
        for(Id productId : mapProduct.values()){
            productIdToPriceMap.put(productId, 10);
        }
        Map<Id, Id> mapPBE = ClsTestDataFactory.createCustomPricebookEntries(productIdToPriceMap, mapPriceBook.get('DE Netto-Preis Cash'));
        Account objAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Consumer', 'Germany')[0];
        objAccount.PersonEmail = 'test@gmail.com';
        update objAccount;
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Payor', 'Germany')[0];
        Account payorAccount2 = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Payor', 'Germany')[0];
        
        Id AddId=[Select Id from RecordType Where sObjectType='Address__c' AND Name='DE Address' Limit 1].Id;
        
        List<Address__c> lstAddress = new List<Address__c>{
                                                            new Address__c(Account__c = objAccount.Id,RecordTypeId = AddId, Type__c = 'Bill To', Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true),
                                                            new Address__c(Account__c = objAccount.Id,RecordTypeId = AddId, Type__c = 'Ship To',Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true),
                                                            new Address__c(Account__c = payorAccount.Id,RecordTypeId = AddId, Type__c = 'Bill To', Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true),
                                                            new Address__c(Account__c = payorAccount.Id,RecordTypeId = AddId, Type__c = 'Ship To',Country__c = 'Germany', City__c = 'Rosemont', Address_Line_1__c = '10255 W Higgins Rd', Postal_Code__c = '60089', Primary_Flag__c = true)
                                                          };
        insert lstAddress;
        Benefit__c primaryBenefit = new Benefit__c(Account__c = objAccount.Id, Member_Id__c = '1789657890', Payor__c = payorAccount.Id, Benefit_Hierarchy__c = 'Primary');
		insert primaryBenefit;
        Opportunity newOpp = new Opportunity(Name = 'New Opportunity For Testing', AccountId = objAccount.Id, Benefit__c = primaryBenefit.Id,Type = 'Reorder', Consumer_Email__c = 'test@gmail.com',
                                             Payor__c = payorAccount.Id, Pricebook2Id = mapPriceBook.get('Barmer'), CloseDate = Date.Today().addDays(30),
                                             Contact_Letter_Sent__c = true, Contact_Doc_Received__c = true, Insurance_Doc_Received__c = true, Hard_Copy_Out__c = true,
                                             Hard_Copy_In__c = true, Training_Letter_Sent__c = true, Training_Letter_Sent_Date__c = Date.Today(), StageName = 'New Opportunity');
        insert newOpp;
        
        insert new BP_Process_Builder_Customization__c(Name = 'DE_Sales_Order', PriceBook__c = mapPriceBook.get('DE Return Replace'));
       // Order objOrder = new Order(AccountId = objAccount.Id, EffectiveDate = Date.today(), Status = 'Draft', Type = 'DE TECH RETURN', Payor__c = payorAccount.Id);
       // insert objOrder;
       // objOrder.Payor_Bill_To_Address__c = lstAddress[2].Id;
      //  update objOrder;
        //objAccount.PersonEmail = 'MADMI@GMAIL.COM';
        //update objAccount;
        Test.startTest();
        Order objOrder1 = new Order(AccountId = objAccount.Id, EffectiveDate = Date.today(), Status = 'Draft',Type = 'DE STANDARD', Price_Book__c = mapPriceBook.get('DE Netto-Preis Cash'), OpportunityId = newOpp.Id, PriceBook2Id = mapPriceBook.get('DE Netto-Preis Cash'), CurrencyIsoCode = 'EUR');
        insert objOrder1;
        objOrder1.Payor__c = payorAccount.Id;
        update objOrder1;
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        for(Id pbeId : mapPBE.values()){
            lstOrderItem.add(new OrderItem(PricebookEntryId = pbeId, OrderId = objOrder1.Id, Quantity = 1, UnitPrice = 10));
        }
        insert lstOrderItem; 
        payorAccount2.Payor__c = payorAccount2.Id;
        objOrder1.Status = 'OPEN';
        objOrder1.Email_Stage__c = null;
        update objOrder1;
        List<OrgWideEmailAddress> lstOWEA = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'de.info@dexcom.com' LIMIT 1];
        BPClsOrder.prepareEmailMessage(null,'test@gmail.com',objAccount.Id,objOrder1.Id,'Test Subject',lstOWEA[0].id);
        SDJob_Temp__c objTemp = new SDJob_Temp__c(Doclist__c = null, Sobject_Name__c = 'Order', Sobject_Id__c = objOrder1.Id, Create_SDJob__c = false);
        insert objTemp;
        objTemp.Create_SDJob__c = true;
        update objTemp;
        Test.stopTest();
	}

}