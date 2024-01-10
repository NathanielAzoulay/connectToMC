@isTest
public with sharing class ColissimoIntegrationTest {
    @isTest 
    static void testCreateColissimoShipmentAndPrint() {

        // OrderDeliveryMethod deliveryMethod = new OrderDeliveryMethod(
        //     Name = 'Test'
        // );
        // insert deliveryMethod;

        // FulfillmentOrder fulfilmentRecord = new FulfillmentOrder( 
        //     Status = 'Draft',
        //     DeliveryMethodId = deliveryMethod.Id,
        //     FulfilledToName = 'Test'
        //        );
        // insert fulfilmentRecord;

        // Shipment shipmentRecord = new Shipment(
        //     FulfillmentOrderId = fulfilmentRecord.Id
        // );
        // insert shipmentRecord;

        // Test.startTest();
        // // Appelez la méthode que vous souhaitez tester
        // ColissimoIntegration.createLabel();
        // Test.stopTest();
        ColissimoIntegration colissimoIntegration = new ColissimoIntegration(); 
        colissimoIntegration.createLabel(
            // Passer des données de test ou des données fictives
            new List<Shippment_Mapping__mdt>(), 
            new List<Shipment_Item__mdt>(), 
            'International', 
            'FulfillmentId', 
            'ShipmentId',
            'Test'
        );
    }

    @isTest
    static void testColissimoIntegrationOutOfHomeDelivery() {
        // Créer des données de test si nécessaire

        // Instancier la classe ColissimoIntegration
        ColissimoIntegration colissimoIntegration = new ColissimoIntegration();

        // Appeler la méthode createLabel avec le service Out of home delivery
        colissimoIntegration.createLabel(
            // Passer des données de test ou des données fictives
            new List<Shippment_Mapping__mdt>(), 
            new List<Shipment_Item__mdt>(), 
            'Out of home delivery', 
            'FulfillmentId', 
            'ShipmentId',
            'Test'
        );

        // Ajouter des assertions pour vérifier que le comportement attendu s'est produit
        // Par exemple, vérifier que le corps de la requête HTTP est correct
        // Vérifier que les données de réponse sont correctement traitées
    }
}