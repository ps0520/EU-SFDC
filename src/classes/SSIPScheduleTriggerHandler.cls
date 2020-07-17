public class SSIPScheduleTriggerHandler {
    public void onAfterUpdate(List<SSIP_Schedule__c> lstSSIPScheduleNew, Map<Id, SSIP_Schedule__c> mapScheduleOld){
        List<SSIP_Schedule__c> lstSSIPSchedule = new List<SSIP_Schedule__c>();
        List<SSIP_Schedule__c> lstSSIPScheduleFilter = new List<SSIP_Schedule__c>();
        Set<Id> setSSIPRuleIds = new Set<Id>();
        for(SSIP_Schedule__c ssipSchedule : lstSSIPScheduleNew){
            if(ssipSchedule.Status__c == 'In Progress' && ssipSchedule.Status__c != mapScheduleOld.get(ssipSchedule.Id).Status__c){
            	setSSIPRuleIds.add(ssipSchedule.SSIP_Rule__c);
                lstSSIPScheduleFilter.add(ssipSchedule);
            }
        }
        Map<Id, SSIP_Rule__c> mapRule = new Map<Id, SSIP_Rule__c>([SELECT Id, Rule_End_Date__c, CurrencyIsoCode, Frequency_In_Days__c, Payment_Term__c, Shipping_Address__c, Shipping_Method__c, (SELECT Id, Schedule_Date__c FROM SSIP_Schedule__r ORDER BY Schedule_Date__c DESC LIMIT 1) FROM SSIP_Rule__c WHERE Id IN: setSSIPRuleIds]);
        for(SSIP_Schedule__c ssipSchedule : lstSSIPScheduleFilter){
            if(mapRule.containsKey(ssipSchedule.SSIP_Rule__c) && mapRule.get(ssipSchedule.SSIP_Rule__c).Frequency_In_Days__c != null){
                SSIP_Rule__c rule = mapRule.get(ssipSchedule.SSIP_Rule__c);
                Date scheduleDate = rule.SSIP_Schedule__r.size() > 0 ? rule.SSIP_Schedule__r[0].Schedule_Date__c.addDays(Integer.valueOf(rule.Frequency_In_Days__c)) : Date.today().addDays(Integer.valueOf(rule.Frequency_In_Days__c));
                if(rule.Rule_End_Date__c == null || scheduleDate <= rule.Rule_End_Date__c){
                    lstSSIPSchedule.add(new SSIP_Schedule__c(Account__c = ssipSchedule.Account__c, CurrencyIsoCode = rule.CurrencyIsoCode, Country__c = ssipSchedule.Country__c, Payment_Term__c = rule.Payment_Term__c,
                                                             Shipping_Address__c = rule.Shipping_Address__c, Shipping_Method__c = rule.Shipping_Method__c, 
                                                             SSIP_Rule__c = ssipSchedule.SSIP_Rule__c, Status__c = 'Open', Fund__c = ssipSchedule.Fund__c, Schedule_Date__c = scheduleDate));
                }
            }
        }
        if(lstSSIPSchedule.size()>0){
            insert lstSSIPSchedule;
        }
        
    }
}