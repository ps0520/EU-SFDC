public class ClsFundTriggerHandler {
    public void onBeforeInsert(List<Fund__c> lstFund){
        Set<Id> setAccountId = new Set<Id>();
        for(Fund__c fund : lstFund) setAccountId.add(fund.Payor__c);
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN: setAccountId]);
        for(Fund__c fund : lstFund){
            String recordTypeDName = mapAccount.get(fund.Payor__c).RecordType.DeveloperName;
        	String currencyCode = recordTypeDName.startsWithIgnoreCase('CA_') ? 'CAD' : recordTypeDName.startsWithIgnoreCase('CH_') ? 'CHF' : 
            					  recordTypeDName.startsWithIgnoreCase('GB_') ? 'GBP' : recordTypeDName.startsWithIgnoreCase('IE_') ? 'EUR' : 
            					  recordTypeDName.startsWithIgnoreCase('INTL_') ? 'USD' : 'EUR';
            if(String.isNotBlank(currencyCode) && String.isNotEmpty(currencyCode)) fund.CurrencyIsoCode = currencyCode;
        }
    }
}