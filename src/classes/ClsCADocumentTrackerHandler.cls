public class ClsCADocumentTrackerHandler {
    
    public static void afterOpportunityInsert(Map<Id, Opportunity> newOpps){
        
        try{
            System.Debug('**afterOpportunityInsert'+newOpps);
            String docsRequired = '';
            List<String> lstDocTypeReq = new List<String>();
            Map<String,Patient_Document__c> mapPatientDocs = new Map<String,Patient_Document__c>();
            List<Patient_Document__c> lstPatientDocs = new List<Patient_Document__c>();
            Map<String, Pdoc_To_Opportunity__c> oppLinkMap = new Map<String, Pdoc_To_Opportunity__c>();
            Map<String,Opportunity> mapOpportunityUpdate = new Map<String,Opportunity>();
            Set<String> reqdDocsSet = new Set<String>();
            List<String> lststrCheck = new List<String>();
            List<Opportunity> lstNewOpporunity = [Select id,Payor__c,AccountId from opportunity where id IN:newOpps.keySet()]; 
            System.debug('**lstNewOpporunity'+lstNewOpporunity);
            Map<String,List<String>> mapPdc = new Map<String,List<String>>();
            if(lstNewOpporunity.size()<200){
                for(Opportunity opp : lstNewOpporunity){
                    
                    List<Account> lstPayor = [Select id,CA_Docs_Required__c from Account where id = :opp.Payor__c];
                    System.debug('**lstPayor'+lstPayor);
                    for(Account objAcc : lstPayor){
                        docsRequired = '';
                        docsRequired = String.valueOf(objAcc.CA_Docs_Required__c);
                        System.debug('**docsRequired'+docsRequired);
                        lstDocTypeReq = docsRequired.split(';');
                        System.debug('**lstDocTypeReq'+lstDocTypeReq);
                        reqdDocsSet.clear();
                        for(String docKey : lstDocTypeReq){
                            reqdDocsSet.add(docKey);
                        }
                    }
                    
                    for(Patient_Document__c Pdc :[Select id,Account__c,Account__r.Id,Doc_Type__c,Status__c from Patient_Document__c where Account__c = :opp.AccountId and Doc_Type__c in :reqdDocsSet order by LastModifiedDate]){
                        mapPatientDocs.put(pdc.Doc_Type__c,Pdc);
                    }
                    
                    System.Debug('##mapPatientDocs'+mapPatientDocs.KeySet());
                    
                    for(String doc : reqdDocsSet) {
                        if (mapPatientDocs.containsKey(doc)){
                            System.debug('**containsKey--'+doc);
                            oppLinkMap.put(doc, new PDoc_To_Opportunity__c (Patient_Document__c = mapPatientDocs.get(doc).Id, Opportunity__c = opp.Id));                   
                           
                        }else{
                            System.debug('**New--'+doc);
                            lstPatientDocs.add(new Patient_Document__c(Account__c = opp.AccountId, Doc_Type__c = doc, Collect_From__c = '', Status__c = 'Not Sent', Sent_Date__c = null, Received_Date__c = null));
                        }
                    }
                    if (lstPatientDocs.size() > 0) {
                        insert lstPatientDocs;
                        System.Debug('##lstPatientDocs-->'+lstPatientDocs);
                        
                        for(Patient_Document__c pdoc : lstPatientDocs) {
                            
                            oppLinkMap.put(pdoc.Doc_Type__c, new PDoc_To_Opportunity__c (Patient_Document__c = pdoc.Id, Opportunity__c = opp.Id));                    
                        }
                    }
                }
                System.debug('**oppLinkMap'+oppLinkMap);
                if (oppLinkMap.size() > 0) insert oppLinkMap.values();
                List<Patient_Document__c> lstPdc = new List<Patient_Document__c>();
                for(String docKey : oppLinkMap.keySet()){
                    lstPdc.add(mapPatientDocs.get(docKey));
                }
                if(lstPdc.size()>0){
                    for(Patient_Document__c pd: lstPdc){
                        if(pd.Status__c == 'Received'){
                            lststrCheck.add(pd.Status__c);
                        }
                    }
                }
                System.debug('##OPpLink'+oppLinkMap.size()+'##lststrCheck--'+lststrCheck.size());
                if(oppLinkMap.size() == lststrCheck.size()){
                    for(String str : oppLinkMap.KeySet()){
                        PDoc_To_Opportunity__c p = oppLinkMap.get(str);
                        if(!mapOpportunityUpdate.containsKey(p.Opportunity__c)){
                            Opportunity oppUpdate = new Opportunity();
                            oppUpdate.Id = p.Opportunity__c;
                            oppUpdate.CA_Customer_Docs_Collection_Status__c = 'All Docs Received';
                            oppUpdate.CA_Prescriber_Docs_Collection_Status__c = 'Docs Received';
                            mapOpportunityUpdate.put(p.Opportunity__c,oppUpdate);
                        }
                    }
                }
                if(mapOpportunityUpdate.size()>0) update mapOpportunityUpdate.values();
                
            }else{
                //As per Vijay info we are inserting single doc through component screen
            }
        }catch(Exception ex){
            System.Debug('**afterOpportunityInsert Error at Line-->'+ex.getLineNumber());
            System.Debug('**afterOpportunityInsert Error-->'+ex.getMessage());
        }
        
    }
    
    public static void afterOpportunityUpdate(Map<Id, Opportunity> newOppsMap, Map<Id, Opportunity> oldOppsMap){
        
        try{
            System.debug('***afterOpportunityUpdate');
            // Ask Vijay IS ther any chances where bulk opportunity is Updated??
            List<Patient_Document__c> lstPatientDoc = new List<Patient_Document__c>();
            List<PDoc_To_Opportunity__c> lstPtDocOppTodel = new List<PDoc_To_Opportunity__c>();
            Map<Id, Opportunity> newOppsPyor = new Map<Id, Opportunity>();
            Set<Id> setPatientDocs = new Set<Id>();
            for(PDoc_To_Opportunity__c pdcObj : [SELECT Id, Opportunity__c, Patient_Document__c FROM PDoc_To_Opportunity__c where Opportunity__c IN :newOppsMap.keySet()]){
                System.debug('***New---'+newOppsMap.get(pdcObj.Opportunity__c).Payor__c );
                System.debug('***Old---'+oldOppsMap.get(pdcObj.Opportunity__c).Payor__c);
                if(newOppsMap.get(pdcObj.Opportunity__c).Payor__c != oldOppsMap.get(pdcObj.Opportunity__c).Payor__c){
                    lstPtDocOppTodel.add(pdcObj);
                    newOppsPyor.put(pdcObj.Opportunity__c,newOppsMap.get(pdcObj.Opportunity__c));
                }    
            }
            System.debug('***lstPtDocOppTodel---'+lstPtDocOppTodel);
            System.debug('***newOppsPyor---'+newOppsPyor);
            if(lstPtDocOppTodel.size()>0){
                System.debug('***lstPtDocOppTodel---'+lstPtDocOppTodel);
                delete lstPtDocOppTodel;
                
            }
            
            if(newOppsPyor.size()>0){
                afterOpportunityInsert(newOppsPyor);
            }
        }catch(Exception ex){
            System.Debug('**afterOpportunityUpdate Error at Line-->'+ex.getLineNumber());
            System.Debug('**afterOpportunityUpdate Error-->'+ex.getMessage());
        }
        
        
    }
}