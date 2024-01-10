public with sharing class PublishEvent {

    public class FlowInputPublishEventParameters {
        @InvocableVariable(label='record Id' required = true )
        public String objectSourceId;
        @InvocableVariable(label='Event Name' required = true )
        public String eventName;
    }
    /**
    * @description publish event 
    * @param FlowInputParameters Paramète du flux
    */
    @InvocableMethod(label='PublishEvent')
    public static void PublishEventFlow(FlowInputPublishEventParameters[] param) {
        String eventName;
        // System.debug('Step 1:'+param);
         
         for(FlowInputPublishEventParameters item : param){
        try {

            String ObjectSourceId = item.ObjectSourceId;
            eventName = item.eventName;
            Database.SaveResult sr;
                       /*
            if(eventName == 'SDINT002_order__e' ){
                SDINT002_order__e event = new SDINT002_order__e();
                event.Object_source_Id__c = ObjectSourceId;
                 sr = EventBus.publish(event);

            }else if(eventName == 'SDINT002_return__e'){
                SDINT002_return__e event = new SDINT002_return__e();
                event.Object_source_Id__c = ObjectSourceId;
                 sr = EventBus.publish(event);
            }else if(eventName == 'SDINT016_order__e'){
                SDINT016_order__e event = new SDINT016_order__e();
                event.Object_source_Id__c = ObjectSourceId;
                 sr = EventBus.publish(event);
            }else if(eventName == 'SDINT016_return__e'){
                SDINT016_return__e event = new SDINT016_return__e();
                event.Object_source_Id__c = ObjectSourceId;
                 sr = EventBus.publish(event);
            }*/
            System.debug('sr= '+sr);
            if (sr.isSuccess()) {
                Logs.info('PublishEvent', eventName, ObjectSourceId);
            } else {
                
                List<String> errors = new List<String>();
                for(Database.Error err : sr.getErrors()) {
                    errors.add(ObjectSourceId + ' : ' + err.getMessage());
                }
                Logs.infos('PublishEvent', eventName, errors );
            }
        } catch(Exception e) {
            Logs.error('PublishEvent',eventName, e);        
        }
             
         }
    } 
}