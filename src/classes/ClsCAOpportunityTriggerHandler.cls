public class ClsCAOpportunityTriggerHandler {
    
    //This method will be called in Before Insert context. The purpose is not to allow insertion on Opportunities on Accounts that have non-Closed Opportunitites.
    public static void doNotAllowMultipleOpenOpps(List<Opportunity> newOppsList) {
        set<ID> newOpsAccIds = new Set<Id>();
        for (Opportunity o : newOppsList) newOpsAccIds.add(o.AccountId);
        List<Opportunity> otherOpenOpps = [Select Id, AccountId from Opportunity where AccountId in :newOpsAccIds AND StageName Not in ('Closed - Complete', 'Cancelled')];
        if (otherOpenOpps.size() < 1) return; // No duplicate Open opps exist.
        Map<Id, Opportunity> existOpps = new Map<Id, Opportunity>();
        for(Opportunity o : otherOpenOpps) existOpps.put(o.AccountId, o);
        for(Opportunity o : newOppsList) {
            if (existOpps.containsKey(o.AccountId)) o.addError('An Open Opportunity with Id: ' + existOpps.get(o.AccountId).Id + ' already exists. Can\'t create a new one.');
        }
    } 
    //Calling the following method in Before Insert or Before Update Trigger Context. It's to Copy the Payor's Name based on the Benefit Payor. 
    public static void setBenfitAndPayor(List<Opportunity> newOppsList) {
        //If there is no Benefit associated with the Opportunity, copy the Primary Beneficiary to the new Opportunity
        if (Trigger.isInsert ) {
            Set<Id> noBenAccountIds = new Set<Id>();
            for (Opportunity o : newOppsList) if (o.Benefit__c == null && o.Parent_Opportunity__c == null ) noBenAccountIds.add(o.AccountId);
            if (noBenAccountIds.size() > 0) {
            	List<Benefit__c> primeBenefits = [Select Id, Account__c from Benefit__c where Account__c in :noBenAccountIds AND Benefit_Hierarchy__c = 'Primary' AND Inactive__c = false];
                Map<Id, Benefit__c> benefitMap = new Map<Id, Benefit__c>();
                for (Benefit__c b : primeBenefits) benefitMap.put(b.Account__c, b);
                for(Opportunity o : newOppsList) {
                    if (o.Benefit__c == null && o.Parent_Opportunity__c == null && benefitMap.containsKey(o.AccountId)) o.Benefit__c = benefitMap.get(o.AccountId).Id;
                }
            }
        }
        Set<ID> benefitIds = new Set<Id>();
        for(Opportunity o : newOppsList) if (o.Benefit__c != null) benefitIds.add(o.Benefit__c);           
		if (benefitIds.size() < 1) return;
        List<Benefit__c> benefitRecs = [Select Id, Payor__c from Benefit__c where id in :benefitIds];
        Map<Id, Benefit__c> benefitMap = new Map<Id, Benefit__c>();
        benefitMap.putAll(benefitRecs);
        for(Opportunity o : newOppsList) {
            if (o.Benefit__c != null) o.Payor__c = benefitMap.get(o.Benefit__c).Payor__c;
        }
    }
    
    //The following method will be called in after Update context. It's purpose is to create a new opportunity after 'Cancelling' an existing Opportunity.
    public static void createNewOpportunity(List<Opportunity> newOppsList, Map<id, Opportunity> oldOppMap) {
        Opportunity oldOpp = new Opportunity();
        Opportunity newOpp = new Opportunity();
        List<Opportunity> newOpps = new List<Opportunity>();
        Set<Id> oppAccIds = new Set<id>();
        for (Opportunity o: newOppsList) oppAccIds.add(o.AccountId);
        List<Account> accountInfo = [Select Id, Name, Territory__c from Account where id in :oppAccIds];
        Map<Id, Account> accountInfoMap = new Map<Id, Account>();
        accountInfoMap.putAll(accountInfo);
        Set<Id> OppsExist = findExistingOpps(newOppsList);
        for(Opportunity o : newOppsList) {
            oldOpp = oldOppMap.get(o.Id);
            if (oldOpp.Create_New_Opportunity__c == false && o.Create_New_Opportunity__c == true && o.StageName == 'Cancelled' && 
                	(oppsExist.size() == 0 || (oppsExist.size()>0 && !oppsExist.contains(o.AccountId)))) {
                   newOpp = new Opportunity();
                		newOpp.Parent_Opportunity__c = o.Id;
                        newOpp.AccountId = o.AccountId;
                        newOpp.CA_Docs_Received__c = o.CA_Docs_Received__c;
                        newOpp.CA_Docs_Sent_Out__c = o.CA_Docs_Sent_Out__c;
                        newOpp.Competitor__c = o.Competitor__c;
                        newOpp.Cash_Pay__c  = o.Cash_Pay__c;
                        newOpp.Medical_Facility__c = o.Medical_Facility__c;
                        newOpp.CurrencyIsoCode = o.CurrencyIsoCode;
                        //newOpp.Name = o.AccountId + String.valueOf(Date.today());
                        newOpp.Name = accountInfoMap.get(o.AccountId).Name + ' - ' + accountInfoMap.get(o.AccountId).Territory__c + ' - ' + String.valueOf(Date.today().month()) + '/' + 
                            String.valueOf(Date.today().day()) + '/' + String.valueOf(Date.today().year());
                        newOpp.OwnerId = o.OwnerId;
                        newOpp.Prescriber__c = o.Prescriber__c;
                       //  system.debug('o.Country__c='+o.Country__c);
                        newOpp.Country__c = o.Country__c;
                        newOpp.Type = o.Type;
                        newOpp.CloseDate = Date.today() + 30;
                        newOpp.RecordTypeId = o.RecordTypeId;
                        newOpp.StageName = 'New Opportunity';
                   newOpps.add(newOpp); 
            }	
        }
        if (newOpps.size() > 0) {
            //try{
                insert newOpps;
            //} catch(DmlException de) {
            //    system.debug('Error in creating New Opportunity after cancelling an earlier one. Error: ' + de.getMessage());
           // }
        } 
    }
    private static Set<Id> findExistingOpps(List<Opportunity> newOppsList) {
        Set<Id> accsWithOpenOpps = new Set<Id>();
        //To do
        set<ID> newOpsAccIds = new Set<Id>();
        for (Opportunity o : newOppsList) newOpsAccIds.add(o.AccountId);
        List<Opportunity> otherOpenOpps = [Select Id, AccountId from Opportunity where AccountId in :newOpsAccIds AND StageName Not in ('Closed - Complete', 'Cancelled')];
        if (otherOpenOpps.size() < 1) return accsWithOpenOpps;
        for(Opportunity o : otherOpenOpps) accsWithOpenOpps.add(o.AccountId);
        return accsWithOpenOpps;
    }
    // Method called from ClsOpportunityBPHandler to Update the MedFac & Prescriber on Account if an Opportunity is Closed for Canada. Vijay Adusumilli Sept 5, 2019
    public static void updAccountMedFacPrescriber(List<Opportunity> updAccountOps) {
        set<Id> acIds = new Set<Id>();
        for(Opportunity opp : updAccountOps) acIds.add(opp.AccountId);
        Map<Id, Account> acctToVerifyMap = new Map<Id, Account> ([Select Id, Medical_Facility__c, Prescriber__c from Account where Id in :acIds]);
        List<Account> updAccList = new List<Account>();
        for(Opportunity op : updAccountOps) {
            Account updAcc = new Account(id=op.AccountId);
            if (op.Medical_Facility__c != null && acctToVerifyMap.get(op.AccountId).Medical_Facility__c != op.Medical_Facility__c) updAcc.Medical_Facility__c = op.Medical_Facility__c;
            if (op.Prescriber__c != null && acctToVerifyMap.get(op.AccountId).Prescriber__c != op.Prescriber__c) updAcc.Prescriber__c = op.Prescriber__c;
            updAccList.add(updAcc);
        }
        Update updAccList;
    }
}