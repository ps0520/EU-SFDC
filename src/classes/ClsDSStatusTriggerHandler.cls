public class ClsDSStatusTriggerHandler {
	
    public Static void onafterUpdate(List<dfsle__EnvelopeStatus__c> lstenvelopeStatus,Map<String,String> mapTempleteNames){
       List<Task> lstTaskToInsert = new List<Task>();
       List<Opportunity> lstOpp = new List<Opportunity>();
        Map<String,String> mapOppOwnerId = new Map<String,String>();
        Set<Id> SetoppId = new Set<Id>();
        for(dfsle__EnvelopeStatus__c envlpStatus: lstenvelopeStatus){
            SetoppId.add(envlpStatus.Opportunity__c);
        }
        
       
        if(mapTempleteNames.size()>0){
              System.debug('**mapTempleteNames--'+mapTempleteNames.KeySet());  
        lstOpp = [Select id,OwnerId from opportunity where id IN:SetoppId ];
        Id recordTypeId =Schema.SObjectType.Task.getRecordTypeInfosByName().get('CA Task').getRecordTypeId();
        for(Opportunity op:lstOpp)mapOppOwnerId.put(op.Id, op.OwnerId);
        
        for(dfsle__EnvelopeStatus__c envlpStatus: lstenvelopeStatus){
            String emailSubject = envlpStatus.dfsle__EmailSubject__c;
            if(emailSubject.Contains('-')){
                emailSubject = emailSubject.substringBefore('-');
            }
            if(emailSubject.Contains('.pdf')){
                emailSubject = emailSubject.substringBefore('.pdf');   
            }
            Task tsk = new Task();
            if(mapTempleteNames.ContainsKey(emailSubject)){
                tsk.Subject = ' DocuSign '+mapTempleteNames.get(emailSubject)+' completed – please review';
                tsk.Description = 'A docusign '+mapTempleteNames.get(emailSubject)+' document has been completed. Please review the document and update the Account/Opportunity record.';
            }
            tsk.RecordTypeId = recordTypeId;
            tsk.Product_Discussed__c = 'G6';
            tsk.Type = 'Other';
            tsk.Status = 'Open';
            tsk.ActivityDate = System.today();
            tsk.Priority = 'Normal';
            tsk.WhatId = envlpStatus.Opportunity__c;
            tsk.OwnerId = mapOppOwnerId.get(envlpStatus.Opportunity__c);
            lstTaskToInsert.add(tsk);
        }
        if(lstTaskToInsert.size()>0){
          insert lstTaskToInsert;  
        }
        }
        
    }
}