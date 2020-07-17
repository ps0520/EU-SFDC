public class GoogleAuthentication {
    private final static String PRIVATE_KEY = 'privatekey'; // replace with what you named your jks token
    private final static String AUTH_ENDPOINT = 'https://www.googleapis.com/oauth2/v4/token';
   // private final static String AUTH_ENDPOINT = 'https://oauth2.googleapis.com/token';
    //private final static String AUTH_ENDPOINT = 'https://dexcomeu--dev.my.salesforce.com/services/authcallback/Google_Drive';
    private final static String JWS_SCOPE = 'scope';
    private final static String JWS_IAT = 'iat';
    private final static String JWS_EXP = 'exp';
    public final static String WRITE_SCOPE = 'https://www.googleapis.com/auth/cloud-platform';
    public final static String READ_SCOPE = 'https://www.googleapis.com/auth/devstorage.read_only';
    //public final static String ISS = 'https://www.googleapis.com/oauth2/v1/certs';
    public final static String ISS = 'it-itg-cc-pod-ro-svc-accnt@p8-integrations-eu-dev-2.iam.gserviceaccount.com';

    // Store the access token in custom settings to reuse accross transactions
    // private static GoogleStorage__c googleStorageSettings = GoogleStorage__c.getOrgDefaults();
	private static GoogleStorage__c googleStorageSettings = GoogleStorage__c.getAll().values()[0];
    /**
     * Scope is defined as : A space-delimited list of the permissions that the application requests.
     * Can be https://www.googleapis.com/auth/cloud-platform for example to edit and manage. Return an
     * AuthenticationResponse to inform code if we have commit to DB to not make another callout in
     * the same transaction.
     */
    public static AuthenticationResponse getAccessToken(String scope) {
        system.debug('Current Access Token Value: ' + googleStorageSettings.AccessToken__c);
        AuthenticationResponse response = new AuthenticationResponse(googleStorageSettings.AccessToken__c);
        if (response.accessToken == null) {
        	response = fetchNewAccessToken(scope);
        }
        return response;
    }

    /**
     * JSON Web Token (JWT) bundles private key and some additional required information 
     */
    public static AuthenticationResponse fetchNewAccessToken(String scope) {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setIss(ISS);
        String serviceAccountEmail = googleStorageSettings.ServiceAccountEmail__c;
        Map<String, Object> claimMap = buildClaimMap(scope);

        //jwt.setIss(serviceAccountEmail);
        jwt.setAud(AUTH_ENDPOINT);
        jwt.setAdditionalClaims(claimMap);

        // 'privatekey' cert created using java keytool converting p12 file obtained from google to jks
        Auth.JWS jws = new Auth.JWS(jwt, PRIVATE_KEY);
		//system.debug('JWS: ' + jws);
        //system.debug(jws.getCompactSerialization() );
        // may throw a Auth.JWTBearerTokenExchange.​JWTBearerTokenExchangeException​
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(AUTH_ENDPOINT, jws);
        //system.debug('Bearer TokenEndpoint: ' + bearer.getTokenEndpoint());
        //system.debug('Bearer JWS: ' + bearer.getJWS());
        //system.debug('Bearer Grant Type: ' + bearer.getGrantType());
       	//system.debug('Bearer httpStatus: ' + bearer.getHttpResponse() );
        //system.debug('Bearer httpStatus body: ' + bearer.getHttpResponse().getBody() );
        //system.debug('Bearer httpStatus Status: ' + bearer.getHttpResponse().getStatus() );
        //system.debug('Bearer httpStatus Status Code: ' + bearer.getHttpResponse().getStatusCode() );
        //system.debug('Bearor Error: ' + bearer.getHttpResponse().toString() );
        //system.debug('Bearer httpStatus HeaderKeys: ' + bearer.getHttpResponse().getHeaderKeys() );
        if (bearer.getHttpResponse().getStatusCode() == 302) {
            system.debug('Redirect Location: ' + bearer.getHttpResponse().getHeader('Location'));
			jwt.setAud(bearer.getHttpResponse().getHeader('Location'));
        }
        AuthenticationResponse response = new AuthenticationResponse(bearer.getAccessToken());

        if (response.accessToken != null) {
        	googleStorageSettings.AccessToken__c = response.accessToken;
        	update googleStorageSettings;
        	response.requiresAjaxCall = true;
        }

        return response;
    }

    private static Map<String, Object> buildClaimMap(String scope) {
        Map<String, Object> claimMap = new Map<String, Object>();
        String issueTime = getIssueTime();
        String expirationTime = getExpirationTime(issueTime);

        claimMap.put(JWS_SCOPE, scope);
        claimMap.put(JWS_IAT,   issueTime);
        claimMap.put(JWS_EXP,   expirationTime);

        return claimMap;
    }

    private static String getIssueTime() {
        Long timeSince = System.now().getTime();
        String iatTime = String.valueOf(timeSince);
        return iatTime;
    }

    private static String getExpirationTime(String issueTime) {
        Long longIssueTime = Long.valueOf(issueTime);
        String expTime = String.valueOf(longIssueTime + 3600);
        return expTime;
    }

    public class AuthenticationResponse {
        public String accessToken;
        public Boolean requiresAjaxCall; // Must use javascript to start another transaction

        public AuthenticationResponse(String accessToken) {
            this.accessToken = accessToken;
            this.requiresAjaxCall = false;
        }
    }
}