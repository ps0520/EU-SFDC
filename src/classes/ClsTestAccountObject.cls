/********************************************************************************
@Author        : Jagan Periyakaruppan
@Date Created    : 08/12/2017
@Description    : Test class to test the scenarios involved in Account object
*********************************************************************************/
@isTest
private class ClsTestAccountObject {
    @isTest static void TestAccountAddress(){
        //Insert 10 account records
        List<Account> accts = ClsTestDataFactory.createAccountsWithBillingAddress(10, 'DE Consumer', 'Germany');
        Test.startTest();
        ClsAccountAddressTriggerStaticClass.addressChangeInvokedFromAddress = FALSE;
        ClsAccountAddressTriggerStaticClass.addressChangeInvokedFromAccount = TRUE;
        //Get the first account, which was inserted
        Account a = accts[0];
        String street = a.BillingStreet;
        String city = a.BillingCity;
        String state = a.BillingState;
        String postalCode = a.BillingPostalCode;
        String country = a.BillingCountry;
        List<Address__c> addrList = [SELECT Id FROM Address__c WHERE Account__c = :a.Id];
        system.assertEquals(2, addrList.size());
        addrList.clear();
        //Change the Billing and Shipping address and save the account
        a.BillingStreet = '1 Main Street';
        a.BillingCity = 'San Diego';
        a.BillingPostalCode = '92121';
        a.BillingCountryCode = 'DE';
        a.ShippingStreet = '2 Main Street';
        a.ShippingCity = 'San Diego';
        a.ShippingPostalCode = '92121';
        a.ShippingCountryCode = 'DE';
        Update a;
        addrList = [SELECT Id FROM Address__c WHERE Account__c = :a.Id];
        system.assertEquals(4, addrList.size());
        addrList.clear();
        //Query for the Address record types
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                               where sObjectType='Address__c' and isActive=true];
    
        //Create a map between the Record Type Name and Id 
        Map<String,String> addRecordTypes = new Map<String,String>();
        for(RecordType rt: rtypes) {
        addRecordTypes.put(rt.Name,rt.Id);
        }     	
        String recordTypeId = addRecordTypes.get('DE Address');
        
