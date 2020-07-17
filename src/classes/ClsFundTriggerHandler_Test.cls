@isTest()
private class ClsFundTriggerHandler_Test {
    @isTest private static void test(){
        Account payorAccount = ClsTestDataFactory.createAccountsWithBillingAddress(1, 'DE Payor', 'Germany')[0];
        Fund__c fund = new Fund__c(Payor__c = payorAccount.Id, Amount_Limit__c = 100000, Auth_End_Date__c = Date.today().addDays(100), Auth_Start_Date__c = Date.today(), 
                                   Receiver_Qty_Limit__c = 100, Sensor_Limit__c = 100, Transmitter_Qty_Limit__c = 100);
      	insert fund;
    }
}