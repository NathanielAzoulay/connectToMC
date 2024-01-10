public class CarrierFactory  {
    @InvocableMethod(label='Send Label' callout=true)
	public static List<OutputFromFlow> CreateField(
	List<inputFromFlow> requestList){        
		return createLabel(requestList[0]);

	} 
	
	public class inputFromFlow{
		@InvocableVariable(required=true)
		public String FulfillmentOrderId;
		
		@InvocableVariable(required=true)
		public String ShipmentId;
        
        @InvocableVariable(required=true)
		public String DeliveryCarrier;

		@InvocableVariable(required=true) 
		public String CarrierService;

		@InvocableVariable(required=true)
		public String GetShipmentType;
	}

	public class OutputFromFlow {
        @InvocableVariable(label='File ID')
        public String fileId;
    }

	public static List<OutputFromFlow> createLabel(inputFromFlow obj) {
		String fulfulId = obj.FulfillmentOrderId;
		String shiplId = obj.ShipmentId;
		String nameDelivery = obj.DeliveryCarrier;  
		String carrierService = obj.CarrierService;
		String getTypeShipment = obj.GetShipmentType;

		List<OutputFromFlow> results = new List<OutputFromFlow>();
		String fileId = CarrierIntegration.integrateCarrier(fulfulId, shiplId, nameDelivery, carrierService, getTypeShipment);
		OutputFromFlow result = new OutputFromFlow();
        result.fileId = fileId;
        results.add(result);
		return results;
	} 
}