public class CarrierDispatcher {
    public static String dispatchCarrier(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, String className, String fulfillmentId, String shipmentId, String carrierService, String getTypeShipment) {
        try {
            Type carrierClassType = Type.forName(className);
            CarrierClass carrierInstance = (CarrierClass)carrierClassType.newInstance();

            String result = carrierInstance.createLabel(shipingMetadataList, shipingItemMetadataList, carrierService, fulfillmentId, shipmentId, getTypeShipment); 
            return result; 
        } catch (Exception e) { 
            // Gérer les erreurs en fonction de vos besoins
            System.debug('Erreur lors de la création de l\'instance de la classe : ' + e.getMessage());
        }
    return null;
    }
}