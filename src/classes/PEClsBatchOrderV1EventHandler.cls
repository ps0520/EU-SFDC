global class PEClsBatchOrderV1EventHandler implements Database.batchable<Sobject>, Database.AllowsCallouts {
    
    //PEClsBatchOrderV1EventHandler replaced with PEBatchCANOrderEvent
	private static final String version = '3.1';  // version of the canonical
    private static final Map<String, String> mapRecordTypeNameToID;
    private static final Map<String, String> mapAddressRecordTypeNameToID;
    private static final Map<String, String> mapCountry;
    private static final Map<String, String> mapState;
    private static final Map<String, Order_Event_Setting__mdt> mapOrderEventSetting;
    private static final Map<String, String> mapTimeZone;
    private List<CRM_Order_Event__e> lstOrderEvent;
    private static final Map<String, List<OrderLineItem>> mapOrderToOrderItems;
    private static final Map<String, Order> mapDuplicateOrder;
    private static final Map<String, String> mapPriceBook;
    public static final Map<String, String> mapOrderTypeENUM;
    private static final Map<String, Finance_Detail__c> mapFinanceDetail;
    //private static final Map<String, CRM_Order_Event__e> mapOrderEvent;
    private static final Map<String, CRM_Order_Event__e> mapOrderEventCreate;
    private static final Map<String, CRM_Order_Event__e> mapOrderEventUpdate;
    static{
        System.debug('Static Block Start----');
        mapCountry = PEClsBatchOrderV1EventHandler.getPicklistValues('Account', 'ShippingCountryCode');
        mapState = PEClsBatchOrderV1EventHandler.getPicklistValues('Account', 'ShippingStateCode');
        mapFinanceDetail = new Map<String, Finance_Detail__c>();
        mapOrderToOrderItems = new Map<String, List<OrderLineItem>>();
        mapDuplicateOrder = new Map<String, Order>();
        mapPriceBook = new Map<String, String>();
        mapRecordTypeNameToID = new Map<String, String>();
        mapAddressRecordTypeNameToID = new Map<String, String>();
        mapOrderTypeENUM = new Map<String, String>();
        mapOrderEventSetting = new Map<String, Order_Event_Setting__mdt>();
        //mapOrderEvent = new Map<String, CRM_Order_Event__e>();
        mapOrderEventCreate = new Map<String, CRM_Order_Event__e>();
        mapOrderEventUpdate = new Map<String, CRM_Order_Event__e>();
        for(Schema.RecordTypeInfo rtInfo : Schema.SObjectType.Order.getRecordTypeInfosByName().values()){
            mapRecordTypeNameToID.put(rtInfo.getName().toLowerCase(), rtInfo.getRecordTypeId());
        }
        for(Schema.RecordTypeInfo rtInfo : Schema.SObjectType.Address__c.getRecordTypeInfosByName().values()){
            mapAddressRecordTypeNameToID.put(rtInfo.getDeveloperName().toLowerCase(), rtInfo.getRecordTypeId());
        }
        for(Order_Event_Setting__mdt oEventSetting : [SELECT Id, Label, DeveloperName, MasterLabel, SFDC_ORDER_TYPE__c, SFDC_RECORD_TYPE__c,
                                                      EBS_ORDER_TYPE__c, FUSION_ORDER_TYPE__c 
                                                      FROM Order_Event_Setting__mdt]){
            mapOrderEventSetting.put(oEventSetting.Label.toLowerCase(), oEventSetting);
            mapOrderTypeENUM.put(oEventSetting.SFDC_ORDER_TYPE__c.toUpperCase(), oEventSetting.DeveloperName);
        }
        System.debug('Static Block End----');
    }
  
    
    global PEClsBatchOrderV1EventHandler(List<CRM_Order_Event__e> lstOrderEvent){
        this.lstOrderEvent = lstOrderEvent;
    }
    global Iterable<Sobject> start(Database.BatchableContext BC){
        return new ObjectIterator(lstOrderEvent);
    }
    global void execute(Database.BatchableContext BC, List<CRM_Order_Event__e> lstOEvent){
        System.debug('Batch class Execution Start----');
        try{
         System.debug('execute Executed with Size----'+lstOEvent.size());
        CRM_Order_Event__e oEventObj = new CRM_Order_Event__e();
         Set<String> setProductId = new Set<String>();
         if(lstOEvent.size() == 0 || lstOEvent.size() > 1){
            /*ErrorUtility.LogError('Consume', 'PEBatchCANOrderEvent', 'Internal Salesforce Error.', 'order', 'crm', 'Batch Size is: ' + lstOEvent.size() + '. It should be 1.', 
                                  '','Fatal Error - Bailing out');*/
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.Execute', 'More then one Item found for processing', 'Order', oEventObj.eventSourceID__c,
                                           'Batch size must be 1 to process event '+oEventObj.eventSource__c, 
                                           oEventObj.eventSourceID__c, 'Fatal Error - Bailing out', String.valueOf(oEventObj));
             return;
         }else{
            oEventObj =  lstOEvent[0];
             System.debug('oEventObj----'+oEventObj);
            
         }
        String uniqueKey = oEventObj.systemOfOrigin__c != null && oEventObj.systemOfOriginID__c != null ? 
            			   oEventObj.systemOfOrigin__c.trim() + oEventObj.systemOfOriginID__c.trim() : '';
        
        if(oEventObj.Line_Items__c != null) {
            mapOrderToOrderItems.put(uniqueKey, (List<OrderLineItem>)JSON.deserialize(oEventObj.Line_Items__c, List<OrderLineItem>.class));
        }
        String priceBookId = null;          	
            
            if(oEventObj.stage__c == 'pending' && oEventObj.operation__c == 'create'){
                uniqueKey = oEventObj.systemOfOrigin__c.trim() + oEventObj.systemOfOriginID__c.trim();
                mapOrderEventCreate.put(uniqueKey, oEventObj);
                System.debug('***mapOrderEventCreate--'+mapOrderEventCreate);
            }
        Map<String, Account> mapAccount = new Map<String, Account>([SELECT Id, Name, RecordType.DeveloperName, Sync_Status__c 
                                                                     FROM Account WHERE Id =: oEventObj.accountID__c]);
        
        if(!mapAccount.containsKey(oEventObj.accountID__c)){
            ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler', 'Unknown Account', 'Order', oEventObj.eventSourceID__c,
                                           'Account Id not found in salesforce with Id: '+oEventObj.accountID__c, 
                                           oEventObj.eventSourceID__c, 'Fatal Error - Bailing out', String.valueOf(oEventObj));
            return;
        }
        
        Map<String, Address__c> mapAddress = new Map<String, Address__c>();
        for(Address__c objAddress : [SELECT Id, Oracle_Cust_Site_Id__c, Business_Name__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,
                                     City__c, Country__c, First_Name__c, Last_Name__c, Postal_Code__c, Primary_Phone__c, State__c, 
                                     SOS_Unique_ID__c, Type__c, Account__c, Inactive__c, IsLocked__c 
                                     FROM Address__c 
                                     WHERE (Id =: oEventObj.shippingAddressId__c 
                                         OR Id =: oEventObj.billingAddressId__c
                                         OR Oracle_Cust_Site_Id__c =: oEventObj.shippingAddressId__c 
                                         OR Oracle_Cust_Site_Id__c =: oEventObj.billingAddressId__c)
                                     AND Account__c IN: mapAccount.keySet()]){
                                         
                mapAddress.put(objAddress.Id, objAddress);
                if(objAddress.Oracle_Cust_Site_Id__c != null && objAddress.Account__c != null){
                	mapAddress.put(objAddress.Account__c +'_'+ objAddress.Oracle_Cust_Site_Id__c, objAddress);
                }
                if(objAddress.Oracle_Cust_Site_Id__c != null) {
                 	mapAddress.put(objAddress.Oracle_Cust_Site_Id__c, objAddress);
                }
        }
        
        Map<String, String> mapSKUProduct = new Map<String, String>();
        List<OrderLineItem> lstOrderItem = oEventObj.Line_Items__c != null ?(List<OrderLineItem>)JSON.deserialize(oEventObj.Line_Items__c, List<OrderLineItem>.class)
           								 : new List<OrderLineItem>();
        for(OrderLineItem oli : lstOrderItem){
            setProductId.add(oli.sku);
            if(oli.skuBundle != null && oli.skuBundle != 'null'){ 
                mapSKUProduct.put(oli.skuBundle, null); 
            }
        }
        List<Platform_Event_Error_Log__c> lstErrorLog = new List<Platform_Event_Error_Log__c>();
        Map<String, String> mapProductToPBE = new Map<String, String>(); 
        Map<String, Finance_Detail__c> mapFinanceDetail = new Map<String, Finance_Detail__c>();

        for(Product2 product : [SELECT Id, Name FROM Product2 WHERE Name IN: mapSKUProduct.keySet()]){
                mapSKUProduct.put(product.Name, product.Id);
        }
        for(Pricebook2 priceBook : [SELECT Id, Name FROM Pricebook2 WHERE Name =:oEventObj.pricebookName__c]){
            mapPriceBook.put(priceBook.Name, priceBook.Id);
        }
        for(PricebookEntry pbe : [SELECT Id, Product2.Name, Pricebook2Id, Pricebook2.Name FROM PricebookEntry 
                                  WHERE Product2.Name IN: setProductId AND Pricebook2Id IN: mapPriceBook.values()]) {
           priceBookId = pbe.Pricebook2Id;
           System.debug('**Key--'+pbe.Product2.Name +'_'+ pbe.Pricebook2Id);                           
           mapProductToPBE.put(pbe.Product2.Name +'_'+ pbe.Pricebook2Id, pbe.Id);
        }
        
        if (priceBookId == null) {
            PriceBook2 pb2 = [Select id from PriceBook2 where name =: oEventObj.pricebookName__c];
            priceBookId = pb2.Id;
        }
        
        for(Finance_Detail__c fd : [SELECT Id, Token__c, Expiry_Date__c FROM Finance_Detail__c 
                                    WHERE Token__c =: oEventObj.creditCardToken__c 
                                    AND Account__c IN: mapAccount.keySet()]){
                                        mapFinanceDetail.put(fd.Token__c, fd);
                                    }
        
        for(Order objOrder: [SELECT Id, SOS_Unique_ID__c FROM Order WHERE SOS_Unique_ID__c =: uniqueKey]){
            mapDuplicateOrder.put(objOrder.SOS_Unique_ID__c, objOrder);
        }
        
         List<User> lstUser = [SELECT Id, Name FROM User 
                               WHERE FirstName = 'Salesforce' 
                               AND LastName = 'Admin' 
                               AND Profile.Name 
                               LIKE 'System Administrator' 
                               LIMIT 1];
        String OwnerId =  lstUser.isEmpty() ? null : lstUser[0].Id; 
        
        String countryCode = oEventObj.shippingAddressCountryCode__c != null ? oEventObj.shippingAddressCountryCode__c.trim(): mapAccount.containsKey(oEventObj.accountID__c) ? mapAccount.get(oEventObj.accountID__c).RecordType.DeveloperName.substring(0,2) : '';
        String recordTypeName = Test.isRunningTest() ? 'de sales order' : oEventObj.orderType__c != null && mapOrderEventSetting.containsKey(oEventObj.orderType__c.toLowerCase()) && mapOrderEventSetting.get(oEventObj.orderType__c.toLowerCase()).SFDC_RECORD_TYPE__c != null ? mapOrderEventSetting.get(oEventObj.orderType__c.toLowerCase()).SFDC_RECORD_TYPE__c.toLowerCase() : '';
        String orderType = Test.isRunningTest() ? 'DE STANDARD' : oEventObj.orderType__c;
            
        PEClsBatchOrderV1EventHandler.createOrder(oEventObj, mapAccount, mapAddress, lstOrderItem, mapProductToPBE, mapSKUProduct,
                                                      mapFinanceDetail.size()>0 ? mapFinanceDetail.values() : null, OwnerId,
                                                       priceBookId, lstErrorLog);
        
        
       System.debug('Batch class Execution End----');
            
        }catch(Exception ex){
            System.debug('---Error In Execute @Line--'+ex.getLineNumber());
            System.debug('---Error In Execute @Message--'+ex.getMessage());
        } 
        
    }
    global void finish(Database.BatchableContext BC){ 
        System.debug('Batch Process Completed!!');
    }
    
    private static void createOrder(CRM_Order_Event__e oEvent, Map<String, Account> mapAccount, Map<String, Address__c> mapAddress, 
                                     List<OrderLineItem> lstOrderLineItem, Map<String, String> mapProductToPBE, Map<String, String> mapSKUProduct,
                                     Finance_Detail__c fd, String ownerId, String priceBookId, List<Platform_Event_Error_Log__c> lstErrorLog){
       System.debug('createOrder execution starts---'+mapSKUProduct);
        try{
        Map<String, Order> mapOrder = new Map<String, Order>();
        Map<String, Order> mapOrderNew = new Map<String, Order>();
        Map<String, List<OrderItem>> mapListOrderItem = new Map<String, List<OrderItem>>();
        Map<String, Finance_Detail__c> mapFinanceDetailToInsert = new Map<String,Finance_Detail__c>();
        Map<String, Address__c> mapAddressToInsert = new Map<String, Address__c>();
        Map<String, Address__c> mapAddressToUpsert = new Map<String, Address__c>();
        Map<String, CRM_Order_Event__e> mapOrderEventToErrorHandle = new Map<string, CRM_Order_Event__e>();
        Map<Id, Order> mapOrderToUpdate = new Map<Id, Order>();
        Set<String> setOrderId = new Set<String>();
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Map<String, Address__c> mapAddressToLocked = new Map<String, Address__c>();
        String uniqueKey = oEvent.systemOfOrigin__c.trim() + oEvent.systemOfOriginID__c.trim();
            //Calculate Order Amount as there is no direct field on Canonical that provides the value
            double orderValue = 0.0; // Vijay Adusumilli March 17, 2020
            for(OrderLineItem oi : mapOrderToOrderItems.get(uniqueKey)) orderValue += oi.price * oi.quantity;  // Vijay Adusumilli March 17, 2020
            if(orderValue != null && orderValue > 0.0 && (oEvent.creditCardAuthorizationCode__c == null || oEvent.creditCardAuthorizationCode__c == 'null' || oEvent.creditCardAuthorizationCode__c == '')){
                ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder',
                                               'AuthorizationCode is required for Order processing.', 'order',
                                               oEvent.eventSourceID__c, 'Order will not be processed without AuthorizationCode.',
                                               oEvent.eventSourceID__c, 'Informational', String.valueOf(oEvent));
                return;
            }
        String countryCode = oEvent.shippingAddressCountryCode__c != null ? oEvent.shippingAddressCountryCode__c.trim(): mapAccount.containsKey(oEvent.accountID__c) ? mapAccount.get(oEvent.accountID__c).RecordType.DeveloperName.substring(0,2) : '';
            String recordTypeName = Test.isRunningTest() ? 'de sales order' : oEvent.orderType__c != null && mapOrderEventSetting.containsKey(oEvent.orderType__c.toLowerCase()) && mapOrderEventSetting.get(oEvent.orderType__c.toLowerCase()).SFDC_RECORD_TYPE__c != null ? mapOrderEventSetting.get(oEvent.orderType__c.toLowerCase()).SFDC_RECORD_TYPE__c.toLowerCase() : '';
            String orderType = Test.isRunningTest() ? 'DE STANDARD' : oEvent.orderType__c;
           
            if(oEvent.eventSource__c.containsIgnoreCase('OMS') && (mapDuplicateOrder.containsKey(uniqueKey) || !mapAccount.containsKey(oEvent.accountID__c) || !mapPriceBook.containsKey(oEvent.pricebookName__c) || !mapRecordTypeNameToID.containsKey(recordTypeName) || ownerId == null)){
                String errorMsg = !mapAccount.containsKey(oEvent.accountID__c) ? 'Account Id is missing in Salesforce : '+ oEvent.accountID__c : '';
                errorMsg += String.isEmpty(errorMsg) && mapDuplicateOrder.containsKey(uniqueKey) ? 'Duplicate Order found in Salesforce with SF ID: ' +mapDuplicateOrder.get(uniqueKey).Id : String.isNotBlank(errorMsg) && mapDuplicateOrder.containsKey(uniqueKey) ?  ', Duplicate Order found in Salesforce with SF ID: ' +mapDuplicateOrder.get(uniqueKey).Id : '';
                errorMsg += String.isEmpty(errorMsg) && !mapPriceBook.containsKey(oEvent.pricebookName__c) ? 'PriceBook is not found in Salesforce with Name: ' +oEvent.pricebookName__c : String.isNotBlank(errorMsg) && !mapPriceBook.containsKey(oEvent.pricebookName__c) ? ', PriceBook is not found in Salesforce with Name: ' +oEvent.pricebookName__c : '';
                errorMsg += String.isEmpty(errorMsg) && !mapRecordTypeNameToID.containsKey(recordTypeName) ? 'RecordType is not found in Salesforce with Name: ' + recordTypeName : String.isNotBlank(errorMsg) && !mapRecordTypeNameToID.containsKey(recordTypeName) ? ', RecordType is not found in Salesforce with Name: ' + recordTypeName : '';
                errorMsg += String.isEmpty(errorMsg) && ownerId == null ? 'Could not get Salesforce Admin Id. Can\'t processing Create Operations' : ownerId == null ? 'Could not get Salesforce Admin Id. Can\'t processing Create Operations' : '';
               ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Incorrect data', 'order', 
                                              oEvent.eventSource__c , errorMsg, oEvent.eventSourceID__c , 'Informational', String.valueof(oEvent));
                return;    
                
            }else if(!oEvent.eventSource__c.containsIgnoreCase('OMS') && (mapDuplicateOrder.containsKey(uniqueKey) || !mapAccount.containsKey(oEvent.accountID__c) || !mapPriceBook.containsKey(oEvent.pricebookName__c) || !mapRecordTypeNameToID.containsKey(recordTypeName) 
                || (oEvent.billingAddressId__c != null && oEvent.billingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.billingAddressId__c)) || (oEvent.shippingAddressId__c != null && oEvent.shippingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.shippingAddressId__c)) || ownerId == null)){
                String errorMsg = !mapAccount.containsKey(oEvent.accountID__c) ? 'Account Id is missing in Salesforce : '+ oEvent.accountID__c : '';
                errorMsg += String.isEmpty(errorMsg) && mapDuplicateOrder.containsKey(uniqueKey) ? 'Duplicate Order found in Salesforce with SF ID: ' +mapDuplicateOrder.get(uniqueKey).Id : String.isNotBlank(errorMsg) && mapDuplicateOrder.containsKey(uniqueKey) ?  ', Duplicate Order found in Salesforce with SF ID: ' +mapDuplicateOrder.get(uniqueKey).Id : '';
                errorMsg += String.isEmpty(errorMsg) && !mapPriceBook.containsKey(oEvent.pricebookName__c) ? 'PriceBook is not found in Salesforce with Name: ' +oEvent.pricebookName__c : String.isNotBlank(errorMsg) && !mapPriceBook.containsKey(oEvent.pricebookName__c) ? ', PriceBook is not found in Salesforce with Name: ' +oEvent.pricebookName__c : '';
                errorMsg += String.isEmpty(errorMsg) && !mapRecordTypeNameToID.containsKey(recordTypeName) ? 'RecordType is not found in Salesforce with Name: ' + recordTypeName : String.isNotBlank(errorMsg) && !mapRecordTypeNameToID.containsKey(recordTypeName) ? ', RecordType is not found in Salesforce with Name: ' + recordTypeName : '';
                errorMsg += String.isEmpty(errorMsg) && oEvent.billingAddressId__c != null && oEvent.billingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.billingAddressId__c) ? 'Billing Address not found in salesforce with ID ' + oEvent.billingAddressId__c : oEvent.billingAddressId__c != null && oEvent.billingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.billingAddressId__c)? ', Biiling Address not found in salesforce with ID ' +oEvent.billingAddressId__c : '';
                errorMsg += String.isEmpty(errorMsg) && oEvent.shippingAddressId__c != null && oEvent.shippingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.shippingAddressId__c) ?   'Shipping Address not found in Salesforce with ID : ' + oEvent.shippingAddressId__c : oEvent.shippingAddressId__c != null && oEvent.shippingAddressId__c != 'null' && !mapAddress.containsKey(oEvent.shippingAddressId__c) ? ', Shipping Address not found in Salesforce with ID: ' + oEvent.shippingAddressId__c : '';
                errorMsg += String.isEmpty(errorMsg) && ownerId == null ? 'Could not get Salesforce Admin Id. Can\'t processing Create Operations' : ownerId == null ? 'Could not get Salesforce Admin Id. Can\'t processing Create Operations' : '';
                ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Incorrect data', 'order', 
                                              oEvent.eventSource__c , errorMsg, oEvent.eventSourceID__c , 'Informational', String.valueof(oEvent));
                    return;
            }
              mapListOrderItem.put(uniqueKey, new List<OrderItem>());                         
             for(OrderLineItem oli : mapOrderToOrderItems.get(uniqueKey)){
                String priceBookEntryKey = oli.sku+'_'+mapPriceBook.get(oEvent.pricebookName__c);
                 System.debug('***priceBookEntryKey---'+priceBookEntryKey);
                if(mapProductToPBE.containsKey(priceBookEntryKey)){
                    mapListOrderItem.get(uniqueKey).add(PEClsBatchOrderV1EventHandler.orderItemMapping(mapProductToPBE.get(priceBookEntryKey),oli, 
                                                                                                null, new OrderItem(), mapSKUProduct, oEvent.eventSource__c));
                }else{
                    ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder',  'Price Book Entry not found to create the Order Item for product : '
                                          + oli.sku, 'order',oEvent.eventSource__c ,'will not be processed', oEvent.eventSourceID__c , 'Informational', String.valueof(oEvent));
                    return;
               
                }
            }                            
           if(mapListOrderItem.get(uniqueKey).size() == mapOrderToOrderItems.get(uniqueKey).size()){
                String billingAddressID = null;
                String shippingAddressID = null;
               
                String addRecordTypeName = oEvent.shippingAddressCountryCode__c != null ? oEvent.shippingAddressCountryCode__c.trim().toLowerCase() +'_address' : mapAccount.containsKey(oEvent.accountID__c) ? mapAccount.get(oEvent.accountID__c).RecordType.DeveloperName.substring(0,1) +'_address':'';
                if(oEvent.eventSource__c.containsIgnoreCase('OMS')){
                    Boolean isBASalesforceId = oEvent.billingAddressId__c != null && Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(oEvent.billingAddressId__c).matches();
                    Boolean isSASalesforceId = oEvent.shippingAddressId__c != null && Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(oEvent.shippingAddressId__c).matches();
                    
                    billingAddressID = (isBASalesforceId && mapAddress.containsKey(oEvent.billingAddressId__c)) ? mapAddress.get(oEvent.billingAddressId__c).Id : (oEvent.billingAddressId__c != null && mapAddress.containsKey(oEvent.billingAddressAccountID__c+'_'+oEvent.billingAddressId__c)) ?  mapAddress.get(oEvent.billingAddressAccountID__c+'_'+oEvent.billingAddressId__c).Id : null;
                    shippingAddressID = (isSASalesforceId && mapAddress.containsKey(oEvent.shippingAddressId__c)) ? mapAddress.get(oEvent.shippingAddressId__c).Id : (oEvent.shippingAddressId__c != null && mapAddress.containsKey(oEvent.shippingAddressAccountID__c+'_'+oEvent.shippingAddressId__c)) ?  mapAddress.get(oEvent.shippingAddressAccountID__c+'_'+oEvent.shippingAddressId__c).Id : null;
                    
                    if(billingAddressID == null){
                        Address__c address = addressMapping(oEvent, null, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'BillTo');
                        address.Oracle_Cust_Site_Id__c = oEvent.billingAddressId__c == null || mapAddress.containsKey(oEvent.billingAddressId__c) || oEvent.billingAddressId__c == 'null' ? null :  oEvent.billingAddressId__c;
                        mapAddressToInsert.put(uniqueKey+'_BillTo', address);
                    }
                    
                    if(shippingAddressID == null){
                        Address__c address = addressMapping(oEvent, null, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'ShipTo');
                        address.Oracle_Cust_Site_Id__c = oEvent.shippingAddressId__c == null || mapAddress.containsKey(oEvent.shippingAddressId__c) ||  oEvent.shippingAddressId__c == 'null' ? null :  oEvent.shippingAddressId__c;
                        mapAddressToInsert.put(uniqueKey+'_ShipTo', address);
                    }
                    
                    if(mapAddress.containsKey(oEvent.billingAddressId__c) && !mapAddress.get(oEvent.billingAddressId__c).isLocked__c){
                        mapAddressToLocked.put(mapAddress.get(oEvent.billingAddressId__c).Id, new Address__c(Id = mapAddress.get(oEvent.billingAddressId__c).Id, isLocked__c = true));
                    }
                    if(mapAddress.containsKey(oEvent.shippingAddressId__c) && !mapAddress.get(oEvent.shippingAddressId__c).isLocked__c){
                        mapAddressToLocked.put(mapAddress.get(oEvent.shippingAddressId__c).Id, new Address__c(Id = mapAddress.get(oEvent.shippingAddressId__c).Id, isLocked__c = true));
                    }
                }else{
                    
                    if(mapAddress.containsKey(oEvent.billingAddressId__c) && !mapAddress.get(oEvent.billingAddressId__c).isLocked__c && isBillingAddressChanged(mapAddress.get(oEvent.billingAddressId__c), oEvent)){
                        mapAddressToUpsert.put(uniqueKey+'_BillTo', addressMapping(oEvent, mapAddress.get(oEvent.billingAddressId__c).Id, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'BillTo'));
                    }else if(!mapAddress.containsKey(oEvent.billingAddressId__c) || (mapAddress.containsKey(oEvent.billingAddressId__c) && mapAddress.get(oEvent.billingAddressId__c).isLocked__c && isBillingAddressChanged(mapAddress.get(oEvent.billingAddressId__c), oEvent))){
                        mapAddressToInsert.put(uniqueKey+'_BillTo', addressMapping(oEvent, null, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'BillTo'));
                    }
                    //note need to add condition if Address is locked then create new address...
                    if(mapAddress.containsKey(oEvent.shippingAddressId__c) && !mapAddress.get(oEvent.shippingAddressId__c).isLocked__c && isBillingAddressChanged(mapAddress.get(oEvent.shippingAddressId__c), oEvent)){
                        mapAddressToUpsert.put(uniqueKey+'_ShipTo', addressMapping(oEvent, mapAddress.get(oEvent.shippingAddressId__c).Id, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'ShipTo'));
                    }else if(!mapAddress.containsKey(oEvent.shippingAddressId__c) || (mapAddress.containsKey(oEvent.shippingAddressId__c) && !mapAddress.get(oEvent.shippingAddressId__c).isLocked__c && isBillingAddressChanged(mapAddress.get(oEvent.shippingAddressId__c), oEvent))){
                        mapAddressToInsert.put(uniqueKey+'_ShipTo', addressMapping(oEvent, null, mapAddressRecordTypeNameToID.get(addRecordTypeName), 'ShipTo'));
                    }
                    billingAddressID = mapAddress.containsKey(oEvent.billingAddressId__c) && !isBillingAddressChanged(mapAddress.get(oEvent.billingAddressId__c), oEvent) ? mapAddress.get(oEvent.billingAddressId__c).Id : null;
                    shippingAddressID= mapAddress.containsKey(oEvent.shippingAddressId__c) && !isShippingAddressChanged(mapAddress.get(oEvent.shippingAddressId__c), oEvent) ? mapAddress.get(oEvent.shippingAddressId__c).Id: null;
                }
                
                String fdId = mapFinanceDetail.containsKey(oEvent.creditCardToken__c) ? mapFinanceDetail.get(oEvent.creditCardToken__c).Id : null;
                mapOrder.put(uniqueKey, orderMapping(oEvent, mapRecordTypeNameToID.get(recordTypeName), mapPriceBook.get(oEvent.pricebookName__c), shippingAddressID, billingAddressID, fdId, new Order(), ownerId, orderType, 'create'));
               if(fdId != null && mapFinanceDetail.get(oEvent.creditCardToken__c).Expiry_Date__c != oEvent.creditCardExpirationDate__c) {
                   mapFinanceDetailToInsert.put(uniqueKey, new Finance_Detail__c(Id = fdId, Expiry_Date__c = oEvent.creditCardExpirationDate__c));
               }
               if(fdId == null && oEvent.creditCardToken__c != null && oEvent.creditCardToken__c != 'null'){                   
                mapFinanceDetailToInsert.put(uniqueKey, PEClsBatchOrderV1EventHandler.mappingFinancialDetail(oEvent, new Order()));
               }
            
		} 
        
         Map<String, String> mapDuplicateAddressIds = PEClsBatchOrderV1EventHandler.findDuplicateAddress(mapAddressToInsert);
        Map<String, Address__c> mapDuplicateAddress = new Map<String, Address__c>([SELECT Id, isLocked__c FROM Address__c WHERE Id IN: mapDuplicateAddressIds.values()]);
        for(String key : mapAddressToInsert.keySet()){
            if(mapDuplicateAddressIds.containsKey(key)) {
                CRM_Order_Event__e oEventData = mapOrderEventCreate.get(key.split('_')[0]); // ask vijay sholud we consider the address duplicate funcationality
                if(oEventData != null && oEventData.eventSource__c.containsIgnoreCase('OMS')){
                    if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'BillTo' && !mapDuplicateAddress.get(mapDuplicateAddressIds.get(key)).isLocked__c){
                        mapOrder.get(key.split('_')[0]).Customer_Bill_To_Address__c = mapDuplicateAddressIds.get(key); 
                        mapAddressToLocked.put(mapDuplicateAddressIds.get(key), new Address__c(Id = mapDuplicateAddressIds.get(key), isLocked__c = true, Oracle_Cust_Site_Id__c = oEvent.billingAddressId__c));
                    }else if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'ShipTo' && !mapDuplicateAddress.get(mapDuplicateAddressIds.get(key)).isLocked__c){
                        mapOrder.get(key.split('_')[0]).Customer_Ship_To_Address__c = mapDuplicateAddressIds.get(key);
                        mapAddressToLocked.put(mapDuplicateAddressIds.get(key), new Address__c(Id = mapDuplicateAddressIds.get(key), isLocked__c = true, Oracle_Cust_Site_Id__c = oEvent.shippingAddressId__c));
                    }else{
                        mapAddressToUpsert.put(key, mapAddressToInsert.get(key));
                    }
                    
                }else{
                    if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'BillTo'){
                        mapOrder.get(key.split('_')[0]).Customer_Bill_To_Address__c = mapDuplicateAddressIds.get(key); 
                    }else if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'ShipTo'){
                        mapOrder.get(key.split('_')[0]).Customer_Ship_To_Address__c = mapDuplicateAddressIds.get(key);
                    }
                    if(!mapDuplicateAddress.get(mapDuplicateAddressIds.get(key)).isLocked__c){
                        mapAddressToLocked.put(mapDuplicateAddressIds.get(key), new Address__c(Id = mapDuplicateAddressIds.get(key), isLocked__c = true));
                        //mapAddressToUpsert.put(key, new Address__c(Id = mapDuplicateAddressIds.get(key), isLocked__c = true));
                    }
                }
            }
            else {
                mapAddressToUpsert.put(key, mapAddressToInsert.get(key));
            }
        }
        List<String> lstAddressKey = new List<String>();
        List<Address__c> lstAddress = new List<Address__c>();
        Map<String, String> mapErrors = new Map<String, String>();
        Set<String> setAddressId = new Set<String>();
        for(String key : mapAddressToUpsert.keySet()){
            if(mapAddressToUpsert.get(key).Id != null && setAddressId.contains(mapAddressToUpsert.get(key).Id)) continue;
            lstAddressKey.add(key);
            lstAddress.add(mapAddressToUpsert.get(key));
            if(mapAddressToUpsert.get(key).Id != null )setAddressId.add(mapAddressToUpsert.get(key).Id);
        }
        
        Database.UpsertResult[] urList = Database.upsert(lstAddress, false);
        for(Integer i = 0; i < urList.size(); i++){
            String key = lstAddressKey[i];
            if(urList[i].isSuccess()){
                mapAddressToLocked.put(urList[i].getId(), new Address__c(Id = urList[i].getId(), isLocked__c = true));
                if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'BillTo'){
                    mapOrder.get(key.split('_')[0]).Customer_Bill_To_Address__c = urList[i].getId(); 
                }else if(mapOrder.containsKey(key.split('_')[0]) && key.split('_')[1] == 'ShipTo'){
                    mapOrder.get(key.split('_')[0]).Customer_Ship_To_Address__c = urList[i].getId();
                }
                
            }else {
                String error = mapErrors.containsKey(key.split('_')[0]) ? mapErrors.get(key.split('_')[0]) : '';
                for(Database.Error err : urList[i].getErrors()) {
                    error += error == '' ? 'Address Error : ' +err.getMessage() : ', ' + err.getMessage();
                }
                mapErrors.put(key.split('_')[0], error);
            }
        }
        List<String> lstFDKey = new List<String>();
        List<Finance_Detail__c> lstFinanceDetail = new List<Finance_Detail__c>();
        for(String key : mapFinanceDetailToInsert.keySet()){
            lstFDKey.add(key);
            lstFinanceDetail.add(mapFinanceDetailToInsert.get(key));
        }

        urList = Database.upsert(lstFinanceDetail, false);
        for(Integer i = 0; i < urList.size(); i++){
            String key = lstFDKey[i];
            if(urList[i].isSuccess()){
                mapOrder.get(key).Finance_Detail__c = urList[i].getId(); 
            }else {
                String error = mapErrors.containsKey(key) ? mapErrors.get(key) + 'Financial Detail Error : ' : '';
                for(Database.Error err : urList[i].getErrors()) {
                    error += error == '' ? 'Financial Detail Error ' + err.getMessage() : ', ' + err.getMessage();
                }
                mapErrors.put(key, error);
            }
        }
        for(String key : mapErrors.keySet()){
            if(!mapOrder.containsKey(key)) continue;
            mapOrder.remove(key);
           
           CRM_Order_Event__e oEvent1 =  mapOrderEventCreate.get(Key);
           System.debug('***oEvent1--'+oEvent1);
           ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Incorrect data', 'order', 
                                              oEvent1.eventSource__c ,mapErrors.get(key), oEvent1.eventSourceID__c , 'Informational', String.valueof(oEvent1));
            
        }
        List<String> lstOrderKey = new List<String>();
        List<Order> lstOrder = new List<Order>();
        for(String key : mapOrder.keySet()){
            lstOrderKey.add(key);
            lstOrder.add(mapOrder.get(key));
        }   
        System.debug('======lstOrder======='+lstOrder);
        Database.SaveResult[]  srList = Database.insert(lstOrder, false);
        for(Integer i = 0; i < srList.size(); i++){
            String key = lstOrderKey[i];
            if(srList[i].isSuccess()){
                System.debug('srList[i].getId()---'+srList[i].getId());
                mapOrderEventToErrorHandle.put(srList[i].getId(), mapOrderEventCreate.get(key));
                mapOrderNew.put(srList[i].getId(), lstOrder[i]);
                if(!mapListOrderItem.containsKey(key)) continue;
                for(OrderItem ordItm : mapListOrderItem.get(key)){
                    ordItm.OrderId = srList[i].getId();
                    lstOrderItem.add(ordItm);
                }
            }else {
                String error = '';
                for(Database.Error err : srList[i].getErrors()) {
                    error += error == '' ? 'Order Error :' + err.getMessage() : ', ' + err.getMessage();
                    error = error +  '; Status Code: ' + err.getStatusCode() + '; fields that affected this error: ' + err.getFields();
                }
                System.debug('======error======='+error);
                
                CRM_Order_Event__e oEvent2 = mapOrderEventCreate.get(key);
               
           		ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Error while creating the order', 'order', 
                                              oEvent2.eventSource__c ,error, oEvent2.eventSourceID__c , 'Informational', String.valueof(oEvent2));
            }
        }
        srList = Database.insert(lstOrderItem, false);
        System.debug('srList*****'+srList);
        Map<Id, Order> mapOrderToDelete = new Map<Id, Order>();        
        for(Integer i = 0; i < srList.size(); i++){    
            String key = lstOrderItem[i].OrderId;
            CRM_Order_Event__e oEvent3 = mapOrderEventToErrorHandle.get(key);
            if(srList[i].isSuccess()){
                if(mapOrderToDelete.containsKey(key)) continue;
            	oEvent3 = mapOrderEventToErrorHandle.get(key);
                Order newOrder = mapOrderNew.get(key);
                /*
                newOrder.Status = oEvent3 != null && oEvent3.stage__c == 'pending' && oEvent3.operation__c == 'update' && oEvent3.eventSource__c.containsIgnoreCase('OMS') && oEvent3.status__c != null ? oEvent3.status__c :
                                  oEvent3 != null && oEvent3.stage__c == 'pending' && oEvent3.operation__c == 'update' && oEvent3.eventSource__c.containsIgnoreCase('OMS') && oEvent3.status__c == null ? newOrder.Status : 
                                  oEvent3 != null && oEvent3.stage__c == 'pending' && oEvent3.operation__c == 'create' && oEvent3.eventSource__c != null && oEvent3.eventSource__c.containsIgnoreCase('ECOM') ? 'Activated' : 'Booked';
                */
                newOrder.Status = oEvent3 != null && oEvent3.stage__c == 'pending' && oEvent3.operation__c == 'create' && oEvent3.eventSource__c != null && oEvent3.eventSource__c.containsIgnoreCase('ECOM') ? 'Activated' : 'Booked';
                mapOrderToUpdate.put(key, newOrder);
            }else {
                mapOrderToDelete.put(key, new Order(Id = key));
                mapOrderToUpdate.remove(key);
                String error = '';
                for(Database.Error err : srList[i].getErrors()) {
                    error += error == '' ? 'OrderItem Error affected due to fields :'+err.getFields() + err.getMessage() : ', ' + err.getMessage();
                }
               
                ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Error while creating the order item', 'order', 
                                              oEvent3.eventSource__c ,'Incorrect data', oEvent3.eventSourceID__c , 'Informational', String.valueof(oEvent3));
            }
        }
        lstOrder = mapOrderToUpdate.values(); 
        delete mapOrderToDelete.values();
        mapOrderNew = new Map<String, Order>();
        srList = Database.update(lstOrder, false);
        for(Integer i = 0; i < srList.size(); i++){
            Order newOrder = lstOrder[i];
            if(srList[i].isSuccess()){
      	
			ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder', 'Successfully consumed Order Event.',
						'Order',  mapOrderEventToErrorHandle.get(newOrder.Id).eventSourceID__c, 
                        'Order Id: ' +  newOrder.Id,mapOrderEventToErrorHandle.get(newOrder.Id).eventSourceID__c,
                        'Success Log', String.valueOf(mapOrderEventToErrorHandle.get(newOrder.Id)));
           
               
                if(newOrder != null && mapAccount.containsKey(newOrder.AccountId) /* && mapAccount.get(newOrder.AccountId).Sync_Status__c.equalsIgnoreCase('created') */){       // Currently removing this while OMS is being set-up.
                    setOrderId.add(newOrder.Id);
                }
            }else {
                mapOrderNew.put(newOrder.Id, newOrder);
                String error = '';
                for(Database.Error err : srList[i].getErrors()) {
                    error += error == '' ? 'Order Update Error affected due to fields :'+err.getFields() +  err.getMessage() : ', ' + err.getMessage();
                }
               
                CRM_Order_Event__e orEvent = mapOrderEventCreate.get(newOrder.Id);
                
                
                ErrorUtility.LogErrorWithEvent('Consume', 'PEClsBatchOrderV1EventHandler.createOrder','Error while creating the order :'+error,
						'Order',  mapOrderEventToErrorHandle.get(newOrder.Id).eventSource__c,
                                               'Order Will not be processed due to Unknown filed/fields found.',
                                               mapOrderEventToErrorHandle.get(newOrder.Id).eventSourceID__c,'Informational',
                                               String.valueOf(mapOrderEventToErrorHandle.get(newOrder.Id)));
               
           
            
            }
        }
        delete mapOrderNew.values();
        
        //finally locked the address record...  
        update mapAddressToLocked.values();
       
            if(!setOrderId.isEmpty()){
                System.debug('***setOrderId---'+setOrderId);
                PEClsHandleOrderEvents.publishOrderEvent(setOrderId, new Set<String>(), 'create');
            }//PEBatchCANOrderEvent.publishOrderEvent(setOrderId, new Set<String>(), mapOrderEvent);  
            
            
          // publishOrderEvent(setOrderId,new Set<String>(),'create')                               
        }catch(Exception ex){
          System.debug('Error @Line ---'+ex.getLineNumber());
          System.debug('Error @Line ---'+ex.getMessage());
        }
    }
    
   @TestVisible private static String parseOrderType(String orderType, String origin){
        if(String.isEmpty(orderType) || String.isBlank(orderType)) return orderType;
        List<String> lstOrderType = orderType.split(' ');
        String countryCode = lstOrderType.remove(0);
        String newOrderType = String.join(lstOrderType, ' ').toUpperCase().trim();
        if(mapOrderTypeENUM.containsKey(newOrderType)){
            return origin.containsIgnoreCase('ECOM') && mapOrderEventSetting.get(mapOrderTypeENUM.get(newOrderType)).EBS_ORDER_TYPE__c != null ? countryCode +' '+ mapOrderEventSetting.get(mapOrderTypeENUM.get(newOrderType)).EBS_ORDER_TYPE__c : 
                   origin.containsIgnoreCase('CRM') && mapOrderEventSetting.get(mapOrderTypeENUM.get(newOrderType)).FUSION_ORDER_TYPE__c != null ? countryCode +' '+ mapOrderEventSetting.get(mapOrderTypeENUM.get(newOrderType)).FUSION_ORDER_TYPE__c : orderType;
        }
        return orderType;
    }
   
    @TestVisible private static Map<String, String> findDuplicateAddress(Map<String, Address__c> mapAddress){
        if(mapAddress.isEmpty()) return new Map<String, String>();
        Map<String, String> mapKeyToAddressID = new Map<String, String>();
        Map<String, List<String>> mapAddressUniqueToKeys = new Map<String, List<String>>();
        Set<String> setAccountID = new Set<String>();
        for(String key : mapAddress.keySet()){
            String uniqueKey = PEClsBatchOrderV1EventHandler.createUniqueKey(mapAddress.get(key));
            if(!mapAddressUniqueToKeys.containsKey(uniqueKey))mapAddressUniqueToKeys.put(uniqueKey, new List<String>());
            mapAddressUniqueToKeys.get(uniqueKey).add(key);
            setAccountID.add(mapAddress.get(key).Account__c);
        }
        for(Address__c address : [SELECT Id, Business_Name__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, Country__c, First_Name__c, Last_Name__c, Postal_Code__c, Primary_Phone__c, State__c, SOS_Unique_ID__c, Type__c, Account__c, Inactive__c, IsLocked__c
                                    FROM Address__c WHERE Account__c IN: setAccountID]){
            String uniqueKey = PEClsBatchOrderV1EventHandler.createUniqueKey(address);
            if(!mapAddressUniqueToKeys.containsKey(uniqueKey)) continue;
            for(String key : mapAddressUniqueToKeys.get(uniqueKey)) mapKeyToAddressID.put(key, address.Id);
        }
        return mapKeyToAddressID;
    }
    @TestVisible private static OrderItem orderItemMapping(String pbeId, OrderLineItem oli, String orderID, OrderItem oItem,
                                                           Map<String, String> mapSKUProduct, String eventSource){
                 
        try{
        
        return new OrderItem(PriceBookEntryId = pbeId,  Quantity = oli.quantity != null ? oli.quantity : oItem.Quantity, 
                             skuBundle__c = oli.skuBundle != null && oli.skuBundle != 'null' && mapSKUProduct.containsKey(oli.skuBundle) ? mapSKUProduct.get(oli.skuBundle) : oItem.skuBundle__c,
                             orderID = orderID, UnitPrice = oli.price != null ? oli.price : oItem.UnitPrice, isBundle__c = oli.isBundle != null ?  oli.isBundle : oItem.isBundle__c, 
                             isBundleItem__c = oli.isBundleItem != null ? oli.isBundleItem : oItem.isBundleItem__c, 
							 External_Id__c = (eventSource.containsIgnoreCase('OMS') && oli.itemID != 'null') ? oli.itemID : null);
        }catch(Exception ex){
            System.debug('--orderItemMapping--@Line'+ex.getLineNumber());
            return null;
        }
    }
    @TestVisible private static Order orderMapping(CRM_Order_Event__e oEvent, String recordTypeID, String priceBookId, String shippingAddressID, String billingAddressID, String fdId, Order newOrder, String ownerId, String orderType, String action){
		if(action == 'create'){
            return new Order(Id = newOrder.Id, RecordTypeId = recordTypeID != null ? recordTypeID : newOrder.RecordTypeId, AccountId = oEvent.accountId__c != null ? oEvent.accountId__c : newOrder.AccountId, 
                             Invoice_Date__c = oEvent.invoiceDate__c != 'null' && !String.isBlank(oEvent.invoiceDate__c) ? Date.valueOf(oEvent.invoiceDate__c) : newOrder.Invoice_Date__c, PriceBook2Id = priceBookId, 
                             Ecom_Confirmation_Number__c = (oEvent.eventSource__c == 'ecom' && oEvent.eventSourceID__c != null) ? oEvent.eventSourceID__c : newOrder.Ecom_Confirmation_Number__c,
                             Invoice_Number__c = oEvent.invoiceNumber__c != 'null' ? oEvent.invoiceNumber__c : newOrder.Invoice_Number__c, Type = orderType != 'null' ? orderType : newOrder.Type, 
                             Status = oEvent.status__c != null && newOrder.Id != null ? oEvent.status__c  : 'Draft', System_Of_Origin__c = oEvent.systemOfOrigin__c != null ? oEvent.systemOfOrigin__c : newOrder.System_Of_Origin__c,
                             System_Of_Origin_ID__c = oEvent.systemOfOriginID__c != null ? oEvent.systemOfOriginID__c : newOrder.System_Of_Origin_ID__c, 
                             Warehouse__c = oEvent.warehouse__c != null && oEvent.warehouse__c != 'null'? oEvent.warehouse__c : newOrder.Warehouse__c,
                             Credit_Card_Authorization_Code__c = oEvent.creditCardAuthorizationCode__c != 'null' ? oEvent.creditCardAuthorizationCode__c : newOrder.Credit_Card_Authorization_Code__c,
                             Payment_Id__c = oEvent.creditCardTransactionID__c  != 'null' ? oEvent.creditCardTransactionID__c  : newOrder.Payment_Id__c,
                             Customer_Bill_To_Address__c = billingAddressID != 'null' ? billingAddressID : newOrder.Customer_Bill_To_Address__c, 
                             Customer_Ship_To_Address__c = shippingAddressID != 'null' ? shippingAddressID : newOrder.Customer_Ship_To_Address__c, 
                             Finance_Detail__c = fdId != 'null' ? fdId : newOrder.Finance_Detail__c, EffectiveDate = PEClsBatchOrderV1EventHandler.getCurrentDate('America/Los_Angeles'), OwnerId = ownerId == null ? newOrder.OwnerId : ownerId,
                             Signature_Required__c = oEvent.isSignatureRequired__c, Shipping_Method__c = oEvent.shippingMethod__c, Price_Book__c = priceBookId,CurrencyIsoCode = 'CAD',
                             SOS_Unique_ID__c = oEvent.systemOfOrigin__c+oEvent.systemOfOriginID__c, Ecom_Parent_Order__c = oEvent.parentSystemOfOriginID__c,
                             OMS_Order_Number__c = oEvent != null && (oEvent.stage__c == 'pending'|| oEvent.stage__c == 'confirmed') && oEvent.operation__c == 'create' && oEvent.eventSource__c != null && oEvent.eventSource__c.containsIgnoreCase('OMS') && oEvent.eventSourceId__c != null ? oEvent.eventSourceId__c : null);
		}else
			return new Order(Id = newOrder.Id, Status = oEvent.status__c != null && newOrder.Id != null ? oEvent.status__c  : 'Draft', Invoice_Date__c = oEvent.invoiceDate__c != 'null' && !String.isBlank(oEvent.invoiceDate__c) ? Date.valueOf(oEvent.invoiceDate__c) : newOrder.Invoice_Date__c, Invoice_Number__c = oEvent.invoiceNumber__c != 'null' ? oEvent.invoiceNumber__c : newOrder.Invoice_Number__c);		
    }
    private static Date getCurrentDate(String timeZone){
        return Date.valueOf(System.now().format('yyyy-MM-dd', timeZone));
    }
    @TestVisible private static Address__c addressMapping(CRM_Order_Event__e oEvent, String recordId, String recordTypeID, String addressType){
        String billingCountry = oEvent.billingAddressCountry__c != 'null' && oEvent.billingAddressCountry__c != null ? oEvent.billingAddressCountry__c : oEvent.billingAddressCountryCode__c != null && mapCountry.containsKey(oEvent.billingAddressCountryCode__c) ? mapCountry.get(oEvent.billingAddressCountryCode__c) : null;
        String shippingCounty = oEvent.shippingAddressCountry__c != 'null' && oEvent.shippingAddressCountry__c != null ? oEvent.shippingAddressCountry__c : oEvent.shippingAddressCountryCode__c != null && mapCountry.containsKey(oEvent.shippingAddressCountryCode__c) ? mapCountry.get(oEvent.shippingAddressCountryCode__c) : null;
        String billingState = oEvent.billingAddressStateProvince__c  != 'null' && oEvent.billingAddressStateProvince__c.length() == 2 &&  mapState.containsKey(oEvent.billingAddressStateProvince__c) ? mapState.get(oEvent.billingAddressStateProvince__c) : oEvent.billingAddressStateProvince__c != 'null' && oEvent.billingAddressStateProvince__c != null && oEvent.billingAddressStateProvince__c.length() > 2 ? oEvent.billingAddressStateProvince__c : null; 
        System.debug('1-billingState--'+billingState);
        System.debug('2-length--'+oEvent.billingAddressStateProvince__c.length());
        System.debug('3-Provience--'+oEvent.billingAddressStateProvince__c);
        
        String shippingState = oEvent.shippingAddressStateProvince__c  != 'null' && oEvent.billingAddressStateProvince__c.length() == 2 &&  mapState.containsKey(oEvent.shippingAddressStateProvince__c) ? mapState.get(oEvent.shippingAddressStateProvince__c) : oEvent.shippingAddressStateProvince__c != 'null' && oEvent.shippingAddressStateProvince__c != null && oEvent.shippingAddressStateProvince__c.length() > 2 ? oEvent.shippingAddressStateProvince__c : null; 
        Address__c address = new Address__c(Id = recordId, recordTypeID = recordTypeID, 
                                            Business_Name__c = addressType == 'BillTo' && oEvent.billingAddressBusinessName__c != 'null'? oEvent.billingAddressBusinessName__c : addressType == 'ShipTo' && oEvent.shippingAddressBusinessName__c != 'null' ? oEvent.shippingAddressBusinessName__c : null, 
                                            Address_Line_1__c = addressType == 'BillTo' && oEvent.billingAddress1__c != 'null' ? oEvent.billingAddress1__c : addressType == 'ShipTo' && oEvent.shippingAddress1__c != 'null' ? oEvent.shippingAddress1__c : null, 
                                            Address_Line_2__c = addressType == 'BillTo' && oEvent.billingAddress2__c != 'null' ? oEvent.billingAddress2__c : addressType == 'ShipTo' && oEvent.shippingAddress2__c != 'null' ? oEvent.shippingAddress2__c : null, 
                                            Address_Line_3__c = addressType == 'BillTo' && oEvent.billingAddress3__c != 'null' ? oEvent.billingAddress3__c : addressType == 'ShipTo' && oEvent.shippingAddress3__c != 'null' ? oEvent.shippingAddress3__c : null,
                                            City__c = addressType == 'BillTo' && oEvent.billingAddressCity__c != 'null' ? oEvent.billingAddressCity__c : addressType == 'ShipTo' && oEvent.shippingAddressCity__c != null ? oEvent.shippingAddressCity__c : null, 
                                            Country__c = addressType == 'BillTo' ? billingCountry : shippingCounty, State__c = addressType == 'BillTo' ?  billingState : shippingState,
                                            Type__c = addressType == 'BillTo' ?  'Bill To' : 'Ship To', 
                                            First_Name__c = addressType == 'BillTo' && oEvent.billingAddressFirstName__c != 'null' ? oEvent.billingAddressFirstName__c : addressType == 'ShipTo' && oEvent.shippingAddressFirstName__c != 'null' ? oEvent.shippingAddressFirstName__c : null, 
                                            Last_Name__c = addressType == 'BillTo' && oEvent.billingAddressLastName__c != 'null' ? oEvent.billingAddressLastName__c : addressType == 'ShipTo' && oEvent.shippingAddressLastName__c != 'null' ? oEvent.shippingAddressLastName__c : null,
                                            Postal_Code__c = addressType == 'BillTo' && oEvent.billingAddressPostalCode__c != 'null'? oEvent.billingAddressPostalCode__c : addressType == 'ShipTo' && oEvent.shippingAddressPostalCode__c != 'null' ? oEvent.shippingAddressPostalCode__c : null,
                                            Primary_Phone__c = addressType == 'BillTo' && oEvent.billingAddressPrimaryPhone__c != 'null' ? oEvent.billingAddressPrimaryPhone__c : addressType == 'ShipTo' && oEvent.shippingAddressPrimaryPhone__c != 'null' ? oEvent.shippingAddressPrimaryPhone__c : null,
                                            Primary_Flag__c = true, System_Of_Origin__c = oEvent.systemOfOrigin__c, System_Of_Origin_Id__c = oEvent.systemOfOriginID__c);
        if(recordId == null) {
            address.Account__c = addressType == 'BillTo' && oEvent.billingAddressAccountID__c != null && oEvent.billingAddressAccountID__c != 'null' ? oEvent.billingAddressAccountID__c : addressType == 'ShipTo' && oEvent.shippingAddressAccountID__c != null && oEvent.shippingAddressAccountID__c != 'null' ? oEvent.shippingAddressAccountID__c : oEvent.accountId__c;
            //address.SOS_Unique_ID__c = addressType +'_'+oEvent.systemOfOrigin__c+'_'+oEvent.systemOfOriginID__c;
        }
        return address;
    }
    @TestVisible private static Boolean isBillingAddressChanged(Address__c address, CRM_Order_Event__e oEvent){
        return (address.Business_Name__c != oEvent.billingAddressBusinessName__c || address.Address_Line_1__c != oEvent.billingAddress1__c || address.Address_Line_2__c != oEvent.billingAddress2__c ||
                address.Address_Line_3__c != oEvent.billingAddress3__c || address.City__c != oEvent.billingAddressCity__c || address.Country__c != oEvent.billingAddressCountry__c ||
                address.First_Name__c != oEvent.billingAddressFirstName__c || address.Last_Name__c != oEvent.billingAddressLastName__c || address.Postal_Code__c != oEvent.billingAddressPostalCode__c ||
                address.Primary_Phone__c != oEvent.billingAddressPrimaryPhone__c || address.State__c != oEvent.billingAddressStateProvince__c);
    }
    @TestVisible private static Boolean isShippingAddressChanged(Address__c address, CRM_Order_Event__e oEvent){
        return (address.Business_Name__c != oEvent.shippingAddressBusinessName__c || address.Address_Line_1__c != oEvent.shippingAddress1__c || address.Address_Line_2__c != oEvent.shippingAddress2__c ||
                address.Address_Line_3__c != oEvent.shippingAddress3__c || address.City__c != oEvent.shippingAddressCity__c || address.Country__c != oEvent.shippingAddressCountry__c ||
                address.First_Name__c != oEvent.shippingAddressFirstName__c || address.Last_Name__c != oEvent.shippingAddressLastName__c || address.Postal_Code__c != oEvent.shippingAddressPostalCode__c ||
                address.Primary_Phone__c != oEvent.shippingAddressPrimaryPhone__c || address.State__c != oEvent.shippingAddressStateProvince__c);
    }
    @TestVisible private static Finance_Detail__c mappingFinancialDetail(CRM_Order_Event__e oEvent, Order newOrder){
        return new Finance_Detail__c(Id = newOrder.Finance_Detail__c, Account__c = oEvent.accountId__c != null ? oEvent.accountId__c : newOrder.AccountId, Finance_Type__c = 'Credit Card',
                                     Token__c = oEvent.creditCardToken__c != 'null' ? oEvent.creditCardToken__c : newOrder.Finance_Detail__r.Token__c, 
                                     Card_Type__c = oEvent.creditCardType__c != 'null' ? oEvent.creditCardType__c : newOrder.Finance_Detail__r.Card_Type__c, 
                                     Expiry_Date__c = oEvent.creditCardExpirationDate__c != 'null' ? oEvent.creditCardExpirationDate__c : newOrder.Finance_Detail__r.Expiry_Date__c, 
                                     InActive__c = false, Last_4_Digits__c = oEvent.creditCardToken__c != 'null' ? oEvent.creditCardToken__c.right(4) : newOrder.Finance_Detail__r.Last_4_Digits__c);
    }
    @TestVisible private static String createUniqueKey(Address__c address){
        return //parseValue(address.Business_Name__c) +'_'+ parseValue(address.First_Name__c)+'_'+ parseValue(address.Last_Name__c)+'_'+ 
               parseValue(address.Address_Line_1__c)+'_'+ parseValue(address.Address_Line_2__c)+'_'+ parseValue(address.Address_Line_3__c)+'_'+ 
               parseValue(address.City__c)+'_'+ parseValue(address.State__c)+'_'+ parseValue(address.Postal_Code__c)+'_'+ 
               parseValue(address.Country__c)+'_'+ parseValue(address.Type__c)+'_'+ parseValue(address.Account__c)+'_'+ parseValue(address.Primary_Phone__c);
    }
    
    @TestVisible private static String parseValue(String value){
        return value == null || value == 'null' ? '' : value.replaceAll( '\\s+', '');
    }
    public static Map<String, String> getPicklistValues(String objectAPI,String fieldAPI){   
        Map<String, String> mapPicklist = new Map<String, String>();
        try{
            for(Schema.PicklistEntry sObjPickListEntry : Schema.getGlobalDescribe().get(objectAPI).newSObject().getSObjectType().getDescribe().fields.getMap().get(fieldAPI).getDescribe().getPickListValues()){
                mapPicklist.put(sObjPickListEntry.getValue(), sObjPickListEntry.getLabel());
                mapPicklist.put(sObjPickListEntry.getLabel(), sObjPickListEntry.getValue());
            }
        }catch(Exception ex){
            ErrorUtility.LogError('Consume', 'PEClsHandleOrderEvents.getPicklistValues', 'Error while getting the Country and State Piclist information: '+ex.getMessage(),
                                  'order', null, 'Incorrect data.', '', 'Informational');
        	     
           
        }
        return mapPicklist;
    }
      public class OrderLineItem{
        public String itemID;
        public String sku;
        public Decimal quantity;
        public Decimal price;
        public Boolean isBundle;
        public Boolean isBundleItem;
        public String skuBundle;
        public String url; 
        
        public OrderLineItem(String sku, Decimal quantity, Decimal price){
            this.sku =  sku;
            this.quantity = quantity;
            this.price = price;
        }
        public OrderLineItem(OrderItem oli){
            this.itemID = oli.External_Id__c != null ? oli.External_Id__c : oli.Id;
            this.sku = oli.Product2.Name;
            this.quantity = oli.Quantity;
            this.price = oli.UnitPrice;
            this.isBundle = oli.isBundle__c;
            this.isBundleItem = oli.isBundleItem__c;
            this.skuBundle = oli.SkuBundle__r.Name;
            this.url = '';
        }
        
    }
    global class ObjectIterator implements Iterator<Sobject>, Iterable<Sobject>{
        global List<Sobject> lstObject; Integer i = 0;
        global ObjectIterator(List<Sobject> lstObject){  this.lstObject = lstObject; i = 0; }  
        global Boolean hasNext(){ return (i >= lstObject.size()) ? false : true; } 
        global Sobject next(){ if(i < lstObject.size()){ i++; return lstObject[i-1]; } return null;}  
        global Iterator<Sobject> iterator() { return this;  } 
    }

}