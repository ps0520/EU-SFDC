public class GoogleStorageReadDoc extends HttpCallout {
	private String fileName;
	private String contentType;
	private Integer fileSize;
	private String fileBody;
	private String accessToken;
	public Boolean requiresAjaxCall;

	public static List<GoogleStorage__c> googleStorageSettings = GoogleStorage__c.getAll().values();
	private static final String MEDIA = 'media';
	private static final String RESUMABLE = 'resumable';
	private static final String AUTHOIZATION = 'Authorization';
	private static final String BEARER = 'Bearer ';
	private static final String CONTENT_TYPE = 'Content-Type';
	private static final String CONTENT_LENGTH = 'Content-Length';
	private static final String RANGE = 'Content-Range';
	private static final String PREDEFINED_CONTENT_TYPE = 'application/json; charset=UTF-8';

	public GoogleStorageReadDoc(String objectName) {
		super('GET', buildEndpoint(objectName));
		this.fileName = objectName;
		//this.contentType = contentType;
		//this.fileBody = fileBody;
		//this.fileSize = fileSize;
		setAccessToken();
		//setRequestBody();
		setHeaders();
	}

	private void setAccessToken() {
		GoogleAuthentication.AuthenticationResponse response =
                    GoogleAuthentication.getAccessToken(GoogleAuthentication.READ_SCOPE);
		this.accessToken = response.accessToken;
		this.requiresAjaxCall = response.requiresAjaxCall;
	}

	public void refreshAccessToken() {
		GoogleAuthentication.AuthenticationResponse response =
                    GoogleAuthentication.fetchNewAccessToken(GoogleAuthentication.READ_SCOPE);
		this.accessToken = response.accessToken;
		this.requiresAjaxCall = response.requiresAjaxCall;
	}

	private void setRequestBody() {
		this.request.setBodyAsBlob(EncodingUtil.base64Decode(this.fileBody));
	}

	private void setHeaders() {
		this.request.setHeader(AUTHOIZATION, BEARER + this.accessToken);
               // this.request.setHeader(CONTENT_TYPE, this.contentType);
               // this.request.setHeader(CONTENT_LENGTH, String.valueOf(this.fileSize));
	}

	public void setAuthorizationHeader(String accessToken) {
		this.request.setHeader(AUTHOIZATION, BEARER + accessToken);
	}

	private static Integer calculateFileSize(Integer startByte, Integer endByte) {
		return endByte - startByte;
	}
    
	private static String buildEndpoint(String fileName) {
        //return 'https://accounts.google.com/ServiceLogin?service=cds&passive=1209600&continue=https://storage.cloud.google.com/'
        //    + filename + '&followup=https://storage.cloud.google.com/' + filename;
        //eu-dev-claim-check-proof-of-delivery/eu.attachment.3pl.raw/content/5f9ce630-9bab-4d10-aa03-7517e0d5aa1f';
        //return googleStorageSettings[0].URL__c + googleStorageSettings[0].BucketName__c + '/o/' + fileName + '?alt=media' ;
        //return googleStorageSettings[0].URL__c + googleStorageSettings[0].BucketName__c + '/' + fileName ;
        return googleStorageSettings[0].URL__c + 'b/' + googleStorageSettings[0].BucketName__c + '/o/' + EncodingUtil.urlEncode(fileName, 'UTF-8') ; // ----- This is good and worked
        // return googleStorageSettings[0].URL__c + fileName ; // For use with id of the Object which includes bucket name
       /*
		return googleStorageSettings[0].URL__c + '/' + googleStorageSettings[0].BucketName__c + '/' + fileName 
                  + '?folder=true&organizationId=true';
		*/
	}
    public void setEndpoint(String media) {
        this.request.setEndPoint(media);
    }

	private static String buildRange(Integer startByte, Integer endByte) {
		return 'bytes=' + String.valueOf(startByte) + '-' + String.valueOf(endByte);
	}
}