public with sharing class HttpRequestApiCreateLabel {
    public static lastHTTPReqInfo lastReq = new lastHTTPReqInfo();
	public static boolean  afterHTTP = false;

	public class lastHTTPReqInfo{
		public HttpRequest  lastReqInfo;
		public HttpResponse lastRespInfo;
		public Object objInfo;
	}

	static Http ws = new Http ();
	static Httprequest req  = new Httprequest ();

	public static void bearerAuthentication(string key){
		req.setHeader('Authorization', 'Bearer '+ key.trim());
	}

	public static void addHeader(string key,string value){
	 	req.setHeader(key, value);
	}

	public static HttpResponse send (string endpoint, string method, String body, Blob bodyDoc) {
		try{

			req.setTimeout (120000);
			if (null != body){
				req.setBody (body);
			}

			if (null != bodyDoc){
				req.setBodyAsBlob (bodyDoc); 
			}
			req.setEndpoint(endpoint);
			req.setMethod(method);

			//UtilsLogService.log_WS(req,null,'request','Debug');

			lastReq.lastReqInfo = req;
			lastReq.lastRespInfo = ws.send(req);
            System.debug('@@@lastReq.lastRespInfo: '+lastReq.lastRespInfo);
			//UtilsLogService.log_WS(req,lastReq.lastRespInfo,'response','Debug');

			req  = new Httprequest ();
			afterHTTP = true;
			if(lastReq !=null  && lastReq.lastRespInfo != null){
				// UtilsLogService.log('after:' +lastReq.lastRespInfo.getBody ());
				//System.debug(lastReq.lastRespInfo.getBody ());
				//System.debug(method);
				//System.debug(body);
				// UtilsLogService.save();
				return lastReq.lastRespInfo;
			}
		}catch(exception err){
			lastReq.lastRespInfo = new HttpResponse();
			lastReq.lastRespInfo.setStatusCode(500);
			lastReq.lastRespInfo.setBody('{"error":\"'+ err.getMessage() + '\"}');
			// UtilsLogService.error(err.getMessage());
			// UtilsLogService.save();
			return lastReq.lastRespInfo;
		}

		return null;
	}


	public static HttpResponse postData(string endpoint, string data) {
		return send (endpoint, 'POST', data, null);
	}

//    public static HTTPResponse makeHttpPost(String endpoint, String requestBody) {
//         Http http = new Http();
//         HttpRequest request = new HttpRequest();
//         request.setEndpoint(endpoint);
//         request.setMethod('POST');
//         request.setHeader('Content-Type', 'application/json');
//         request.setBody(requestBody); 

//         HttpResponse resp = http.send(request);
//        return resp;
//      }
}