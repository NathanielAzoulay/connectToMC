/**
----------------------------------------------------------------------
-- - Name              :  Logs
-- - Author            :  Bilal MOUSSI
-- - Description       :  Classe permettant l'insertion des logs dans l'objet Logs__c

-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks 
-- -----------          -----------                 --------         ------------------
-- 11-05-2021           Bilal MOUSSI                1.0              Initial version
---------------------------------------------------------------------------------------
*/
public with sharing class Logs {

    /**
     * info 
     * @description Save information log
     * @param  String className 
     * @param  String task 
     * @param  String description
     */
    public static void info(String className, String task, String description){
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        log.Description__c=description.abbreviate(10000);
        log.TaskName__c = task;
        log.log_level__c =Level.info.name();
        insert log;
    }

    /**
     * info 
     * @description Save information log from shipment
     * @param  String className 
     * @param  String task 
     * @param  String description
     */
    public static void infoShipment(String className, String task, HttpResponse HttpStatusCode, String response){
        Double responseStatus = HttpStatusCode.getStatusCode(); 
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        if (response.length() < 500 ) {
            log.Description__c=response; 
        }
        log.TaskName__c = task; 
        log.Http_status_code__c =responseStatus;
        log.log_level__c =Level.info.name();
        insert log;
        System.debug('@@resp' + response);
        if (response.length() > 500 ) {
            String attachmentName = 'response.txt';
            ContentVersion cv = new ContentVersion();
			cv.Title = 'titleAttachment';
			cv.PathOnClient = 'response.txt';
			cv.VersionData =  Blob.valueOf(response);
			cv.IsMajorVersion = true; 
			cv.FirstPublishLocationId = log.id;
            insert cv; 
        } 
        
    }

    /**
     * infos 
     * @description Save information log for List
     * @param  String className
     * @param  String task
     * @param  List<String> descriptions
     */
    public static void infos(String className, String task, List<String> descriptions){
        List<Logs__c> lLogToInsert = new List<Logs__c> ();
        for (String descr : descriptions){
            Logs__c log = new Logs__c();
            log.ClassName__c = className;
            log.Description__c=descr;
            log.TaskName__c = task;
            log.log_level__c =Level.info.name();
            lLogToInsert.add(log);
        }
        insert lLogToInsert;
    }

    /**
     * trace 
     * @description Save success log
     * @param  String className
     * @param  String task
     * @param  String description
     */
    public static void trace(String className,String task,String description ){
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        log.TaskName__c = task;
        log.Description__c=description;
        log.log_level__c = Level.trace.name();
        Insert log;
    }

    /**
     * error 
     * @description Save exception log
     * @param  String      className
     * @param  String      task
     * @param  Exception   e
     */
    public static void error(String className,String task, Exception e){
        Logs__c log = new Logs__c();
        log.TaskName__c = task;
        log.ClassName__c = className;
        log.Stacktrace__c = e.getStackTraceString();
        log.message_error__c = e.getMessage();
        log.log_level__c = Level.error.name();
        log.Line_Number__c = e.getLineNumber();
        Insert log;
    }

    /**
     * logHTTPRequest 
    * @description    Save HTTP request log
    * @param  String   className
    * @param  String  methodName
    * @param  String description
    * @param  HttpRequest request
    */
    public static void logHTTPRequest(String className, String methodName, String description, HttpRequest request){
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        log.TaskName__c = methodName;
    // log.Description__c = description;
        log.log_level__c = Level.info.name();
        if(request != null){
            log.http_request__c = request.getBody();
        }
        Insert log;
    }

    /**
     * logHTTPResponse 
     * @description Save HTTP response log
     * @param  String   className
     * @param  String  methodName
     * @param  String description
     * @param  HttpResponse    response
     */
    public static void logHTTPResponse(String className, String methodName, String description, HttpResponse response){
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        log.TaskName__c = methodName;
    // log.Description__c = description;
        log.log_level__c = Level.info.name();
        if(response != null){
            log.http_response__c = response.getBody();
            log.http_status_code__c = response.getStatusCode();         
        }
        Insert log;
    }
    
    /**
    * logHTTPResponseWithoutInsert 
    * @description Save HTTP response log
    * @param  String   className
    * @param  String  methodName
    * @param  String description
    * @param  HttpResponse    response
    */
    public static Logs__c logHTTPResponseWithoutInsert(String className, String methodName, String description, HttpResponse response){
        Logs__c log = new Logs__c();
        log.ClassName__c = className;
        log.TaskName__c = methodName;
        // log.Description__c = description;
        log.log_level__c = Logs.Level.info.name();
        if(response != null){
            log.http_response__c = response.getBody();
            log.http_status_code__c = response.getStatusCode();         
        }
        return log;
    }
    
    /**
     * Level
     * @description enumeration des level logs
     */
    public enum Level{
        info,
        trace,
        debug,
        error
     }
}