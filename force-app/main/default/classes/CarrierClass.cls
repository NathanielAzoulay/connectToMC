public virtual class CarrierClass {
    public virtual String createLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, String carrierService, String fulfillmentId, String shipmentId, String getTypeShipment) {
        return createLabel(shipingMetadataList, shipingItemMetadataList, carrierService, fulfillmentId, shipmentId, getTypeShipment);
    } 

    public virtual String getValueFromMdt(String jsonApiName, List<SObject> shipingMetadataList, List<Shipment> shipmentOrder, ShipmentItem shipmentItemOrder) {
        String result = '';
        Map<String, String> labelToApi = new Map<String, String>();
       
        for (SObject data : shipingMetadataList) {
            if (data instanceof Shippment_Mapping__mdt) {
                Shippment_Mapping__mdt mappingData = (Shippment_Mapping__mdt)data;
                labelToApi.put(jsonApiName, mappingData.Mapping_API__c);
               
                if (mappingData.Json_Api_Name__c == jsonApiName && mappingData.Hardcoded__c) {
                    if (labelToApi.get(jsonApiName) == null) {
                        result = '';
                    } else {
                        result = labelToApi.get(jsonApiName);
                    }
                    return result;
                } else if (mappingData.Json_Api_Name__c == jsonApiName && !mappingData.Hardcoded__c && !mappingData.Mapping_API__c.contains('.'))  {
                    result = String.valueOf(shipmentOrder[0].get(labelToApi.get(jsonApiName)));
                    return result;
                } else if (mappingData.Json_Api_Name__c == jsonApiName && !mappingData.Hardcoded__c && mappingData.Mapping_API__c.contains('.') ) {
                    String objectName = mappingData.Mapping_API__c.substringBefore('.');
                    if (objectName == 'OrderSummary') {
                        result = String.valueOf(shipmentOrder[0].OrderSummary.get(labelToApi.get(jsonApiName).substringAfter('.')));
                    } 
                    if (objectName == 'FulfillmentOrder') {
                        result = String.valueOf(shipmentOrder[0].FulfillmentOrder.get(labelToApi.get(jsonApiName).substringAfter('.')));
                    }
                    return result;
                }
            } else if (data instanceof Shipment_Item__mdt) {
                Shipment_Item__mdt itemData = (Shipment_Item__mdt)data;
                labelToApi.put(jsonApiName, itemData.Mapping_API__c);

                if (itemData.Json_Api_Name__c == jsonApiName && itemData.Hardcoded__c) {
                    if (labelToApi.get(jsonApiName) == null) {
                        result = '';
                    } else {
                        result = String.valueOf(labelToApi.get(jsonApiName));
                        return result;
                    }
                } else if (itemData.Json_Api_Name__c == jsonApiName && !itemData.Hardcoded__c && !itemData.Mapping_API__c.contains('.')) {
                    result = String.valueOf(shipmentItemOrder.get(labelToApi.get(jsonApiName)));
                    if (result.contains('.')) {
                        result = result.substringBefore('.');
                        return result;
                    } else {
                        return result;
                    }
                } else if (itemData.Json_Api_Name__c == jsonApiName && !itemData.Hardcoded__c && itemData.Mapping_API__c.contains('.')) {
                    String objectName = itemData.Mapping_API__c.substringBefore('.');
                    if (objectName == 'Product2') {
                        result = String.valueOf(shipmentItemOrder.Product2.get(labelToApi.get(jsonApiName).substringAfter('.')));
                    } 
                    if (objectName == 'FulfillmentOrderLineItem') {
                        result = String.valueOf(shipmentItemOrder.FulfillmentOrderLineItem.get(labelToApi.get(jsonApiName).substringAfter('.')));
                        return result;
                    }
                }
            }
        }
        return result;
    }
    
    public virtual List<Map<String, Object>> updateArticlesListInRequestBody(String typeRequest, List<ShipmentItem> shipmentItemOrder, List<SObject> shipingItemMetadataList) {
		List<Map<String, Object>> articlesList = new List<Map<String, Object>>();

        if (typeRequest == 'Expedition') {
		    for (ShipmentItem shipmentItem : shipmentItemOrder) {
		    	Map<String, Object> articleMap = new Map<String, Object>{ 
		    		'description' => getValueFromMdt('letter.customsDeclarations.contents.article.description', shipingItemMetadataList, null, shipmentItem),
		    		'quantity' => getValueFromMdt('letter.customsDeclarations.contents.article.quantity', shipingItemMetadataList, null, shipmentItem),
		    		'weight' => getValueFromMdt('letter.customsDeclarations.contents.article.weight', shipingItemMetadataList, null, shipmentItem),
		    		'value' => getValueFromMdt('letter.customsDeclarations.contents.article.value', shipingItemMetadataList, null, shipmentItem)
		    	};
		    	articlesList.add(articleMap);
		    }
        } else if (typeRequest == 'Return') {
            for (ShipmentItem shipmentItem : shipmentItemOrder) {
		    	Map<String, Object> articleMap = new Map<String, Object>{ 
                    'description' => getValueFromMdt('letter.customsDeclarations.contents.article.description', shipingItemMetadataList, null, shipmentItem),
                    'quantity' =>getValueFromMdt('letter.customsDeclarations.contents.article.quantity', shipingItemMetadataList, null, shipmentItem),
		    		'weight' => getValueFromMdt('letter.customsDeclarations.contents.article.weight', shipingItemMetadataList, null, shipmentItem),
		    		'value' => getValueFromMdt('letter.customsDeclarations.contents.article.value', shipingItemMetadataList, null, shipmentItem),
                    'hsCode' => getValueFromMdt('letter.customsDeclarations.contents.article.hsCode.ReturnInternational', shipingItemMetadataList, null, shipmentItem),
                    'originCountry' => getValueFromMdt('letter.customsDeclarations.contents.article.originCountry.ReturnInternational', shipingItemMetadataList, null, shipmentItem),
                    'currency' => getValueFromMdt('letter.customsDeclarations.contents.article.currency.ReturnInternational', shipingItemMetadataList, null, shipmentItem),
                    'artref' => getValueFromMdt('letter.customsDeclarations.contents.article.artref.ReturnInternational', shipingItemMetadataList, null, shipmentItem),
                    'originalIdent' => getValueFromMdt('letter.customsDeclarations.contents.article.originalIdent.ReturnInternational', shipingItemMetadataList, null, shipmentItem)
		    	};
		    	articlesList.add(articleMap);
		    }
        }
        return articlesList;
	}

    public virtual void insertInformationShipment(List<Shipment> shipmentOrder, String service, HttpResponse responseHttp, String trackingNumber, String shipmentId) {

        String titleAttachment = service+' '+ label.name_pdf_shipment;
        ContentVersion cv = new ContentVersion();
			cv.Title = titleAttachment;
			cv.PathOnClient = 'label.pdf';
			cv.VersionData =  responseHttp.getBodyAsBlob();
			cv.IsMajorVersion = true; 
			cv.FirstPublishLocationId = shipmentId;  
			insert cv; 
			if (trackingNumber != null) {
				shipmentOrder[0].Parcel_Id__c = trackingNumber;
				shipmentOrder[0].TrackingNumber = trackingNumber;
				upsert shipmentOrder;
			}  
    }

    public virtual List<Shipment> listShipmentMetadata(List<Shippment_Mapping__mdt> shipingMetadataList, String shipmentId) {
        List<String> serviceDataLabelApi = new List<String>();

		for (Shippment_Mapping__mdt serviceMetaData : shipingMetadataList) {
		    if (!serviceMetaData.Hardcoded__c) {
		        serviceDataLabelApi.add(serviceMetaData.Mapping_API__c);
		    }
		}

		String dataJsonShiping = String.join(serviceDataLabelApi, ',');
		
		String soqlQuery = 'SELECT Id, OrderSummaryId, Carrier_Service__c';
        if (dataJsonShiping.length() >= 2 ) {
            soqlQuery += ',' + dataJsonShiping + ' FROM Shipment WHERE Id = \'' + shipmentId + '\'';
        } else { 
            soqlQuery += ' FROM ShipmentItem WHERE ShipmentId = \'' + shipmentId + '\'';
        }
		
		List<Shipment> shipmentOrder= Database.query(soqlQuery);

        return shipmentOrder;
    }

    public virtual List<ShipmentItem> listShipmentItemMetadata(List<Shipment_Item__mdt> shipingItemMetadataList, String shipmentId) {
        List<String> serviceDataLabelApi = new List<String>();

		for (Shipment_Item__mdt serviceMetaData : shipingItemMetadataList) {
		    if (!serviceMetaData.Hardcoded__c) { 
		        serviceDataLabelApi.add(serviceMetaData.Mapping_API__c);
		    }
		}

        //System.debug(serviceDataLabelApi);
		String dataJsonShipingItem = String.join(serviceDataLabelApi, ',');
		
        //System.debug(dataJsonShipingItem);
        
		String soqlQuery = 'SELECT Id';
        if (dataJsonShipingItem.length() >= 2 ) {
            soqlQuery += ', ' + dataJsonShipingItem + ' FROM ShipmentItem WHERE ShipmentId = \'' + shipmentId + '\'';
        } else {
            soqlQuery += ' FROM ShipmentItem WHERE ShipmentId = \'' + shipmentId + '\'';
        }

        List<ShipmentItem> shipmentItemOrder = new List<ShipmentItem>();
        if (!String.isBlank(dataJsonShipingItem)) {
            shipmentItemOrder = Database.query(soqlQuery);
        }
        //System.debug(shipmentItemOrder);
        return shipmentItemOrder;
    }

}