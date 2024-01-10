public with sharing class TriggerMarketingCloud {

    public class TriggerMarketingCloudParameters {
        @InvocableVariable(label='EventDefinitionKey' required = true )
        public String eventKey;
        @InvocableVariable(label='ContactKey' required = true )
        public String ContactKey;
        @InvocableVariable(label='Email Address' required = true )
        public String email;
        @InvocableVariable(label='Json Data' required = true )
        public String jsonData;
    }
    
     @InvocableMethod(label='MCFireEntryEvent')
    public static void MCFireEntryEvent(TriggerMarketingCloudParameters[] param) {
        
        for(TriggerMarketingCloudParameters params : param){
        try {
        String eventKey = params.eventKey;
        String ContactKey = params.ContactKey;
        String email = params.email;
        String jsonData =params.jsonData;
        
        //-----------------MarketingCloudOAuth();
        //
        //

        String clientId = '9d2jxiieuvcgl0jajsu55r7c';
        String clientSecret = 'yzZcuwUVYk8TKFt2KM3NS57N';
        String accountID = '7298397';
        String jsonBody = GetAccessTokenJsonBody(clientId, clientSecret, accountID).getAsString(); 
        String authURL = 'https://mctv1-6js5tcmn66b24mhj283jdm.auth.marketingcloudapis.com';
        String accessToken;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authURL);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(jsonBody);

        HttpResponse res = h.send(req);
        String responseBody = res.getBody();
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        if(res.getStatusCode() == 200){
            accessToken = 'Bearer '+result.get('access_token').toString();
            }
       
        //
        //
        //
        
        String EventJsonBody = GetEventInteractionJSONBody(ContactKey, email, eventKey).getAsString();  
        Http eventHttp = new Http();
        HttpRequest eventReq = new HttpRequest();
        eventReq.setEndpoint('callout:MarketingCloud/interaction/v1/events');
        eventReq.setHeader('Content-Type', 'application/json');
        eventReq.setHeader('Authorization', '{!$Credential.OAuthToken}');
        eventReq.setMethod('POST');
        eventReq.setBody(EventJsonBody);
        
        HttpResponse eventRes = eventHttp.send(eventReq);
        String EventResponseBody = eventRes.getBody();
        Map<String, Object> EventResponseResult = (Map<String, Object>)JSON.deserializeUntyped(EventResponseBody);
        //if(eventRes.getStatusCode() == 201){
            system.debug('****** EventResponseBody:' + EventResponseBody);
        //}
        } catch(Exception e) {
            system.debug('****** MCFireEntryEvent-Expection:' + e);        
        }
    }
        }
public static JSONGenerator GetEventInteractionJSONBody(String contactKey, String email, String eventKey){
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('ContactKey', contactKey);
    gen.writeStringField('EventDefinitionKey', eventKey);
    gen.writeFieldName('Data');
    gen.writeStartObject();
    gen.writeStringField('ContactKey', contactKey);
    gen.writeStringField('Email Address', email);
    gen.writeEndObject();
    gen.writeEndObject();
    return gen;
}

public static JSONGenerator GetAccessTokenJsonBody(String clientID, String clientSecret, String accountID){
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('grant_type', 'client_credentials');
    gen.writeStringField('client_id', clientID);
    gen.writeStringField('client_secret', clientSecret);
    gen.writeStringField('account_id', accountID);
    gen.writeEndObject();
    return gen;
}
    
    
    //Attempt to use Named Credential
 public static void MarketingCloudOAuth(){
        
       // String authURL = 'your_auth_URL';
        String accessToken;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MC');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        
        String jsonBody = GetAccessTokenJsonBody('{!$Credential.Username}', '{!$Credential.Password}').getAsString(); 
        req.setBody(jsonBody);

        HttpResponse res = h.send(req);
        String responseBody = res.getBody();
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

        if(res.getStatusCode() == 200){
            accessToken = 'Bearer '+result.get('access_token').toString();
            }
       }

public static JSONGenerator GetAccessTokenJsonBody(String clientID, String clientSecret){
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('grant_type', 'client_credentials');
    gen.writeStringField('client_id', clientID);
    gen.writeStringField('client_secret', clientSecret);
    gen.writeEndObject();
    return gen;
}
}