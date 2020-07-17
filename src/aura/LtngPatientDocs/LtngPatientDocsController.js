({
    doInit : function(component, event, helper) {
        var PDocId = component.get("v.PdocRecordId");
        var accRecId = component.get("v.accountId");
        var opptRecId = component.get("v.oppId");
        helper.getCFPicklist(component,event);
        helper.getStatusPicklist(component,event);
        helper.getCLFRMPicklist(component,event);
        if( PDocId != null ){
            component.set("v.isEditMode",true);
            var action = component.get("c.fetchPatientRec");
            action.setParams({ Pdoc : PDocId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var patientDoc =  response.getReturnValue();
                    component.find("dc_Type").set("v.value",patientDoc.Doc_Type__c);
                    component.find("dc_status").set("v.value",patientDoc.Status__c);
                    component.find("dc_cf").set("v.value",patientDoc.Collect_From__c);
                    component.find("dc_Sndt").set("v.value",patientDoc.Sent_Date__c);
                    component.find("dc_rdt").set("v.value",patientDoc.Received_Date__c);
                    
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) { 
                                console.log("Error message: " + 
                                            errors[0].message);
                                //alert(errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
            
        }else if(PDocId == null ){
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            component.set("v.today", today);
            component.find("dc_Type").set("v.value",'--None--');
            component.find("dc_status").set("v.value",'Sent');
            component.find("dc_cf").set("v.value",'--None--');
            component.find("dc_Sndt").set("v.value",component.get("v.today"));
            component.find("dc_rdt").set("v.value",null);
            component.set("v.acctRecId",accRecId);
            
        }
        
    },
    submitCCFormData : function (component, event, helper) {
        $A.enqueueAction(component.get('c.handleSubmitCCFormData'));
    },
    handleSubmitCCFormData : function(component, event, helper) {
        var isEdit = component.get("v.isEditMode");
        var recCFData = component.get("v.recCF");
        var PDocId = component.get("v.PdocRecordId");
        var isValidRec = true;
        var toastErrorMsg = '';
       
        var doctype = component.get("v.docType");
        
        if(doctype == '--None--' || doctype == ''){
           toastErrorMsg = 'Select Doc Type';
            isValidRec = false;
        }else{
            recCFData.Doc_Type__c = component.get("v.docType");
        } 
        var status =  component.get("v.docst");
        //alert(status);
        if(status == '--None--' || status == ''){
           toastErrorMsg = 'Select Status';
            isValidRec = false;
        }else{
             recCFData.Status__c = component.get("v.docst");
        } 
        var collectfrom = component.get("v.docColtfrm");
        if(collectfrom == '--None--' || collectfrom == ''){
            if(!isEdit){
                toastErrorMsg = 'Select Collect from';
                isValidRec = false;
            }else{
               recCFData.Collect_From__c = ''; 
            }
            
        }else{
            recCFData.Collect_From__c =  component.get("v.docColtfrm");
        }
        
        var  sendDate= component.find("dc_Sndt").get("v.value");
        var receivedDate = component.find("dc_rdt").get("v.value");
        //alert(sendDate+'--'+receivedDate);
        if(receivedDate < sendDate){
            isValidRec = false ;
            toastErrorMsg = 'Document Received Date must be greater than Send Date';
        }else if(($A.util.isUndefined(sendDate) || sendDate == null) && receivedDate != null){
            isValidRec = false ;
            toastErrorMsg = 'Document Received Date must be greater than Send Date';
        }else{
            recCFData.Sent_Date__c = sendDate;
            recCFData.Received_Date__c = receivedDate;

        }
        
        if(isValidRec){
            var accRecId = component.get("v.accountId");
            recCFData.Account__c = accRecId;
            var recordId = component.get("v.oppId");
            var action = '';
            if(isEdit){
                //alert('Edit  Record');
                action = component.get("c.updatePatientDocs"); 
                action.setParams({ "recCF" : recCFData,
                                  "PDocRecId" : PDocId });
            }else{
                //alert('New Record');
                action = component.get("c.savePatientDocs"); 
                action.setParams({ "recCF" : recCFData,
                                  "oppId" : recordId });
            }
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastMessage = '';
                    if(isEdit){
                        toastMessage='Document updated Succesfully'; 
                    }else{
                        toastMessage='Document Created Succesfully';
                    }
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": toastMessage
                    });
                    resultsToast.fire();
                    
                    var myEvent = component.getEvent("myRefreshTable");
                    myEvent.setParams({"param": "Patient Document"});
                    myEvent.fire();
                    
                    var myEvent = component.getEvent("CloseModal");
                    myEvent.setParams({"param": "CMP_PatientDoc"});
                    myEvent.fire();
                    
                    
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }  
            });
            $A.enqueueAction(action);
        }else{
            helper.showToastErr(component,event,toastErrorMsg);
        }
    }
    
})