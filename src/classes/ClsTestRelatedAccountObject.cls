/********************************************************************************
@Author        : Jagan Periyakaruppan
@Date Created    : 08/12/2017
@Description    : Test class to test the scenarios involved in Related Account object
*********************************************************************************/
@isTest
private class ClsTestRelatedAccountObject {
    @isTest static void TestRelatedAccount(){
        ClsAccountAddressTriggerStaticClass.medFacChangedInvokedFromRelatedAccount = TRUE;
        ClsAccountAddressTriggerStaticClass.medFacChangedInvokedFromPrescriber = FALSE;
        //Insert 5 Prescriber record
        List<Account> prescriberAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Prescriber', 'Germany');
        //Insert 5 Medical Facility record
        List<Account> medFacAccts = ClsTestDataFactory.createAccountsWithBillingAddress(5, 'DE Medical Facility', 'Germany');
        Test.startTest();
            //Associate a Medical Facility to a Prescriber using Related Account
            List<Related_Account__c> relAccountsToBeInserted = new List<Related_Account__c>();
            List<Related_Account__c> relAccountsToBeUpdated = new List<Related_Account__c>();
            Related_Account__c relAccount = new Related_Account__c();
            relAccount.Parent_Account__c = medFacAccts[0].Id;
            relAccount.Child_Account__c = prescriberAccts[0].Id;
            relAccount.Primary_Flag__c = TRUE;
            relAccount.Preferred_Email__c='test@gmail.com';
            relAccountsToBeInserted.add(relAccount);
            
            Related_Account__c relAccount1 = new Related_Account__c();
            relAccount1.Parent_Account__c = medFacAccts[1].Id;
            relAccount1.Child_Account__c = prescriberAccts[1].Id;
            relAccount1.Preferred_Email__c='test1@gmail.com';           
            relAccountsToBeInserted.add(relAccount1);
            
            Related_Account__c relAccount2 = new Related_Account__c();
            relAccount2.Parent_Account__c = medFacAccts[2].Id;
            relAccount2.Child_Account__c = prescriberAccts[1].Id;           
            relAccount2.Primary_Flag__c = TRUE;
            relAccount2.Preferred_Email__c='test2@gmail.com';
            relAccountsToBeInserted.add(relAccount2);
            
            
            
            insert relAccountsToBeInserted;
            //Test the duplicate logic where we cannot have the same Med Fac to Prescriber combintation
            Related_Account__c relAccount3 = new Related_Account__c();
            relAccount3.Parent_Account__c = medFacAccts[0].Id;
            relAccount3.Child_Account__c = prescriberAccts[0].Id;
            relAccount3.Preferred_Email__c='test3@gmail.com';
            try{
                insert relAccount3;
            }
            catch(Exception e){}
            //Change the primary association
            /*Related_Account__c relAccountToBeUpdated = [SELECT Id FROM Related_Account__c WHERE Parent_Account__c = :medFacAccts[1].Id AND Child_Account__c = :prescriberAccts[1].Id];
            relAccountToBeUpdated.Primary_Flag__c = TRUE;*/
            
            relAccount1.Parent_Account__c = medFacAccts[3].Id;
            relAccount1.Primary_Flag__c = TRUE; 
            //update relAccount1;    
              
            
             List<Id> ids =new List<id>();
             List<Related_Account__c> idsEmpty=new List<Related_Account__c>();
             idsEmpty.add(relAccount3);
            for(Related_Account__c rc:relAccountsToBeInserted){
              ids.add(rc.id);
            }
            system.debug('->>ids'+ids);
           
             ClsRelatedAccountTriggerHandlerHelper.GetPrimaryRelatedAccountsTiedToAccount(ids,idsEmpty,'Medical Facility','Prescriber');  
                 
        Test.stopTest();
    }  
     @isTest static void testAccountHelper(){
      
     
    } 
}