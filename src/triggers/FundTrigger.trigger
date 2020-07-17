trigger FundTrigger on Fund__c (before insert) {
	
    if(Trigger.isInsert && Trigger.isBefore){
        new ClsFundTriggerHandler().onBeforeInsert(Trigger.new);
    }
}