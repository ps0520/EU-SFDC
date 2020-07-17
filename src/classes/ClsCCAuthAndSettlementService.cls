public class ClsCCAuthAndSettlementService {
    
    public static Map<Id, ClsCCAuthAndSettlementResponse> authorize(Id orderId){
        Map<Id, ClsCCAuthAndSettlementResponse> mapSvcRes= new Map<Id, ClsCCAuthAndSettlementResponse>();
        ClsCCAuthAndSettlementResponse svcRes= new ClsCCAuthAndSettlementResponse();
        mapSvcRes.put(orderId, svcRes); Boolean isDupe=false;
        if(orderId != null){
            List<Order> lstOrders= new List<Order>([Select Id, OrderNumber, CurrencyISOCode, Total_Gross_Price__c, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail, Account.Owner.Email, 
                 Finance_Detail__r.Expiry_Date__c, Finance_Detail__r.Token__c, Finance_Detail__r.CC_Address__r.Address_Line_1__c, Payment_Id__c, CC_Auth_Amount__c, CC_Trans_Status__c,
                 Finance_Detail__r.CC_Address__r.City__c,  Finance_Detail__r.CC_Address__r.State__c, Finance_Detail__r.CC_Address__r.Postal_Code__c, Finance_Detail__r.CC_Address__r.Country__c,Account.Primary_Contact_Number__c  
                 from Order Where Id =:orderId AND Finance_Detail__r.Token__c != null 
             	 AND Finance_Detail__r.Expiry_Date__c != null AND Finance_Detail__r.CC_Address__c != null
                 AND Finance_Detail__r.InActive__c = false AND  Finance_Detail__r.RecordType.DeveloperName = 'Credit_Card']);
        if(!lstOrders.isEmpty()){
            	Order o=lstOrders[0];
           if(o != null){
           	System.Debug('**** TPS:EH 2.1 o=' + o);
            if(o.Payment_Id__c!= null && o.CC_Auth_Amount__c!=null){
                isDupe=true;
            }
            if(ClsCheckRecursive.orderId != null ) {
                if(ClsCheckRecursive.orderId==o.Id) {
                	isDupe=true;    
                }
            }
            if(isDupe){
                System.Debug('**** TPS:EH 3.1 authorize Duplicate');
            	svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
                svcRes.Error='Duplicate CC processing  error: This Order already has a payment Id and auth amount applied.';
                return mapSvcRes; 
            } 
                 ClsCheckRecursive.orderId=o.Id;
            	 ClsCSPaymentAuthReq req= new ClsCSPaymentAuthReq();
                    ClsCSPaymentAuthReq.clientReferenceInformation cri= new ClsCSPaymentAuthReq.clientReferenceInformation();
                    cri.code=o.OrderNumber;
                    req.clientReferenceInformation=cri;
            
                    ClsCSPaymentAuthReq.processingInformation pi=new ClsCSPaymentAuthReq.processingInformation();
                    pi.commerceIndicator='internet';// pi.capture=true;
                    req.processingInformation=pi;
                    
                    ClsCSPaymentAuthReq.tokenizedCard tc= new ClsCSPaymentAuthReq.tokenizedCard();
                    tc.expirationMonth=o.Finance_Detail__r.Expiry_Date__c.split('\\/')[0]; tc.expirationYear=o.Finance_Detail__r.Expiry_Date__c.split('\\/')[1];
                    ClsCSPaymentAuthReq.customer cus= new ClsCSPaymentAuthReq.customer();
                    cus.customerId=o.Finance_Detail__r.Token__c;
                    ClsCSPaymentAuthReq.paymentInformation payi = new ClsCSPaymentAuthReq.paymentInformation();
                    payi.tokenizedCard=tc; payi.customer=cus; req.paymentInformation=payi;
                    
                    ClsCSPaymentAuthReq.orderInformation oi= new ClsCSPaymentAuthReq.orderInformation();
                    ClsCSPaymentAuthReq.amountDetails ad=new ClsCSPaymentAuthReq.amountDetails();
                    ad.totalAmount=string.valueOf(o.Total_Gross_Price__c); ad.currToRep=o.CurrencyISOCode; oi.amountDetails=ad;
                    
                    ClsCSPaymentAuthReq.billTo bt=  new ClsCSPaymentAuthReq.billTo();
                    bt.firstName=o.Account.FirstName; bt.lastName=o.Account.LastName;
                    bt.address1=o.Finance_Detail__r.CC_Address__r.Address_Line_1__c;
                    bt.locality=o.Finance_Detail__r.CC_Address__r.City__c;
                    bt.administrativeArea=o.Finance_Detail__r.CC_Address__r.State__c; 
                    bt.postalCode=o.Finance_Detail__r.CC_Address__r.Postal_Code__c; 
                    bt.country=o.Finance_Detail__r.CC_Address__r.Country__c;
                    
                    if (!ClsOrderEntryHandler.validateEmail(o.Account.PersonEmail))  bt.email='null@cybersource.com'; else bt.email = o.Account.PersonEmail;	
               		if (ClsOrderEntryHandler.validatePhone(o.Account.Primary_Contact_Number__c))  bt.phoneNumber = o.Account.Primary_Contact_Number__c;
                    oi.billTo=bt;
                    req.orderInformation=oi;
                    string reqAuth=Json.serialize(req, true).replace('"currToRep"','"currency"');
                    System.Debug('**** TPS:EH 3.1 Authorize req=' + reqAuth);
                    ClsCCAuthAndSettlementServiceHelper clsHelper= new ClsCCAuthAndSettlementServiceHelper();
                    svcRes= clsHelper.AuthorizeHelper(reqAuth, o.CurrencyISOCode, svcRes);
                    System.Debug('**** TPS:EH 3.2 authorize svcRes=' + svcRes);
                    
                    o.Payment_Id__c= svcRes.paymentId; o.CC_Trans_Status__c=svcRes.transStatus; 
                    o.Settlement_Id__c=null; o.Settlement_Error__c=svcRes.error; o.CC_Auth_Amount__c=null;
               
                    if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.SUCCESS){
                        if(svcRes.paymentId != null && svcRes.settlementId != null && svcRes.approvalCode != null){                             
                            o.Settlement_Error__c=null;
                            o.CC_Auth_Amount__c=svcRes.authorizedAmount;                            
                        }    
                    } else if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.ERROR){
                        if(svcRes.paymentId != null){
                            System.Debug('**** TPS:EH 4.1 Get ResponseCode paymentId=' + svcRes.paymentId);
                            //o.Possible_Action__c= ErrorHelper(svcRes.paymentId, o.CurrencyISOCode);
                            //System.Debug('**** TPS:EH 4.2 Possible_Action__c=' + o.Possible_Action__c);
                        }                	
                	}
                    update o;
                   
           }  // if o != null
                
       } else {
       		svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
        	svcRes.Error='Order does not have a finance detail record or associated finance detail record does nopt have token / primary / expiry/ cc address configured.';
       }
        }
        return mapSvcRes;        
    }
    
    public static Map<Id, ClsCCAuthAndSettlementResponse> settlePayment(Id orderId){
    	Map<Id, ClsCCAuthAndSettlementResponse> mapSvcRes= new Map<Id, ClsCCAuthAndSettlementResponse>();
        ClsCCAuthAndSettlementResponse svcRes= new ClsCCAuthAndSettlementResponse();
        mapSvcRes.put(orderId, svcRes); Boolean isDupe=false;
        if(orderId != null){
        	List<Order> lstOrders= new List<Order>([Select Id, OrderNumber, CurrencyISOCode, TotalAmount, Total_Gross_Price__c, CC_Auth_Amount__c, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail, Account.Owner.Email, 
                 Finance_Detail__r.Expiry_Date__c, Finance_Detail__r.Token__c, Finance_Detail__r.CC_Address__r.Address_Line_1__c, Payment_Id__c, CC_Trans_Status__c, Settlement_Id__c,
                 Finance_Detail__r.CC_Address__r.City__c,  Finance_Detail__r.CC_Address__r.State__c, Finance_Detail__r.CC_Address__r.Postal_Code__c, Finance_Detail__r.CC_Address__r.Country__c 
                 from Order Where Id =:orderId AND Finance_Detail__r.Token__c != null 
             	 AND Finance_Detail__r.Expiry_Date__c != null AND Finance_Detail__r.CC_Address__c != null
                 AND Finance_Detail__r.InActive__c = false AND  Finance_Detail__r.RecordType.Name = 'Credit Card']);
        if(!lstOrders.isEmpty()){
            Order o=lstOrders[0];
        	if(o != null){
                System.Debug('**** TPS:EH 2.1 o=' + o);
                if(o.CC_Auth_Amount__c != o.Total_Gross_Price__c && o.Total_Gross_Price__c>0){
                    System.Debug('**** TPS:EH 2.2 o=' + o);
                	svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
                	svcRes.Error='Order Total Gross Price does not match CC Auth Amount.';
                    return mapSvcRes;
                }
                
            if(o.CC_Trans_Status__c != null && o.Payment_Id__c!= null && o.CC_Auth_Amount__c != null && o.Settlement_Id__c != null){
            	isDupe=true;    
            }
            if(ClsCheckRecursive.orderId != null ) {
                if(ClsCheckRecursive.orderId==o.Id) {
                	isDupe=true;    
                }   
            }            
            if(isDupe){
            	System.Debug('**** TPS:EH 3.1 settlePayment');
                svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
                svcRes.Error='Duplicate CC processing  error: This Order already has a payment Id and auth amount applied.';
                return mapSvcRes;
            }
                
                ClsCheckRecursive.orderId=o.Id;
            	//string req='{"orderInformation": {"amountDetails": {"totalAmount": "{TotalAmount}","currency": "' + o.CurrencyISOCode + '"}}}';
                string req='{ "clientReferenceInformation": { "code": "[OrderNumber]" }, "orderInformation": {"amountDetails": {"totalAmount": "[TotalAmount]","currency": "' + o.CurrencyISOCode + '"}}}';
                req=req.replace('[TotalAmount]', string.valueOf(o.Total_Gross_Price__c));
                req=req.replace('[OrderNumber]', string.valueOf(o.OrderNumber));
                
                System.Debug('**** TPS:EH 3.1 Authorize req=' + req);
                string PayId=o.Payment_Id__c;
                
                ClsCCAuthAndSettlementServiceHelper clsHelper= new ClsCCAuthAndSettlementServiceHelper();
                svcRes= clsHelper.SettleHelper(req, payId, o.CurrencyISOCode, svcRes);
                System.Debug('**** TPS:EH 3.2 authorizeAndSettlePayment svcRes=' + svcRes);
                
                o.CC_Trans_Status__c=svcRes.transStatus; 
                o.Settlement_Id__c=null; o.Settlement_Error__c=svcRes.error;
                if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.SUCCESS){
                    if(svcRes.paymentId != null && svcRes.settlementId != null){
                    	o.Settlement_Id__c= svcRes.settlementId; 
                        o.Settlement_Error__c=null;                       
                    }    
                } else if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.ERROR){
                    if(svcRes.paymentId != null){
                    	//o.Possible_Action__c= ErrorHelper(svcRes.paymentId, o.CurrencyISOCode);    
                    }
                }
				update o;
            } 
        } else {
        	svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
            svcRes.Error='Order does not have a finance detail record or associated finance detail record does nopt have token / primary / expiry/ cc address configured.';
        } // !lstOrders.isEmpty
        
        } // orderId != null
        return mapSvcRes;        
    }
    
     public static Map<Id, ClsCCAuthAndSettlementResponse> authorizeAndSettlePayment(Id orderId){
    	Map<Id, ClsCCAuthAndSettlementResponse> mapSvcRes= new Map<Id, ClsCCAuthAndSettlementResponse>();
        ClsCCAuthAndSettlementResponse svcRes= new ClsCCAuthAndSettlementResponse();
        mapSvcRes.put(orderId, svcRes); Boolean isDupe=false;       
        if(orderId != null){
        	Map<Order, Finance_Detail__c> mapOrderFD=new  Map<Order, Finance_Detail__c>();
            List<Order> lstOrders= new List<Order>([Select Id, OrderNumber, CurrencyISOCode, TotalAmount, Total_Gross_Price__c, AccountId, Account.IsPersonAccount, Account.FirstName, Account.LastName, Account.Name, Account.PersonEmail, Account.Owner.Email, 
                 Finance_Detail__r.Expiry_Date__c, Finance_Detail__r.Token__c, Finance_Detail__r.CC_Address__r.Address_Line_1__c, Payment_Id__c, CC_Auth_Amount__c, CC_Trans_Status__c, Settlement_Id__c,
                 Finance_Detail__r.CC_Address__r.City__c,  Finance_Detail__r.CC_Address__r.State__c, Finance_Detail__r.CC_Address__r.Postal_Code__c, Finance_Detail__r.CC_Address__r.Country__c, Account.Primary_Contact_Number__c 
                 from Order Where Id =:orderId AND Finance_Detail__r.Token__c != null 
             	 AND Finance_Detail__r.Expiry_Date__c != null AND Finance_Detail__r.CC_Address__c != null]);
        if(!lstOrders.isEmpty()){
            Order o=lstOrders[0];
            if(o != null){
                //If the Order has Total Gross Price as 0 then no need to invoke the service
                if(o.Total_Gross_Price__c == 0)
                {
                  svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.SUCCESS;  
                  mapSvcRes.put(orderId, svcRes);
                }
                else
                {
       if(o.Payment_Id__c!= null && o.CC_Auth_Amount__c!=null && o.CC_Trans_Status__c!=null && o.Settlement_Id__c !=null){
			isDupe=true;
	   }
       if(ClsCheckRecursive.orderId != null ) {
            if(ClsCheckRecursive.orderId==o.Id) {
                isDupe=true;    
            }   
	   }
                    
       if(isDupe){
       		System.Debug('**** TPS:EH 3.1 authorize Duplicate');
            svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
          	svcRes.Error='Duplicate CC processing  error: This Order already has a payment Id and auth amount applied.';
            return mapSvcRes;
       }
                    System.Debug('**** TPS:EH 2.1 o=' + o);
                    ClsCheckRecursive.orderId=o.id;
                    ClsCSPaymentAuthReq req= new ClsCSPaymentAuthReq();
                    ClsCSPaymentAuthReq.clientReferenceInformation cri= new ClsCSPaymentAuthReq.clientReferenceInformation();
                    cri.code=o.OrderNumber;
                    req.clientReferenceInformation=cri;
            
                    ClsCSPaymentAuthReq.processingInformation pi=new ClsCSPaymentAuthReq.processingInformation();
                    pi.commerceIndicator='internet'; pi.capture=true;
                    req.processingInformation=pi;
                    
                    ClsCSPaymentAuthReq.tokenizedCard tc= new ClsCSPaymentAuthReq.tokenizedCard();
                    tc.expirationMonth=o.Finance_Detail__r.Expiry_Date__c.split('\\/')[0]; tc.expirationYear=o.Finance_Detail__r.Expiry_Date__c.split('\\/')[1];
                    ClsCSPaymentAuthReq.customer cus= new ClsCSPaymentAuthReq.customer();
                    cus.customerId=o.Finance_Detail__r.Token__c;
                    ClsCSPaymentAuthReq.paymentInformation payi = new ClsCSPaymentAuthReq.paymentInformation();
                    payi.tokenizedCard=tc; payi.customer=cus; req.paymentInformation=payi;
                    
                    ClsCSPaymentAuthReq.orderInformation oi= new ClsCSPaymentAuthReq.orderInformation();
                    ClsCSPaymentAuthReq.amountDetails ad=new ClsCSPaymentAuthReq.amountDetails();
                    ad.totalAmount=string.valueOf(o.Total_Gross_Price__c); ad.currToRep=o.CurrencyISOCode; oi.amountDetails=ad;
                    
                    ClsCSPaymentAuthReq.billTo bt=  new ClsCSPaymentAuthReq.billTo();
                    if(o.Account.IsPersonAccount){
                    	bt.firstName=o.Account.FirstName; bt.lastName=o.Account.LastName;    
                    }else{                    	
                        bt.firstName=o.Account.Name; bt.lastname=o.Account.Name;
                    }
                    
                    bt.address1=o.Finance_Detail__r.CC_Address__r.Address_Line_1__c;
                    bt.locality=o.Finance_Detail__r.CC_Address__r.City__c;
                    bt.administrativeArea=o.Finance_Detail__r.CC_Address__r.State__c; 
                    bt.postalCode=o.Finance_Detail__r.CC_Address__r.Postal_Code__c; 
                    bt.country=o.Finance_Detail__r.CC_Address__r.Country__c;
                    
                    if (!ClsOrderEntryHandler.validateEmail(o.Account.PersonEmail))  bt.email='null@cybersource.com'; else bt.email = o.Account.PersonEmail;	
               		if (ClsOrderEntryHandler.validatePhone(o.Account.Primary_Contact_Number__c))  bt.phoneNumber = o.Account.Primary_Contact_Number__c;
                    oi.billTo=bt;
                    req.orderInformation=oi;
                    string reqAuth=Json.serialize(req, true).replace('"currToRep"','"currency"');
                    System.Debug('**** TPS:EH 3.1 Authorize req=' + reqAuth);
                    
                    ClsCCAuthAndSettlementServiceHelper clsHelper= new ClsCCAuthAndSettlementServiceHelper();
                    svcRes= clsHelper.AuthorizeHelper(reqAuth, o.CurrencyISOCode, svcRes);
                    System.Debug('**** TPS:EH 3.2 authorizeAndSettlePayment svcRes=' + svcRes);
                    string PaymentId=svcRes.paymentId;
                    
                    o.Payment_Id__c= svcRes.paymentId; o.CC_Trans_Status__c=svcRes.transStatus; 
                    o.Settlement_Id__c=null; o.Settlement_Error__c=svcRes.error; o.CC_Auth_Amount__c=null;
                    if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.SUCCESS){
                        if(svcRes.paymentId != null && svcRes.settlementId != null && svcRes.approvalCode != null){
                            o.Settlement_Id__c= svcRes.settlementId; 
                            o.Settlement_Error__c=null;
                            o.CC_Auth_Amount__c=svcRes.authorizedAmount;
                        }    
                    } else if(svcRes.status== ClsCCAuthAndSettlementResponse.enumStatus.ERROR){
                    	if(svcRes.paymentId != null){
                            System.Debug('**** TPS:EH 4.1 authorizeAndSettlePayment ResponseCode paymentId=' + svcRes.paymentId);
                            //ErrorHelper(o.Id, svcRes.paymentId, o.CurrencyISOCode);
                            //System.Debug('**** TPS:EH 4.2 authorizeAndSettlePayment Possible_Action__c=' + o.Possible_Action__c);
                        }    
                    }
                    update o;
                    
                }
            }
            mapSvcRes.put(orderId, svcRes);// added by Shailendra
        } else {
            	svcRes.Status=ClsCCAuthAndSettlementResponse.enumStatus.ERROR;
                svcRes.Error='Order does not have a finance detail record or associated finance detail record does nopt have token / primary / expiry/ cc address configured.';
        }
            
        }
         
        return mapSvcRes;
    }
}