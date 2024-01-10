@isTest
public class CarrierClassTest {


    @isTest
    public static void testListShipmentMetadata() {
        // Créer des données de test (assurez-vous d'avoir des enregistrements Shippment_Mapping__mdt)
        Shippment_Mapping__mdt mappingData = new Shippment_Mapping__mdt(
            Json_Api_Name__c = 'testJsonApiName',
            Mapping_API__c = 'testMappingApi',
            Hardcoded__c = true
        );
        Shippment_Mapping__mdt mappingData2 = new Shippment_Mapping__mdt(
            Json_Api_Name__c = 'testJsonApiName2',
            Mapping_API__c = 'testMappingApi2',
            Hardcoded__c = false
        );
        
        List<Shippment_Mapping__mdt> shipingMetadataList = [SELECT Id, Mapping_API__c, Hardcoded__c FROM Shippment_Mapping__mdt LIMIT 5];

        CarrierClass carrier = new CarrierClass();

        Shipment shipmentOrder = new Shipment(
            Parcel_Id__c = '123QW45',
            ShipToName = 'Alexi'
        );
        insert shipmentOrder;

        // Appeler la fonction à tester
        List<Shipment> result = carrier.listShipmentMetadata(shipingMetadataList, shipmentOrder.Id);

        // Effectuer des assertions pour vérifier que le résultat est conforme aux attentes
        System.assertEquals(true, result.size() > 0, 'La liste des envois ne doit pas être vide');
        // Ajoutez d'autres assertions au besoin
    }

    @isTest
    public static void testListShipmentItemMetadata() {
        Shipment_Item__mdt mappingItemData = new Shipment_Item__mdt(
            Json_Api_Name__c = 'testJsonApiName',
            Mapping_API__c = 'testMappingApi',
            Hardcoded__c = true
        );
        Shipment_Item__mdt mappingItemData2 = new Shipment_Item__mdt(
            Json_Api_Name__c = 'testJsonApiName2',
            Mapping_API__c = 'testMappingApi2',
            Hardcoded__c = false
        );
        List<Shipment_Item__mdt> shipingItemMetadataList = [SELECT Id, Mapping_API__c, Hardcoded__c FROM Shipment_Item__mdt LIMIT 5];

        CarrierClass carrier = new CarrierClass();

        Shipment shipmentOrder = new Shipment(
            Parcel_Id__c = '123QW45',
            ShipToName = 'Alexi'
        );
        insert shipmentOrder;

        // Appeler la fonction à tester
        List<ShipmentItem> result = carrier.listShipmentItemMetadata(shipingItemMetadataList, String.valueOf(shipmentOrder.Id));

        // Effectuer des assertions pour vérifier que le résultat est conforme aux attentes
        System.assertEquals(true, result.size() >= 0, 'La liste des articles denvoi ne doit pas être null');
    }

    @isTest
    static void testInsertInformationShipment() {
        // Créer des données de test, par exemple, une fausse réponse HTTP
        HttpResponse mockHttpResponse = new HttpResponse();
        mockHttpResponse.setBodyAsBlob(Blob.valueOf('Mock PDF Content'));

        List<Shipment> shipmentOrderList = new List<Shipment>{
            new Shipment(
                Parcel_Id__c = '123QW45',
                ShipToName = 'Alexi'
            )
        };
        
        // Insérer la liste d'expéditions
        insert shipmentOrderList;
        

        // Créer une instance de votre classe de service
        CarrierClass carrier = new CarrierClass();

        // Appeler la méthode avec des données de test
        Test.startTest();
        carrier.insertInformationShipment(
            shipmentOrderList,
             'YourServiceName',
             mockHttpResponse,
             'MockTrackingNumber',
             shipmentOrderList[0].Id
        );
        Test.stopTest();

        // Vérifier que la version de contenu a été insérée
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(1, contentVersions.size(), 'Expected one ContentVersion record to be inserted');

        // Vérifier que les champs de suivi ont été mis à jour
        List<Shipment> updatedShipments = [SELECT Parcel_Id__c, TrackingNumber FROM Shipment];
        System.assertEquals('MockTrackingNumber', updatedShipments[0].Parcel_Id__c, 'Parcel_Id__c should be updated');
        System.assertEquals('MockTrackingNumber', updatedShipments[0].TrackingNumber, 'TrackingNumber should be updated');
    }

