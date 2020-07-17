/*
@Author        : Kumar Navneet
@Date Created    : 20/03/2020
@Description    : Batch class for Email Invoice Automation
****************************************************************************************/
global class BClsSendSdocDist implements Database.Batchable<Sobject> {    
    private List<SDOC__SDJob__c> jobList = new List<SDOC__SDJob__c> {};
    private Map<String, String> mapETemId = new Map<String, String>(); 
    private String country;
    
    global BClsSendSdocDist(String country){ 
        this.country = country;
        //Get all the invoice templates that are required for processing
         country = 'Distributor';
        String recordTypeName = String.isNotBlank(country) && String.isNotEmpty(country) ? country + '%' : '';
        String templateQuery = 'Select Id, Name from SDOC__SDTemplate__c Where SDOC__Document_Category__c = \'Invoice\'';
        templateQuery+= String.isNotBlank(recordTypeName) && String.isNotEmpty(recordTypeName) ? (' AND Recordtype.Name LIKE \'' + recordTypeName + '\'') : '';
        system.debug('Template Query is ' + templateQuery);
        for(SDOC__SDTemplate__c Sd : Database.query(templateQuery)){
            this.mapETemId.put(Sd.Name, Sd.Id);
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //If there is no country filter then query for all Orders that are to be processed for Email Invoicing
        country = 'DIST';
        String orderType = String.isNotBlank(country) && String.isNotEmpty(country) ? country + '%' : '';
        String query = 'SELECT Id, Warehouse__c FROM Order ';
               query+= ' where ID =  \'8011n00000EibbLAAR\'' ;                  
             //  query+= ' AND Email_Invoice_Opt_In__c = true';
             //  query+= String.isNotBlank(orderType) && String.isNotEmpty(orderType) ? (' AND Type LIKE \'' + orderType + '\'') : '';
        system.debug('Start Query is' + query);                
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> scope){ 
        for(Order objOrder : scope){   
            if(objOrder.Warehouse__c != null && objOrder.Warehouse__c != ''){ 
            String strHTMLTemplateId;
            String strDOCTemplateId ;
                if(objOrder.Warehouse__c.startsWithIgnoreCase('SD'))
            {
               // strHTMLTemplateId =  mapETemId.get('Distributor - APAC SOA');
            }else
            {
               // strHTMLTemplateId =  mapETemId.get('Distributor - EMEA SOA');   
            }
                strHTMLTemplateId =  mapETemId.get('Distributor - HTML');
                strDOCTemplateId =  mapETemId.get('Distributor - EMEA SOA');
                system.debug('strHTMLTemplateId=' + strHTMLTemplateId); 
                system.debug('strDOCTemplateId=' + strDOCTemplateId); 
             List<String> lstTemplateIds = new List<String>();     
            if(String.isNotEmpty(strDOCTemplateId) && String.isNotBlank(strDOCTemplateId)) lstTemplateIds.add(strDOCTemplateId);
            if(String.isNotEmpty(strHTMLTemplateId) && String.isNotBlank(strHTMLTemplateId)) lstTemplateIds.add(strHTMLTemplateId);
            if(!lstTemplateIds.isEmpty()){                
                jobList.add(new SDOC__SDJob__c(SDOC__Start__c = true,  SDOC__Oid__c = objOrder.Id, SDOC__ObjApiName__c = 'Order', SDOC__SendEmail__c = '1', SDOC__Doclist__c = String.join(lstTemplateIds, ','))); 
            }     
        }  
    }
        system.debug('jobList=' + jobList);
        if(!jobList.isEmpty())insert jobList;
        update scope;
    }
    global void finish(Database.BatchableContext BC){
        system.debug('Order Finish: ');    }
}