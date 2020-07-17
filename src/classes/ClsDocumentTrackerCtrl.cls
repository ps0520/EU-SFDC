/*******************************************************************************************
@Author        : Pravin jagadale
@Date Created  : 06/25/2020
@Description   : Covers Dcoument Tracker functionality
*********************************************************************************************/
public class ClsDocumentTrackerCtrl {
    
    @AuraEnabled
    public static List<PDoc_To_Opportunity__c> fetchRequiredDoc(String oppRecId){
        
        List<PDoc_To_Opportunity__c> lst = [Select id,Opportunity__c ,Patient_Document__r.Doc_type__c,
                                             Patient_Document__r.Status__c,
                                             Patient_Document__r.Received_Date__c,
                                             Patient_Document__r.Collect_From__c,
                                             Patient_Document__r.Sent_Date__c,
                                             Patient_Document__r.Account__c
                                             from PDoc_To_Opportunity__c
                                             where Opportunity__c =:oppRecId];
        
        
        
        return lst;
        
    }
    
    @AuraEnabled
    public static Boolean opportunityStageCheck(String oppRecId){
        
        boolean addDocsVisible = false;
        Opportunity opp = [Select id,Stagename from Opportunity
                          where Id=:oppRecId];
        if(opp.StageName == 'New Opportunity' || opp.StageName == 'Customer Doc Collection' ){
            addDocsVisible = true;
        }
        
        return addDocsVisible;
    }
    
    @AuraEnabled
    public static List<PDoc_To_Opportunity__c> deletePdocToOpppRec(String PdocId,String OpprecId){
        System.debug('***PdocId--'+PdocId);
        PDoc_To_Opportunity__c pdocObj = [Select id,Opportunity__c ,Patient_Document__r.Id
                                          from PDoc_To_Opportunity__c
                                          where Patient_Document__r.Id =:PdocId AND Opportunity__c=:OpprecId ];
        delete pdocObj;
        
        //Opportunity Stage Update if all docs status is received
        List<String> lstStr = new List<String>();            
        List<PDoc_To_Opportunity__c> lst = fetchRequiredDoc(OpprecId);
        
       /* List<PDoc_To_Opportunity__c> lst = [Select id,Opportunity__c ,Patient_Document__r.Doc_type__c,
                                             Patient_Document__r.Status__c,
                                             Patient_Document__r.Received_Date__c,
                                             Patient_Document__r.Collect_From__c,
                                             Patient_Document__r.Sent_Date__c,
                                             Patient_Document__r.Account__c
                                             from PDoc_To_Opportunity__c
                                             where Opportunity__c =:oppRecId];*/
        if(lst.size()>0){
            for(PDoc_To_Opportunity__c pdc:  lst){
                if(pdc.Patient_Document__r.Status__c == 'Received'){
                    lstStr.add(pdc.Patient_Document__r.Status__c);
                }
            }
            Opportunity opp = new Opportunity();
            if(lst.size() == lstStr.size()){                
                opp.Id = OpprecId;
                opp.CA_Customer_Docs_Collection_Status__c = 'All Docs Received';
                opp.CA_Prescriber_Docs_Collection_Status__c = 'Docs Received';
            }else{
                opp.Id = OpprecId;
                opp.CA_Customer_Docs_Collection_Status__c = 'Pending';
                opp.CA_Prescriber_Docs_Collection_Status__c = 'Pending';
            }
            update opp;
        }
        
        return lst;
        
        //return null;
        
    }
    
    @AuraEnabled
    public static Patient_Document__c fetchPatientRec(String Pdoc){
        
        Patient_Document__c pdocObj =[SELECT Id, Doc_Type__c, Status__c, Collect_From__c, 
                                      Sent_Date__c, Received_Date__c, Account__c
                                      FROM Patient_Document__c where Id=:Pdoc];
        return pdocObj;
        
    }
	 @AuraEnabled    
    public Static void savePatientDocs(Patient_Document__c recCF,String oppId){
        try{
            String recFd ='';
            insert recCF;  
            
            PDoc_To_Opportunity__c pdOpp = new PDoc_To_Opportunity__c();            
            pdOpp.Patient_Document__c = recCF.Id; 
            pdOpp.Opportunity__c = oppId;
            insert pdOpp;
            
            //Opportunity Stage Update if all docs status is received
            List<String> lstStr = new List<String>();            
            List<PDoc_To_Opportunity__c> lst = fetchRequiredDoc(oppId);
            if(lst.size()>0){
                for(PDoc_To_Opportunity__c pdc:  lst){
                    if(pdc.Patient_Document__r.Status__c == 'Received'){
                        lstStr.add(pdc.Patient_Document__r.Status__c);
                    }
                }
                Opportunity opp = new Opportunity();
                if(lst.size() == lstStr.size()){                
                    opp.Id = oppId;
                    opp.CA_Customer_Docs_Collection_Status__c = 'All Docs Received';
                    opp.CA_Prescriber_Docs_Collection_Status__c = 'Docs Received';
                }else{
                    opp.Id = oppId;
                    opp.CA_Customer_Docs_Collection_Status__c = 'Pending';
                    opp.CA_Prescriber_Docs_Collection_Status__c = 'Pending';
                }
                update opp;
            }
            System.debug('Insertion Successful--'+recCF.Id);
        }catch(Exception ex){
           System.debug('**Insert Error at Line -'+ ex.getLineNumber()); 
            System.debug('**Insert Error -'+ ex); 
        }
    }    
    
    @AuraEnabled
    public static void updatePatientDocs(Patient_Document__c recCF,String PDocRecId){
        try{
            recCF.Id=  Id.valueOf(PDocRecId);
            update recCF;
            List<PDoc_To_Opportunity__c> lstPdOp = [Select Patient_Document__c,Opportunity__c 
                                                    from PDoc_To_Opportunity__c
                                                    where Patient_Document__c=:PDocRecId];
            String OppId = lstPdOp[0].Opportunity__c;
            //Opportunity Stage Update if all docs status is received
            List<String> lstStr = new List<String>();            
            List<PDoc_To_Opportunity__c> lst = fetchRequiredDoc(OppId);
            if(lst.size()>0){
                for(PDoc_To_Opportunity__c pdc:  lst){
                    if(pdc.Patient_Document__r.Status__c == 'Received'){
                        lstStr.add(pdc.Patient_Document__r.Status__c);
                    }
                }
                Opportunity opp = new Opportunity();
                if(lst.size() == lstStr.size()){                
                    opp.Id = oppId;
                    opp.CA_Customer_Docs_Collection_Status__c = 'All Docs Received';
                    opp.CA_Prescriber_Docs_Collection_Status__c = 'Docs Received';
                }else{
                    opp.Id = oppId;
                    opp.CA_Customer_Docs_Collection_Status__c = 'Pending';
                    opp.CA_Prescriber_Docs_Collection_Status__c = 'Pending';
                }
                update opp;
            }
            System.debug('Update Succesful--'+recCF.Id);
        }catch(Exception ex){
           System.debug('Update Error at Line -'+ ex.getLineNumber());
        }
    }
       
    @AuraEnabled    
    public Static Map<String,String> getDocTypePicklist(){
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Patient_Document__c.Doc_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }
    @AuraEnabled    
    public Static Map<String,String> getDocStatusPicklist(){
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Patient_Document__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }
    @AuraEnabled    
    public Static Map<String,String> getCLFPicklist(){
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Patient_Document__c.Collect_From__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(),p.getLabel());
        }
        return options;
    }
}