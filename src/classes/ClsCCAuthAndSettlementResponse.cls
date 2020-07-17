public class ClsCCAuthAndSettlementResponse {    
   
    public string paymentId;
    public string settlementId;
    public string approvalCode;
    public decimal authorizedAmount;
    public enumStatus status;
    public string error;
    public string transStatus;
    public ClsCCAuthAndSettlementResponse(){}

	public enum enumStatus {NA, ERROR, SUCCESS }
}