public class PEClsHandleAttachmentEvents {
    public static void handleIncomingEvents(List<CRM_Attachment_Event__e> attachmentList) {
        List<ContentVersion> ListNewDocs = new List<ContentVersion>();
        Set<String> SetOrdNums = new Set<String>();
        Set<String> SetDocNames = new Set<String>();
       	Map<String, ContentVersion> MapExistingDocs = new Map<String, ContentVersion>();
        Map<String, Id> MapExistingOrders = new Map<String, Id>();
        List<Platform_Event_Error_Log__c> ListPlatErrLog = new List<Platform_Event_Error_Log__c>();
        List<ContentDocumentLink> ListOrdUpdate = new List<ContentDocumentLink>();
        Map<String, String> MapDocToOrder = new Map<String, String>();
        for(CRM_Attachment_Event__e att : attachmentList) {
            SetOrdNums.add(att.referenceNumberValue__c);
            SetDocNames.add(att.name__c);
            MapDocToOrder.put(att.name__c, att.referenceNumberValue__c);
        }
        for(ContentVersion existingDoc : [Select Id, ContentDocumentId, Description, CreatedDate from ContentVersion where Description in :SetDocNames])
            MapExistingDocs.put(existingDoc.Description, existingDoc);
        for(Order ord : [Select Id, OrderNumber from Order where OrderNumber in :SetOrdNums])
            MapExistingOrders.put(ord.OrderNumber, ord.Id);
        
        for(CRM_Attachment_Event__e att : attachmentList) {
            if (!MapExistingOrders.containsKey(att.referenceNumberValue__c)) {
                ListPlatErrLog.add(ErrorUtility.prepareErroLog('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Order listed in Attachment not found', 'attachment', att.eventSource__c, 'Order Number: ' + att.referenceNumberValue__c + ' not found.', att.eventSourceID__c, 'Informational', ''));
				continue;
            }
            if (MapExistingDocs.containsKey(att.name__c)) {
                ListPlatErrLog.add(ErrorUtility.prepareErroLog('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Duplicate Document Received', 'attachment', att.eventSource__c, 'Atacchment was already received on ' + MapExistingDocs.get(att.name__c).CreatedDate, att.eventSourceID__c, 'Informational', ''));
				continue;
            }
            // Call here @Future Method
            loadContentFile(att.referenceNumberValue__c, att.content__c, att.name__c, att.eventSource__c, att.eventSourceID__c, MapExistingOrders.get( att.referenceNumberValue__c));
            /*
            ContentVersion doc = new ContentVersion();
            doc.ContentLocation = 'S';
            doc.PathOnClient = att.referenceNumberValue__c + '.pdf';
            doc.Title = att.referenceNumberValue__c;
            Blob blobContent = testGoogleStorageDocRead.displaydoc(att.content__c.subString(4));
            if (blobContent == null) {
                blobContent = testGoogleStorageDocRead.displaydoc(att.content__c.subString(4)); //sometimes first call just gets the access code. Hence call again.
                //if it is still null, push the event back to queue for handling later on
                if (blobContent == null && EventBus.TriggerContext.currentContext().retries < 5) {
                    // Condition isn't met, so try again later.
                    throw new EventBus.RetryableException('Error happened, so retrying the trigger again.');
                } else {
                    //ErrorUtility.LogErrorWithEvent(action, classNMethodName, errorMsg, eventType, eventSource, exceptionError, externalID, severity, event)
                    ErrorUtility.LogErrorWithEvent('Consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error in Consuming Attachment Create Operations.', 'Attachment', att.eventSource__c, 
                         'Could not get access to the content and exceeded retry attempts.' , att.eventSourceID__c, 'Informational', String.valueOf(att));
                    continue;
                }
            }
            doc.VersionData = blobContent;
            doc.Description = att.name__c;
        	ListNewDocs.add(doc);
			*/
        }
        /*
        Set<Id> ListInsertedFileIds = new set<id>();
        if (ListNewDocs.size() > 0) {
            Database.SaveResult[] ListDsr = Database.Insert(ListNewDocs, False);
            Integer i = 0;
            String ErrorString = '';
            for(Database.SaveResult dsr : ListDsr) {
                if (dsr.isSuccess()) { 
                    ListInsertedFileIds.add(dsr.getId());
                } else {
                    ErrorString = '';
                    for(Database.Error err : dsr.getErrors()) ErrorString += err + '; ';
                    ListPlatErrLog.add(ErrorUtility.prepareErroLog('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error adding a document', 'attachment', 'crm', ErrorString, '', 'Informational', ''));
                }
            }
        }
        If (ListInsertedFileIds.size() > 0) {
            List<ContentVersion> ListInsertedFiles = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id in :ListInsertedFileIds];
            for(ContentVersion cv : ListInsertedFiles) {
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = MapExistingOrders.get(cv.Title);
                conDocLink.ContentDocumentId = cv.ContentDocumentId;
                conDocLink.shareType = 'V';
                ListOrdUpdate.add(conDocLink);
            }
        }
        if (ListOrdUpdate.size() > 0) {
            Database.SaveResult[] ListDsr = Database.insert(ListOrdUpdate, False);
            Integer i = 0;
            String ErrorString = '';
            for(Database.SaveResult dsr : ListDsr) {
                if (!dsr.isSuccess()) {
                    ErrorString = '';
                    for(Database.Error err : dsr.getErrors()) ErrorString += err + '; ';
                    ListPlatErrLog.add(ErrorUtility.prepareErroLog('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error adding a document', 'attachment', 'crm', ErrorString, '', 'Informational', ''));
                }
            }
        }
		*/
    }
    @Future (callout=true)
    public static void loadContentFile(String referenceNumberValue, String content, String name, String eventSource, String eventSourceID, Id orderId) {
        List<ContentVersion> ListNewDocs = new List<ContentVersion>();
        List<ContentDocumentLink> ListOrdUpdate = new List<ContentDocumentLink>();
        ContentVersion doc = new ContentVersion();
        doc.ContentLocation = 'S';
        doc.PathOnClient = referenceNumberValue + '.pdf';
        doc.Title = referenceNumberValue;
        Blob blobContent = testGoogleStorageDocRead.displaydoc(content.subString(4));
        if (blobContent == null) {
            blobContent = testGoogleStorageDocRead.displaydoc(content.subString(4)); //sometimes first call just gets the access code. Hence call again.
            //if it is still null, push the event back to queue for handling later on
            if (blobContent == null) {
                //ErrorUtility.LogErrorWithEvent(action, classNMethodName, errorMsg, eventType, eventSource, exceptionError, externalID, severity, event)
                ErrorUtility.LogError('Consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error in Consuming Attachment Create Operations.', 'Attachment', eventSource, 
                                      'Could not get access to the content - Bailing out.' , eventSourceID, 'Informational') ;
                return;
            }
        }
        doc.VersionData = blobContent;
        doc.Description = name;
        ListNewDocs.add(doc);
        Set<Id> ListInsertedFileIds = new set<id>();
        if (ListNewDocs.size() > 0) {
            Database.SaveResult[] ListDsr = Database.Insert(ListNewDocs, False);
            Integer i = 0;
            String ErrorString = '';
            for(Database.SaveResult dsr : ListDsr) {
                if (dsr.isSuccess()) { 
                    ListInsertedFileIds.add(dsr.getId());
                } else {
                    ErrorString = '';
                    for(Database.Error err : dsr.getErrors()) ErrorString += err + '; ';
                    ErrorUtility.LogError('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error adding a document', 'attachment', 'crm', ErrorString, '', 'Informational');
                }
            }
        }
        If (ListInsertedFileIds.size() > 0) {
            List<ContentVersion> ListInsertedFiles = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id in :ListInsertedFileIds];
            for(ContentVersion cv : ListInsertedFiles) {
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = orderId;
                conDocLink.ContentDocumentId = cv.ContentDocumentId;
                conDocLink.shareType = 'V';
                ListOrdUpdate.add(conDocLink);
            }
        }
        if (ListOrdUpdate.size() > 0) {
            Database.SaveResult[] ListDsr = Database.insert(ListOrdUpdate, False);
            Integer i = 0;
            String ErrorString = '';
            for(Database.SaveResult dsr : ListDsr) {
                if (!dsr.isSuccess()) {
                    ErrorString = '';
                    for(Database.Error err : dsr.getErrors()) ErrorString += err + '; ';
                    ErrorUtility.LogError('consume', 'PEClsHandleAttachmentEvents.handleIncomingEvents', 'Error adding a document', 'attachment', 'crm', ErrorString, '', 'Informational');
                }
            }
        }
    }
}