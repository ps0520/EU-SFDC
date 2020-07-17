public with sharing class TPS_NewTOLiftController {
    @AuraEnabled(Cacheable = true)
    public static List<CampaignMember> getRecords(String recordId) {
        
        List<CampaignMember> campaignMembers = [SELECT Name, Status, CompanyOrAccount
        FROM CampaignMember
        WHERE CampaignId =: recordId];
        return campaignMembers;
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<ReturnProduct> getReturnProducts (String recordId) {
        List<ReturnProduct> retPrds= new List<ReturnProduct>();
    	List<Order> lstOrd=new List<Order>([Select Id, OrderNumber, RecordType.Name, Type, Status,Parent_Order__c, (Select Id, Quantity,Product2Id, Return_Reason__c from OrderItems) 
        	from Order Where Id=:recordId AND Parent_Order__c !=null AND Status='Draft' And Type Like '%RETURN%']);
        if(!lstOrd.isEmpty()){
            Order o=lstOrd[0];
            System.Debug('**** TPS:EH 1.1 getReturnProducts Order o=' + o);            
            Map<Id, integer> mapAvailableQty = getReturnedQtyByProductByOrder(o.Parent_Order__c);
            System.Debug('**** TPS:EH 1.2 mapAvailableQty=' + mapAvailableQty);
            
            for(OrderItem oi : [Select Id, Product2Id, Product2.ProductCode, Quantity, UnitPrice, PricebookEntryId, Return_Reason__c 
                                from OrderItem Where OrderId=:o.Parent_Order__c LIMIT 1000]){
            	ReturnProduct rp = new ReturnProduct();
                rp.Id=oi.Id; rp.productCode=oi.Product2.ProductCode; rp.ProductId=oi.Product2Id; 
                rp.UnitPrice=oi.UnitPrice; rp.PBEId=oi.PricebookEntryId; rp.ErrorQTY='No'; rp.ErrorRR='No'; rp.ReturnReason=''; rp.ReturnQty=0;
                if(mapAvailableQty.containsKey(oi.Product2Id)){
                	rp.AvailableQty=mapAvailableQty.get(oi.Product2Id);   
                }
                if(o.OrderItems != null){
                    for(OrderItem oiD : o.OrderItems){
                        if(oi.Product2Id==oiD.Product2Id){
                        	rp.ReturnQty=Math.Abs((Integer)oiD.Quantity);
                            rp.ReturnReason=oiD.Return_Reason__c;
                        }
                    }
                }
                retPrds.Add(rp);
                System.Debug('**** TPS:EH 1.4 getReturnProducts oi=' + oi);
            }
            
        }
		System.Debug('**** TPS:EH 1.3 retPrds=' + retPrds);
        return retPrds;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map<Id, integer> getReturnedQtyByProductByOrder(Id orderId){
    	Map<Id, integer> mapRet= new Map<Id, integer>();
        for(AggregateResult aggregatedOrderDetail : [Select product2Id , SUM(Quantity)
            from OrderItem Where (Order.Parent_Order__c=:orderId OR OrderId=:orderId) 
            AND Order.ActivatedDate != null AND Order.Status!='Cancelled' Group By product2Id]){
                
            String productId = (String)aggregatedOrderDetail.get('product2Id');
            Integer qty = Integer.valueOf(aggregatedOrderDetail.get('expr0'));
            System.debug('## productId=' + productId);
            System.debug('## qty=' + qty );
            mapRet.put(productId, qty);
		}
        return mapRet;
    }
    
    @AuraEnabled    
    public static List<String> getReturnReasonsList (string countryCode) {
    	List<String> lstRR= new List<String>();
        for(Order_Return_Reason__mdt rr : [Select Id, Return_Reason__c from Order_Return_Reason__mdt Where Country__c=:countryCode LIMIT 1]){
            if(rr.Return_Reason__c != null){
            	lstRR=	rr.Return_Reason__c.split(';');
            }
        }
        System.Debug('** TPS:EH getReturnReasonsList=' + lstRR);
        return lstRR;
    }
    public class ReturnProduct {
        @AuraEnabled public Boolean selected;
        @AuraEnabled public Id Id;
		@AuraEnabled public String ProductCode;
		@AuraEnabled public Id ProductId;        
		@AuraEnabled public integer AvailableQty;
		@AuraEnabled public integer ReturnQty;
        @AuraEnabled public decimal UnitPrice;
        @AuraEnabled public Id PBEId;
		@AuraEnabled public String ReturnReason;
        @AuraEnabled public String errorQTY;
        @AuraEnabled public String errorRR;
	}
}