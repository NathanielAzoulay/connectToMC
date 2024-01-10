@isTest 
public with sharing class ChronopostIntegrationTest {
    @isTest 
    static void testChronopostIntegrationFunc() {
         // Créer des enregistrements de test nécessaires 
        // Exemple : Créez un enregistrement de Shippment_Mapping__mdt et un enregistrement de Shipment pour les tests.

        // Préparez les données pour la méthode d'invocation
        //ColissimoIntegration.inputFromFlow input = new ColissimoIntegration.inputFromFlow();
        OrderDeliveryMethod deliveryMethod = new OrderDeliveryMethod(
            Name = 'Test'
        );
        insert deliveryMethod;
        FulfillmentOrder fulfilmentRecord = new FulfillmentOrder( 
            Status = 'Draft',
            DeliveryMethodId = deliveryMethod.Id,
            FulfilledToName = 'Test'
               );
        insert fulfilmentRecord;

        // Créez un enregistrement Shipment de test associé au Fulfilment
        Shipment shipmentRecord = new Shipment(
            FulfillmentOrderId = fulfilmentRecord.Id
        );
        insert shipmentRecord;

        // input.recordId = fulfilmentRecord.id;
        // input.shipmentId = shipmentRecord.id;

        // Test.startTest(); 
        // // Appelez la méthode que vous souhaitez tester
        // ChronopostIntegration.ChronopostIntegrationFunc();
        // Test.stopTest();
    }
}