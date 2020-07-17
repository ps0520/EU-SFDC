@isTest()
public class BclsMarketingInteractionGBIETest {
@isTest
    static void testHourlyEmailScheduledJob() {
        //insert TestDataBuilder.testURLExpiryVal();

        List<Account> accountList= new List<Account>();
        Date tenDate= date.today().adddays(10);
        Account testAccount = TestUtils.testGBConsumerAccount();
        testAccount.PersonEmail='jane.smith@sundog.net';
        testAccount.Email_Opt_In_Method__c = 'Via Email';
        
            
        insert testAccount;
        
        Product2 p = new product2();
        P.Name ='MTRNTG612MOS';
        insert p;
        
        SSIP_Rule__c ssip = new SSIP_Rule__c();
        ssip.Account__c=testAccount.Id;
        ssip.Renewal_Date__c=tenDate;
        ssip.product__c=p.id;
        ssip.Status__c='Active';
        insert ssip;
        
        Test.startTest();
        String jobId = System.schedule('testScheduled', '0 0 0 3 9 ? 2052', new SclsMarketingInteractionGBIEScheduled());
        
        BclsMarketingInteractionGBIEBatch sbatch = new BclsMarketingInteractionGBIEBatch();
        Id batchInstanceId = Database.executeBatch(sbatch, 1);
        
        Test.stopTest();
        
        List<marketing_interaction__c> m= [SELECT id, Account__c FROM marketing_interaction__c WHERE account__c = :testAccount.Id 
                                           AND Communication_Type__c='UKIE - Subscription Renewal - G6'];
        
        System.assertEquals(1, m.size());
        
    }
        
        
}