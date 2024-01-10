public with sharing class MarketingCloudApiHandelerClass {

    private static String accessToken;
    private static DateTime tokenExpiration;

    public static List<String> callWebServiceToken() {

        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'client_id' => '{!$Credential.Username}',
            'client_secret' => '{!$Credential.Password}',
            'account_id' => '7298397',
            'grant_type' => 'client_credentials'
        };

        String requestBody = JSON.serialize(requestBodyMap);
        HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json');
        HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:AuthToMC', requestBody);
        String response = responseHttp.getBody();
        System.debug('response: ' + response);  

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        if (responseHttp.getStatusCode() == 200) {

            String newToken = (String) responseMap.get('access_token');
            System.debug('newToken: ' + newToken);
            Integer expiresIn = (Integer) responseMap.get('expires_in');
            System.debug('expiresIn: ' + expiresIn);
            String accessToken = newToken;
            DateTime tokenExpiration = System.now().addSeconds(expiresIn - 90);
            System.debug('tokenExpiration: ' + tokenExpiration);

            List<String> variable = new List<String>();
            variable.add(accessToken);
            variable.add(String.valueOf(tokenExpiration));
            return variable;
        } else {
            throw new CalloutException('Error: ' + responseHttp.getStatusCode() + ' - ' + responseHttp.getStatus());
        } 
    }   


    public class RequestBodyWrapper {
        @InvocableVariable(label='Request Body' required=true)
        public String requestBody;
    } 

    public class OutputMCEvent {
        @InvocableVariable(label='List Message Key' required=true)
        public List<String> listMessageKey;
    } 
    @InvocableMethod(label='Send Email Multiple Recipients' description='Send Email Multiple Recipients')
    public static List<OutputMCEvent> callMCEventMail(RequestBodyWrapper [] param) {
        System.debug('@@param: ' + param);
        String accessToken = '';

        MarketingCloudTokenData__c tokenData = MarketingCloudTokenData__c.getValues('TokenData');
        if (tokenData == null || tokenData.TokenExpiration__c < System.now()) {
            List<String> variable = callWebServiceToken();
            accessToken = variable[0];
            tokenExpiration = DateTime.valueOf(variable[1]);
            String accessTokenPart1 = accessToken.substring(0, 255);
            String accessTokenPart2 = accessToken.substring(255,510);
            String accessTokenPart3 = accessToken.substring(510);
            tokenData.AccessTokenPart1__c = accessTokenPart1;
            tokenData.AccessTokenPart2__c = accessTokenPart2;
            tokenData.AccessTokenPart3__c = accessTokenPart3;
            tokenData.TokenExpiration__c = tokenExpiration;
        } else {
            accessToken = tokenData.AccessTokenPart1__c + tokenData.AccessTokenPart2__c + tokenData.AccessTokenPart3__c;
        }
    
        HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json');
        HttpRequestApiCreateLabel.addHeader('Authorization',  'Bearer ' + accessToken);
        HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:SendEmailMultipleRecipients', param[0].requestBody );
        system.debug('@@responseHttp: ' + responseHttp.getBody());
        List<String> variable = processResponse(responseHttp);
        List<OutputMCEvent> outputMCEventList = new List<OutputMCEvent>();
        OutputMCEvent outputMCEvent = new OutputMCEvent();
        outputMCEvent.listMessageKey = variable;
        outputMCEventList.add(outputMCEvent);
    

        upsert tokenData;
    
        return outputMCEventList;
    }

    public static List<String> processResponse (HttpResponse responseHttp) {
        List<String> listMessageKey = new List<String>();
        if (responseHttp.getStatusCode() == 202) {
            String response = responseHttp.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            List<Object> responses = (List<Object>) responseMap.get('responses');
            for (Object responseItem : responses) {
                Map<String, Object> responseItemMap = (Map<String, Object>) responseItem;
                String messageKey = (String) responseItemMap.get('messageKey');
                listMessageKey.add(messageKey);
            }
            System.debug('listMessageKey: ' + listMessageKey);
        } else {
            throw new CalloutException('Error: ' + responseHttp.getStatusCode() + ' - ' + responseHttp.getStatus());
        }
        return listMessageKey;
    }
}