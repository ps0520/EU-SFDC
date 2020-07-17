/********************************************************************************
@Author         : Pravin Jagadale
@Date Created   : 14/07/2020
@Description    : Class will Cover -EBS Tax Calculation  - REST API Call 
*********************************************************************************/
public class ClsCAEBSTaxCalculation {
    
    /* Personal Note - 2 fields Added on OrderItem
     * CA_GST_Tax_Amount__c
     * CA_PST_Tax_Amount__c
     * Item_VAT_TAX__c - will contains Sum of Both filed
    */
    
    public class RequestWrapper{
        public EBSTaxWrapper EbsWrapObj;
        public RequestWrapper(Order objOrder){
            this.EbsWrapObj = new EBSTaxWrapper(objOrder);
            System.debug('***EbsWrapObj--'+EbsWrapObj);
        }
    }
    
    // Class will accomodate the Header & TaxLineItem
    public class EBSTaxWrapper{
        
        public String CurrencyCode;
        public String OrderSource;
        public String Province;
        public String BillToAccountReference;
        public String ShipToAccountReference;
        public List<TaxLines> listTaxLines;
        
        public EBSTaxWrapper(Order objOrder){
            
            this.CurrencyCode = objOrder.Customer_Bill_To_Address__r.CurrencyIsoCode;
            this.OrderSource = objOrder.System_Of_Origin__c;
            this.Province = objOrder.Customer_Ship_To_Address__r.Postal_Code__c;
            this.BillToAccountReference = objOrder.Customer_Bill_To_Address__r.Account__c;
            this.ShipToAccountReference = objOrder.Customer_Ship_To_Address__r.Account__c;
            this.listTaxLines = new List<TaxLines>();
            for(Integer i = 1; i <= objOrder.OrderItems.size(); i++){ // OrderItems - SubQuery relationshipName Need to add Product_Name__c in Sub Query
                listTaxLines.add(new TaxLines(objOrder.OrderItems[i-1]));
            }
        }
    }
    
    
    // For EBS Request Serialization 
    public class TaxLines {
        public String LineId;
        public String Price;
        public String Quantity;
        public String Sku;
        
        public TaxLines(OrderItem Olitem){
            this.LineId = String.valueOf(Olitem.Id);  
            this.Price = String.valueOf(Olitem.Unitprice);
            this.Quantity = String.valueOf(Olitem.Quantity);
            this.Sku = String.valueOf(Olitem.Product_Name__c);
        }
    }
    
    
    // For EBS Response Deserialization 
    public class EBSResponseWrapper{ // LineItem
        public String LineId;
        public String Price;
        public String Quantity;
        public String Sku;
        public String TaxAmount;
        
        public EBSResponseWrapper(OrderItem Olitem){            
            this.LineId = String.valueOf(Olitem.Id);
            this.Price = String.valueOf(Olitem.Unitprice);
            this.Quantity = String.valueOf(Olitem.Quantity);
            this.Sku = String.valueOf(Olitem.Product_Name__c);
            this.TaxAmount = String.valueOf(Olitem.Item_VAT_TAX__c);
        }
    }
}