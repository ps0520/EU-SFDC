public class ClsPdocHandler {
    
    public static Boolean runOnce = true;    
    public static void afterPdocOpportunityInsert(List<PDoc_To_Opportunity__c> lstPdocOpportunity){
        System.debug('***Inside Handler***'+lstPdocOpportunity.size());
        if(ClsPdocHandler.runOnce){
            ClsPdocHandler.runOnce = false;
            boolean runTrigger = false;
            Set<Id> setPatientDoc = new Set<Id>();
            Set<Id> setOpportunity = new Set<Id>();
            Set<Id> setOpptToProcess = new Set<Id>();
            for(PDoc_To_Opportunity__c pdocOpprtunity :  lstPdocOpportunity){
                setPatientDoc.add(pdocOpprtunity.Patient_Document__c);
                setOpportunity.add(pdocOpprtunity.Opportunity__c);
            }
            
            //Check Opportunity StageName -- if stagename is New Opportunity then update the opportunity
            if(setOpportunity.size()>0){             
                for(Opportunity opp : [Select id,StageName from opportunity where id IN:setOpportunity]){
                    if(opp.StageName == 'New Opportunity'){
                         setOpptToProcess.add(opp.Id);
                    }
                }
            }
            
            System.debug('***setPatientDoc***'+setPatientDoc);
            List<Patient_Document__c> lstPatientInfo = new List<Patient_Document__c>();
            lstPatientInfo = [SELECT Id, Doc_Type__c,Account__c, Status__c, Collect_From__c, Sent_Date__c, Received_Date__c 
                              FROM Patient_Document__c
                              where Id IN:setPatientDoc];
            
            Set<Id> setPayor = new Set<Id>();
            System.debug('**lstPatientInfo**'+lstPatientInfo.size());
            Map<String,List<Patient_Document__c>> mapPdocInfo = new Map<String,List<Patient_Document__c>>();
            for(Patient_Document__c pdc : lstPatientInfo){
                String strKey = pdc.id+'-'+pdc.Account__c;
                if(mapPdocInfo.Containskey(strKey)){
                    List<Patient_Document__c> lst = mapPdocInfo.get(strKey);
                    lst.add(pdc);
                    mapPdocInfo.put(strKey,lst);
                }else{
                    List<Patient_Document__c> newLst = new List<Patient_Document__c>();
                    newLst.add(pdc);
                    mapPdocInfo.put(strKey,newLst);
                }
            }
            System.debug('**mapPdocInfo**'+mapPdocInfo.values());
            Map<String,PDoc_To_Opportunity__c> mapPDocOp = new Map<String,PDoc_To_Opportunity__c>();
            Map<String,Opportunity> mapOpportunityUpdate = new Map<String,Opportunity>();
            //Map<String,Opportunity> mapOpportunityUpdateV2 = new Map<String,Opportunity>();
            Map<String,String> mapUpdateOpp = new Map<String,String>();
            Set<Id> setOppId = new Set<Id>();
            Integer statusnullCounter = 0;
            //Integer statusnotnullCounter = 0;
            List<Opportunity> lstupdateOp = new List<Opportunity>();
            List<PDoc_To_Opportunity__c> lstPdcOp = [Select id,Patient_Document__c,Patient_Document__r.Account__r.Id,Opportunity__c from PDoc_To_Opportunity__c 
                                                     where Patient_Document__c IN:setPatientDoc and Opportunity__c IN:setOpptToProcess];
            System.debug('**lstPdcOp--'+lstPdcOp.size());
            if(lstPdcOp.size()>0){
                for(PDoc_To_Opportunity__c pdOp :  lstPdcOp){ 
                    String pdocKey = pdOp.Patient_Document__c+'-'+pdOp.Patient_Document__r.Account__r.Id;
                    if(mapPdocInfo.containsKey(pdocKey)){
                        for(Patient_Document__c pdc :mapPdocInfo.get(pdocKey)){
                            if(pdc.Status__c == null){
                                if(!mapOpportunityUpdate.Containskey(pdOp.Opportunity__c)){
                                    System.debug('**Null Status of Pdoc');
                                    Opportunity oppUpdate = new Opportunity();
                                    oppUpdate.Id = pdOp.Opportunity__c;
                                    oppUpdate.CA_Customer_Docs_Collection_Status__c = 'Not Started';
                                    oppUpdate.CA_Prescriber_Docs_Collection_Status__c = 'Not Started';
                                    mapOpportunityUpdate.put(pdOp.Opportunity__c,oppUpdate);
                                }
                            }else{
                                //if(mapOpportunityUpdate.Containskey(pdOp.Opportunity__c)) continue;
                                Opportunity oppUpdate = new Opportunity();
                                oppUpdate.Id = pdOp.Opportunity__c;
                                oppUpdate.CA_Customer_Docs_Collection_Status__c = 'Pending';
                                oppUpdate.CA_Prescriber_Docs_Collection_Status__c = 'Pending';
                                mapOpportunityUpdate.put(pdOp.Opportunity__c,oppUpdate);
                            }    
                        }
                    } 
                }
            }
            
            if(mapOpportunityUpdate.size()>0){
                System.debug('##mapOpportunityUpdate--'+mapOpportunityUpdate.size());
                update mapOpportunityUpdate.values();
            }
        }
        
    }
}