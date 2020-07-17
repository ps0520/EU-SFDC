public class ClsJobUpdateAccountsWithFund implements Queueable {
    private List<Account_Fund__c> lstAF= new List<Account_Fund__c>();
    public ClsJobUpdateAccountsWithFund(List<Account_Fund__c> lst) {
        this.lstAF= lst;       
    }
    public void execute(QueueableContext context) {
        if(!lstAF.isEmpty()){
            set<Id> setAccId= new set<Id>(); set<Id> setAFId= new set<Id>();
            for(Account_Fund__c sf:lstAF){
            		
                if(sf.Primary_Flag__c){
                    setAccId.Add(sf.Account__c);
                    setAFId.Add(sf.Fund__c);
                }
            }
            Map<Id, Account_Fund__c> mapAF= new Map<Id, Account_Fund__c>([Select Id, Fund__c, Fund__r.Payor__c,Account__c, Account__r.Fund__c, 
                Account__r.Payor__c From Account_Fund__c Where ID IN :setAFId]);
            List<Account> lstAccUpd= new List<Account>();
            for(Account_Fund__c af : mapAF.values()){
            	Account a = new Account(Id=af.Account__c, Fund__c=af.Fund__c, Payor__c=af.Fund__r.Payor__c);
                lstAccUpd.Add(a);
            }
            
            if(lstAccUpd.size()>0){
            	update lstAccUpd;    
        	}
        }
    }
}