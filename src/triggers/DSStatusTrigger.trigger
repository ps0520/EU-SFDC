/* Function: When VAT exempt document is completed by a customer, sets field Account.Tax Exempt to true.
*/
trigger DSStatusTrigger on dfsle__EnvelopeStatus__c (after Update) {
     if(trigger.isAfter && trigger.isUpdate){
         List<DocuSign_Templates__mdt> lstDocuSignmdt = new List<DocuSign_Templates__mdt>();
         Map<String,String> mapTempleteNames = new Map<String,String>();
         lstDocuSignmdt = [SELECT Id,Template_Name__c, email_subject__c,Record_type__c
                           FROM DocuSign_Templates__mdt where Record_type__c='CA_Opportunity'];
         System.debug('**lstDocuSignmdt--'+lstDocuSignmdt.size());
         if(lstDocuSignmdt.size()>0){
             for(DocuSign_Templates__mdt mdt: lstDocuSignmdt){
                 String emailSubject = mdt.Email_Subject__c;
                 if(emailSubject.Contains('-')){
                     emailSubject = emailSubject.substringBefore('-');
                 }
                 if(emailSubject.Contains('.pdf')){
                     emailSubject = emailSubject.substringBefore('.pdf');   
                 }
                 mapTempleteNames.put(emailSubject,mdt.Template_Name__c);
             }
         }
         // --
         List<dfsle__EnvelopeStatus__c>  lstenvelopStatus = new List<dfsle__EnvelopeStatus__c>();
         List<Account> lstAccUpd= new List<Account>();
         for(dfsle__EnvelopeStatus__c newStatus: trigger.new){
             dfsle__EnvelopeStatus__c oldStatus=trigger.oldMap.get(newStatus.Id);
             if(newStatus.dfsle__Status__c != oldStatus.dfsle__Status__c && newStatus.dfsle__Status__c=='Completed'){
                 String emailSubject = newStatus.dfsle__EmailSubject__c;
                 if(emailSubject.Contains('-')){
                     emailSubject = emailSubject.substringBefore('-');
                 }
                 if(emailSubject.Contains('.pdf')){
                     emailSubject = emailSubject.substringBefore('.pdf');   
                 }
                 if(mapTempleteNames.ContainsKey(emailSubject)){
                     lstenvelopStatus.add(newStatus);
                 }
                 
                 if(newStatus.dfsle__SourceId__c != null){
                     if(newStatus.dfsle__EmailSubject__c.contains('VAT') && newStatus.dfsle__EmailSubject__c.contains('Exemption')){
                         if(newStatus.dfsle__SourceId__c.startsWith('001')){
                         	Account a = new Account(Id=newStatus.dfsle__SourceId__c, Tax_Exempt__c=true); 
                         	lstAccUpd.Add(a);    
                         }  
                     }
                 }
             }
         }
         
         if(!lstAccUpd.isEmpty()){
             Database.Update(lstAccUpd);
         }
         if(lstenvelopStatus.size()>0){
            ClsDSStatusTriggerHandler.onafterUpdate(lstenvelopStatus,mapTempleteNames);
         }
     }
}