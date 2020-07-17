trigger TrgOrderEventV11 on CRM_Order_Event_V1__e (after insert) {
    system.debug('*****Total records to process ' + trigger.new.size());
    Integer counter = 0;//Counter to count the number of records
    List<CRM_Order_Event_V1__e> batchEventsList = new List<CRM_Order_Event_V1__e>();//Temp list, which holds data in 200 count    
    for(CRM_Order_Event_V1__e ev: trigger.new) {
        counter++;
        // Resume after the last successfully processed event message after the trigger stops running. Exit for loop.
        if (counter > 200){ 
            break;
        }
        else
        {
            batchEventsList.add(ev);
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(ev.ReplayId);
        }
    }
    system.debug('*****Counter is ' + counter + ' -- Entering the class PEClsHandleOrderEvents_V11 for processing the batch');
    if(!batchEventsList.isEmpty()) PEClsHandleOrderEvents_V11.onAfterInsert(batchEventsList);// Many item status updates are coming in one go and failing. This Batch process is supposed to handle them.
}