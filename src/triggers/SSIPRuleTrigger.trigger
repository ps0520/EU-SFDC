trigger SSIPRuleTrigger on SSIP_Rule__c (before insert, after insert, after update) {
    
    if(trigger.isBefore && trigger.isInsert){ 
        new SSIPRuleTriggerHandler().onBeforeInsert(trigger.new);
    }else if(trigger.isAfter && trigger.isInsert){
        new SSIPRuleTriggerHandler().onAfterInsert(trigger.new);
    }else if(trigger.isAfter && trigger.isUpdate){
        new SSIPRuleTriggerHandler().onAfterUpdate(trigger.new, trigger.oldMap);
    }
}