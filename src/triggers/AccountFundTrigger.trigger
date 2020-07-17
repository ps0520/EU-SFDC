trigger AccountFundTrigger on Account_Fund__c (after insert, after update) {

if(Trigger.isInsert){
    if(Trigger.isAfter) new ClsAccountFundTriggerHandler().onAfterInsert(Trigger.new); 
}

if(Trigger.isUpdate){
    if(Trigger.isAfter) new ClsAccountFundTriggerHandler().onAfterUpdate(Trigger.new, Trigger.oldMap);
}

}