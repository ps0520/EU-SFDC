public class ClsOUSTaxCalculator {
    @auraenabled
    public static String calculateTax(Id OrderId) {
        // Map<Id, double> Taxes = new Map<Id, double>();
        //Call the Fusion Rest Service to get Taxes
        Order o = [SELECT TotalAmount, Total_Gross_Price__c, Type, Shipping_Charges__c, Id, Count_of_Order_Line_Items__c, Need_To_Calculate_Tax__c, Tax_Exempt__c, Tax_Registration_Number__c, Payor__c, Payor_Bill_To_Address__c,
                   		  Customer_Bill_To_Address__r.Account__c, Customer_Bill_To_Address__c, Customer_Ship_To_Address__r.Account__c, Customer_Ship_To_Address__c,
	                      Customer_Ship_To_Address__r.Country__c, Warehouse__c, CurrencyIsoCode, OrderNumber, Payor__r.Tax_Registration_Number__c, Payor__r.Tax_Exempt__c,
                   		  Payor_Bill_To_Address__r.Country__c,
                   		  (SELECT Id, Unitprice, Quantity, TotalPrice FROM OrderItems) 
                   FROM Order WHERE Id = :OrderId];
        if (String.isNotBlank(o.Payor__c) && String.isBlank(o.Payor_Bill_To_Address__c)) return 'There is a Payor, please add Payor\'s Billing Address to the Order.';
        if (o.Need_To_Calculate_Tax__c != 'True' || (o.Tax_Exempt__c && !(String.isNotBlank(o.Payor__c) && (o.type.startsWithIgnoreCase('GB') || o.type.startsWithIgnoreCase('IE'))))) return 'No need to calculate Tax';
        if ((o.TotalAmount == 0.00 && o.Count_of_Order_Line_Items__c == 0) || (o.Count_of_Order_Line_Items__c == 1 && o.Total_Gross_Price__c == o.Shipping_Charges__c && o.Total_Gross_Price__c > 0))  return 'Please add a Product before Calculating Tax';
        if(calculateTaxRemote(o) == 'Succeeded')        
	        return 'Exact VAT/TAX Calculated from Fusion System';
        else {
            if(o.Tax_Registration_Number__c != null || (String.isNotBlank(o.Payor__c) && (o.type.startsWithIgnoreCase('GB') || o.type.startsWithIgnoreCase('IE'))) || o.Type.StartsWithIgnoreCase('DIST') ){
				return 'Fusion Tax service is not reachable or encountered an error. Account has VAT Registration Number or a Payor for GB or IE or for \'Internation Distributor\'. So approximate tax cannot be calculated';
				
			}else{
			if (calculateTaxLocally(OrderId) == 'Succeeded') 
				return 'Approximate VAT/TAX Calculated in Salesforce';
			else return 'VAT/TAX Calculation Failed';
			}
        }
    }

	public static String calculateTaxRemote(Order o) {
        /*For now commenting this out as response is not yet coming. --- Please uncomment when not needed.*/
	    /*List<Order> lstOrder = [SELECT Id, Customer_Bill_To_Address__r.Account__c, Customer_Bill_To_Address__c, Customer_Ship_To_Address__r.Account__c, Customer_Ship_To_Address__c,
	                                   Customer_Ship_To_Address__r.Country__c, Warehouse__c, CurrencyIsoCode, OrderNumber, Tax_Registration_Number__c, 
	                                   (SELECT Id, Unitprice, Quantity, TotalPrice FROM OrderItems) 
	                             FROM Order WHERE Id =: OrderId];*/
	   
	    String responseBody = ClsOUSTaxCalculatorUtility.makeCallOut(o);
	    System.debug('==========responseBody======'+responseBody);
	    if(responseBody.containsIgnoreCase('ERROR')){
	        return 'Failed';
	    }else{
	        try{
    	        ClsOUSTaxCalculatorUtility.ResponseWrapper response = (ClsOUSTaxCalculatorUtility.ResponseWrapper)JSON.deserialize(responseBody, ClsOUSTaxCalculatorUtility.ResponseWrapper.class);
    	        System.debug('==========response======'+response);
    	        List<OrderItem> lstOrderItem = new List<OrderItem>();
    	        for(Integer i = 0; i < o.OrderItems.size(); i++){
    		        ClsOUSTaxCalculatorUtility.ResultW result  = response.calculateTransactionTaxEstimateResponse.result[i];
    		        lstOrderItem.add(new OrderItem(Id = o.OrderItems[i].Id, Tax_Rate__c = Decimal.valueOf(result.TaxRate), Item_VAT_TAX__c = Decimal.valueOf(result.TaxAmount), Tax_Source__c = 'Fusion'));
    		    }
    		    System.debug('==========lstOrderItem======'+lstOrderItem);
    		    update lstOrderItem;
    		    update new Order(Id = o.Id, Need_To_Calculate_Tax__c = 'False');
    		    return 'Succeeded';
	        }catch(Exception ex){ 
	             return 'Failed';
	        }
	    }
    }
    public static String calculateTaxLocally(Id OrderId) {
        //Map<Id, double> Taxes = new Map<Id, double>();
        String result = 'Succeeded';
        double tax = 0.0;
        List<OrderItem> updateOlisList = new List<OrderItem>();
        //read all the line items in the order
        List<OrderItem> olis = [Select Order.ShippingCountryCode, order.Account.Tax_Exempt__c, id, Total_Price__c, order.Account.Tax_Registration_Number__c, Order.ShippingPostalCode from OrderItem where Orderid = :OrderId];
        for (OrderItem oli : olis) {
            tax = multiplicationFactor(oli.Order.ShippingCountryCode, oli.order.Account.Tax_Exempt__c, oli.order.Account.Tax_Registration_Number__c, oli.Order.ShippingPostalCode);
			updateOlisList.add(new OrderItem(id = oli.Id, Item_VAT_TAX__c = oli.Total_Price__c * tax, Tax_Rate__c = tax, Tax_Source__c = 'Salesforce'));
        }
        update updateOlisList; 
        update new Order(Id = OrderId, Need_To_Calculate_Tax__c = 'False');
        return result;
    }
    public static double multiplicationFactor(String cc, boolean taxExempt, String trn, String spc) {
        if ( cc == 'GB' && taxExempt) return 0.00;
        if ( cc == 'IE' && taxExempt) return 0.00;
		if ( cc == 'GB') {if (String.isNotBlank(trn)) return 0.00; else return 0.20; }
        if ( cc == 'AT') {if (String.isNotBlank(trn)) return 0.00; else return 0.20; }
        if ( cc == 'DE') {if (String.isNotBlank(trn)) return 0.00; else if (spc == '78266' /* Büsingen postal code */) return 0.077; else return 0.19; } 
        if ( cc == 'IE') {if (String.isNotBlank(trn)) return 0.00; else return 0.23; }
        if ( cc == 'CH' || cc == 'LI') return 0.077;
        if ( cc == 'NL') return 0.21;
        if ( cc == 'BE') {if (String.isNotBlank(trn)) return 0.00; else return 0.21;}
        if ( cc == 'ES') {if (String.isNotBlank(trn)) return 0.00; else return 0.21;}
        if ( cc == 'FR') {if (String.isNotBlank(trn)) return 0.00; else return 0.20;}
        return 0.00;
    }
}