public class RefundJobUtility {

    public class RefundStandardOrder implements Queueable, Database.AllowsCallouts{
        public String orderId;
        public String refundAmount;
        
        public RefundStandardOrder(){}
		public RefundStandardOrder(String orderId,String refundAmount){
            this.orderId = orderId;
            this.refundAmount = refundAmount;
        }
		        
        public void execute(QueueableContext context) {
           
           // System.enqueueJob(new ClsCCAuthAndSettlementService.RefundPayment(orderId, orderId, refundAmount) );
            
        } 
        
    }
   
    
}