        //Insert new address record
        List<Address__c> addrListToBeInserted = new List<Address__c>();
        Address__c newBillToAddr = new Address__c();
        newBillToAddr.Account__c = a.Id;
        newBillToAddr.RecordTypeId = recordTypeId;
        newBillToAddr.Address_Line_1__c = '3 Main Street';
        newBillToAddr.City__c = 'San Diego';
        newBillToAddr.Postal_Code__c = '92121';
        newBillToAddr.Country__c = 'Germany';
        newBillToAddr.Type__c = 'Bill To';
        newBillToAddr.Primary_Flag__c = TRUE;
        addrListToBeInserted.add(newBillToAddr);
        Address__c newShipToAddr = new Address__c();
        newShipToAddr.Account__c = a.Id;
        newShipToAddr.RecordTypeId = recordTypeId;
        newShipToAddr.Address_Line_1__c = '4 Main Street';
        newShipToAddr.City__c = 'San Diego';
        newShipToAddr.Postal_Code__c = '92121';
        newShipToAddr.Country__c = 'Germany';
        newShipToAddr.Type__c = 'Ship To';
        newShipToAddr.Primary_Flag__c = TRUE;
        addrListToBeInserted.add(newShipToAddr);
        insert addrListToBeInserted;
        //Process to make existing address as Primary
        List<Address__c> addrListToBeUpdated = new List<Address__c>();
        //Query for original billing primary address and make it as primary
        Address__c billToAddrToBeMadePrimary = [SELECT Id FROM Address__c WHERE Address_Line_1__c = :street AND Account__c = :a.Id AND Type__c = 'Bill To'];
        billToAddrToBeMadePrimary.Primary_Flag__c = TRUE;
        addrListToBeUpdated.add(billToAddrToBeMadePrimary);
        //Query for original shipping primary address and make it as primary
        Address__c shipToAddrToBeMadePrimary = [SELECT Id FROM Address__c WHERE Address_Line_1__c = :street AND Account__c = :a.Id AND Type__c = 'Ship To'];
        shipToAddrToBeMadePrimary.Primary_Flag__c = TRUE;
        addrListToBeUpdated.add(shipToAddrToBeMadePrimary);
        update addrListToBeUpdated;
        //Make existing address as primary
        //Change the Billing and Shipping address and save the account
        a.BillingStreet = '3 Main Street';
        a.BillingCity = 'San Diego';
        a.BillingPostalCode = '92121';
        a.BillingCountryCode = 'DE';
        a.ShippingStreet = '4 Main Street';
        a.ShippingCity = 'San Diego';
        a.ShippingPostalCode = '92121';
        a.ShippingCountryCode = 'DE';
        Update a;
        Test.stopTest();
        //Confirm the counts
        addrList = [SELECT Id FROM Address__c WHERE Account__c = :a.Id];
        system.assertEquals(10, accts.size());
        system.assertEquals(6, addrList.size());
    }
    @isTest static void TestPrescriberToMedFacRelation(){
        //Insert 5 Prescriber record
        List<Account> prescriberAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Prescriber', 'Germany');
        //Insert 2 Prescribers tied to a Med Fac
        List<Account> prescribersWithMedFac = ClsTestDataFactory.createAccountsWithPrescriberToMedFacAssociation(2, 'Germany');
        Account prescriberAccnt = prescriberAccts[0];
        //Insert 5 Medical Facility record
        List<Account> medFacAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Medical Facility', 'Germany');
        Test.startTest();
        //Associate a Medical Facility to a Prescriber
        prescriberAccnt.Medical_Facility__c = medFacAccts[0].Id;
        update prescriberAccnt;
        //Change the association to another Medical Facility
        prescriberAccnt.Medical_Facility__c = medFacAccts[1].Id;
        update prescriberAccnt;
        //Change the association to first Medical Facility
        prescriberAccnt.Medical_Facility__c = medFacAccts[0].Id;
        update prescriberAccnt;
        Test.stopTest();
    }	
    @isTest static void TestAccountTerritoryAssignment(){
        //Insert zip to terr
        List<Zip_to_Terr__c> zipToTerrList = new List<Zip_to_Terr__c>();
        Zip_to_Terr__c zipToTerr = new Zip_to_Terr__c();
        zipToTerr.Name = '61169';
        ZipToTerr.Territory__c = 'DE020101';
        ZipToTerr.Region__c = 'DE020000';
        ZipToTerr.District__c = 'DE020100';
        ZipToTerr.Country__c = 'Germany';
        zipToTerrList.add(ZipToTerr);
        Zip_to_Terr__c zipToTerr1 = new Zip_to_Terr__c();
        zipToTerr1.Name = '61168';
        zipToTerr1.Territory__c = 'DE020102';
        zipToTerr1.Region__c = 'DE020000';
        zipToTerr1.District__c = 'DE020100';
        zipToTerr1.Country__c = 'Germany';
        zipToTerrList.add(zipToTerr1);
        insert zipToTerrList;
        //Insert 10 account records
        List<Account> accts = ClsTestDataFactory.createAccountsWithBillingAddress(10, 'DE Consumer', 'Germany');
        //Insert 5 Medical Facility record
        List<Account> medFacAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Medical Facility', 'Germany');
        //Insert 5 Prescriber record
        List<Account> prescriberAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Prescriber', 'Germany');
        List<Account> accntsToBeUpdated = new List<Account>();
        Test.startTest();
        Account accntWithMedFac = accts[0];
        accntWithMedFac.Medical_Facility__c = medFacAccts[0].Id;
        accntsToBeUpdated.add(accntWithMedFac);
        Account accntWithMedPrescriber = accts[1];
        accntWithMedPrescriber.Prescriber__c = prescriberAccts[0].Id;
        accntsToBeUpdated.add(accntWithMedPrescriber);
        Account accntWithChangedZip = accts[2];
        accntWithChangedZip.ShippingPostalCode = '61168';
        accntsToBeUpdated.add(accntWithChangedZip);
        //Insert User
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'DE Salesforce Admin'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'DE Inside Sales'];
        User usr = ClsTestDataFactory.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
        try
        {
            insert usr;
        }
        Catch(DMLException e){}
        //Insert custom setting
        Country_Admin__c countryAdminSetting = new Country_Admin__c();
        countryAdminSetting.Name='DE';
        countryAdminSetting.User_Id__c = usr.Id;
        insert countryAdminSetting;
        Update accntsToBeUpdated;
        Test.stopTest();
    }
    @isTest Static void testAccountMerge() {
        // Insert new accounts
        List<Account> ls = new List<Account>{
            new Account(name='Acme Inc.'),
                new Account(name='Acme')
                };                                        
        insert ls;
        
        // Queries to get the inserted accounts 
        Account masterAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        Account mergeAcct = [SELECT Id, Name FROM Account WHERE Name = 'Acme' LIMIT 1];
        
        // Add a contact to the account to be merged
        Contact c = new Contact(FirstName='Joe',LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        test.startTest();
        try {
            merge masterAcct mergeAcct;
        } catch (DmlException e) {
            // Process exception
            System.debug('An unexpected error has occurred: ' + e.getMessage()); 
        }
        test.stopTest();
        // Once the account is merged with the master account,
        // the related contact should be moved to the master record.
        masterAcct = [SELECT Id, Name, (SELECT FirstName,LastName From Contacts) 
                      FROM Account WHERE Name = 'Acme Inc.' LIMIT 1];
        System.assert(masterAcct.getSObjects('Contacts').size() > 0);
        System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
        System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        
        // Verify that the merge record got deleted
        Account[] result = [SELECT Id, Name FROM Account WHERE Id=:mergeAcct.Id];
        System.assertEquals(0, result.size());
    }
}