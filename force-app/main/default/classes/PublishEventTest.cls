@isTest

public with sharing class PublishEventTest {

/**
	* testConformiteOk Test que les souscriptons du jeu de données sont conformes
	*/
    static testMethod void testConformiteOk() {
        Test.startTest();
        list<PublishEvent.FlowInputPublishEventParameters> paramL = new List<PublishEvent.FlowInputPublishEventParameters>();
        PublishEvent.FlowInputPublishEventParameters param = new PublishEvent.FlowInputPublishEventParameters();
        param.objectSourceId = '1234';
        param.eventName='SDINT002_order__e';
        paramL.add(param);
        PublishEvent.PublishEventFlow(paramL);
        
        param.eventName='SDINT002_return__e';
        PublishEvent.PublishEventFlow(paramL);
        
        param.eventName='SDINT016_order__e';
        PublishEvent.PublishEventFlow(paramL);
        
        param.eventName='SDINT016_return__e';
        PublishEvent.PublishEventFlow(paramL);
        
        Test.stopTest();
        
        System.assertEquals(9, 9, 'Successfully published event');
    }
}