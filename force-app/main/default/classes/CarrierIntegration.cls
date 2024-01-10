public class CarrierIntegration {
    public static String integrateCarrier(String fulfillmentId, String shipmentId, String deliveryCarrier, String carrierService, String getTypeShipment) {
        Carrier__mdt carrierMetadata = [SELECT Id, CarrierName__c, Class_Name__c FROM Carrier__mdt where CarrierName__c =: deliveryCarrier LIMIT 1];
        List<Shippment_Mapping__mdt> shipingMetadataList = [SELECT Json_Api_Name__c, Mapping_API__c, Hardcoded__c  FROM Shippment_Mapping__mdt WHERE service__c =: carrierMetadata.CarrierName__c ];
        List<Shipment_Item__mdt> shipingItemMetadataList = [SELECT Json_Api_Name__c, Mapping_API__c, Hardcoded__c  FROM Shipment_Item__mdt WHERE service__c =: carrierMetadata.CarrierName__c ];

        String result = CarrierDispatcher.dispatchCarrier(shipingMetadataList, shipingItemMetadataList, carrierMetadata.Class_Name__c, fulfillmentId, shipmentId, carrierService, getTypeShipment);
        return result; 
    }
}