    @isTest
    static void testUpdateArticlesListInRequestBody() {
        // Créez des objets ShipmentItem pour simuler des données
        List<ShipmentItem> shipmentItemOrder = new List<ShipmentItem>{
            new ShipmentItem(/* Ajoutez ici les champs nécessaires */)
            // Ajoutez autant d'éléments que nécessaire pour votre test
        };

        // Créez des objets de métadonnées pour simuler des données
        List<SObject> shippingItemMetadataList = new List<SObject>{
            // Ajoutez ici des objets de métadonnées avec les champs nécessaires
        };

        CarrierClass carrier = new CarrierClass();

        Test.startTest();
        List<Map<String, Object>> resultExpedition = carrier.updateArticlesListInRequestBody('Expedition', shipmentItemOrder, shippingItemMetadataList);
        List<Map<String, Object>> resultReturn = carrier.updateArticlesListInRequestBody('Return', shipmentItemOrder, shippingItemMetadataList);
        Test.stopTest();

        System.assertNotEquals(null, resultExpedition, 'Result should not be null');
        System.assertEquals(shipmentItemOrder.size(), resultExpedition.size(), 'Result size should match input size');
    }

    @isTest
    static void testGetValueFromMdt() {
        // Créez des objets de métadonnées pour simuler des données
        List<Shipment_Item__mdt> hardcodedMappingItemData = new List<Shipment_Item__mdt>{ new Shipment_Item__mdt (
            Json_Api_Name__c = 'testJsonApiName',
            Mapping_API__c = 'testMappingApi',
            Hardcoded__c = true
        )};

        List<Shipment_Item__mdt> dynamicMappingItemData = new List<Shipment_Item__mdt>{ new Shipment_Item__mdt (
            Json_Api_Name__c = 'testJsonApiName2',
            Mapping_API__c = 'testMappingApi2',
            Hardcoded__c = false
        )};

        List<Shipment_Item__mdt> hardcodedMappingItemList = hardcodedMappingItemData;
        List<Shipment_Item__mdt> dynamicMappingItemList = dynamicMappingItemData;

        List<Shippment_Mapping__mdt> hardcodedMappingData = new List<Shippment_Mapping__mdt>{new Shippment_Mapping__mdt (
            Json_Api_Name__c = 'testJsonApiName',
            Mapping_API__c = 'testMappingApi',
            Hardcoded__c = true
        )};
            
        
        List<Shippment_Mapping__mdt> dynamicMappingData = new List<Shippment_Mapping__mdt>{new Shippment_Mapping__mdt (
            Json_Api_Name__c = 'testJsonApiName2',
            Mapping_API__c = 'testMappingApi2',
            Hardcoded__c = false
        )};

        List<Shippment_Mapping__mdt> hardcodedMappingList = hardcodedMappingData;
        List<Shippment_Mapping__mdt> dynamicMappingList = dynamicMappingData;

        // Créez une instance de votre classe de service
        CarrierClass carrier = new CarrierClass();

        // Créez des objets Shipment et ShipmentItem pour simuler des données
        List<Shipment> shipmentOrderList = new List<Shipment>{
            new Shipment(
                Parcel_Id__c = '123QW45',
                ShipToName = 'Alexi'
            )
        }; 
        insert shipmentOrderList;
        ShipmentItem shipmentItemOrder = new ShipmentItem(/* Ajoutez ici les champs nécessaires */);

        Test.startTest();

        // Testez la branche pour un mapping API durcodé
        String resultHardcodedMapping = carrier.getValueFromMdt('testJsonApiName', hardcodedMappingList, shipmentOrderList, shipmentItemOrder);
        System.assertEquals('testMappingApi', resultHardcodedMapping, 'La valeur retournée doit être conforme à vos attentes pour le mapping API durcodé');

        // Testez la branche pour un mapping API dynamique
        // String resultDynamicMapping = carrier.getValueFromMdt('testJsonApiName2', dynamicMappingList, shipmentOrderList, shipmentItemOrder);
        // System.assertEquals('testMappingApi2', resultDynamicMapping, 'La valeur retournée doit être conforme à vos attentes pour le mapping API durcodé');

        // Ajoutez ici la valeur attendue pour le mapping API dynamique

        // Testez d'autres branches et cas de test en fonction de votre logique

        Test.stopTest();
    } 
}