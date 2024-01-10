public with sharing class UpsIntegration extends CarrierClass {

	public override void createLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, String carrierService, String fulfillmentId, String shipmentId) {  

        List<Shipment> shipmentOrder = listShipmentMetadata(shipingMetadataList, shipmentId); 
        //ShipmentItem shipmentItemOrder = listShipmentItemMetadata(shipingItemMetadataList, shipmentId);

		String requestBody = upsLabel(shipingMetadataList, shipmentOrder);
        
        HTTPResponse responseHttp = callWebService(requestBody);

        processResponse(responseHttp, shipmentOrder, shipmentId);
    }

    public String upsLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment> shipmentOrder) {

        Map<String, Object> shipmentRequest = new Map<String, Object>{
            'ShipmentRequest' => new Map<String, Object>{
                'Request' => new Map<String, Object>{
                    'SubVersion' => getValueFromMdt('Request.SubVersion', shipingMetadataList, shipmentOrder, null),
                    'RequestOption' => getValueFromMdt('Request.RequestOptions', shipingMetadataList, shipmentOrder, null),
                    'TransactionReference' => new Map<String, Object>{
                        'CustomerContext' => getValueFromMdt('Request.TransactionReference.CustomerContext', shipingMetadataList, shipmentOrder, null)
                    }
                },
                'Shipment' => new Map<String, Object>{ 
                    'Description' => getValueFromMdt('Shipment.Description', shipingMetadataList, shipmentOrder, null),
                    'Shipper' => new Map<String, Object>{
                        'Name' => getValueFromMdt('Shipment.Shipper.Name', shipingMetadataList, shipmentOrder, null),
                        'AttentionName' => getValueFromMdt('Shipment.Shipper.AttentionName', shipingMetadataList, shipmentOrder, null),
                        'TaxIdentificationNumber' => getValueFromMdt('Shipment.Shipper.TaxIdentificationNumber', shipingMetadataList, shipmentOrder, null),
                        'Phone' => new Map<String, Object>{
                            'Number' => getValueFromMdt('Shipment.Shipper.Phone.Number', shipingMetadataList, shipmentOrder, null),
                            'Extension' => getValueFromMdt('Shipment.Shipper.Phone.Extension', shipingMetadataList, shipmentOrder, null)
                        },
                        'ShipperNumber' => getValueFromMdt('Shipment.Shipper.ShipperNumber', shipingMetadataList, shipmentOrder, null),
                        'FaxNumber' => getValueFromMdt('Shipment.Shipper.FaxNumber', shipingMetadataList, shipmentOrder, null),
                        'Address' => new Map<String, Object>{
                            'AddressLine' =>getValueFromMdt('Shipment.Shipper.Address.AddressLine', shipingMetadataList, shipmentOrder, null),
                            'City' => getValueFromMdt('Shipment.Shipper.Address.City', shipingMetadataList, shipmentOrder, null),
                            'StateProvinceCode' => getValueFromMdt('Shipment.Shipper.Address.StateProvinceCode', shipingMetadataList, shipmentOrder, null),
                            'PostalCode' => getValueFromMdt('Shipment.Shipper.Address.PostalCode', shipingMetadataList, shipmentOrder, null),
                            'CountryCode' => getValueFromMdt('Shipment.Shipper.Address.CountryCode', shipingMetadataList, shipmentOrder, null)
                        }
                    },
                    'ShipTo' => new Map<String, Object>{
                        'Name' => getValueFromMdt('Shipment.ShipTo.Name', shipingMetadataList, shipmentOrder, null),
                        'AttentionName' => getValueFromMdt('Shipment.ShipTo.AttentionName', shipingMetadataList, shipmentOrder, null),
                        'Phone' => new Map<String, Object>{
                            'Number' => getValueFromMdt('Shipment.ShipTo.Phone.Number', shipingMetadataList, shipmentOrder, null)
                        },
                        'Address' => new Map<String, Object>{
                            'AddressLine' => getValueFromMdt('Shipment.ShipTo.Address.AddressLine', shipingMetadataList, shipmentOrder, null),
                            'City' => getValueFromMdt('Shipment.ShipTo.Address.City', shipingMetadataList, shipmentOrder, null),
                            'StateProvinceCode' => getValueFromMdt('Shipment.ShipTo.Address.StateProvinceCode', shipingMetadataList, shipmentOrder, null),
                            'PostalCode' => getValueFromMdt('Shipment.ShipTo.Address.PostalCode', shipingMetadataList, shipmentOrder, null),
                            'CountryCode' => getValueFromMdt('Shipment.ShipTo.Address.CountryCode', shipingMetadataList, shipmentOrder, null)
                        },
                        'Residential' => getValueFromMdt('Shipment.ShipTo.Residential', shipingMetadataList, shipmentOrder, null)
                    },
                    'ShipFrom' => new Map<String, Object>{
                        'Name' => getValueFromMdt('Shipment.ShipFrom.Name', shipingMetadataList, shipmentOrder, null),
                        'AttentionName' => getValueFromMdt('Shipment.ShipFrom.AttentionName', shipingMetadataList, shipmentOrder, null),
                        'Phone' => new Map<String, Object>{
                            'Number' => getValueFromMdt('Shipment.ShipFrom.Phone.Number', shipingMetadataList, shipmentOrder, null)
                        },
                        'FaxNumber' => getValueFromMdt('Shipment.ShipFrom.Phone.FaxNumber', shipingMetadataList, shipmentOrder, null),
                        'Address' => new Map<String, Object>{
                            'AddressLine' => getValueFromMdt('Shipment.ShipFrom.Address.AddressLine', shipingMetadataList, shipmentOrder, null),
                            'City' => getValueFromMdt('Shipment.ShipFrom.Address.City', shipingMetadataList, shipmentOrder, null),
                            'StateProvinceCode' => getValueFromMdt('Shipment.ShipFrom.Address.StateProvinceCode', shipingMetadataList, shipmentOrder, null),
                            'PostalCode' => getValueFromMdt('Shipment.ShipFrom.Address.PostalCode', shipingMetadataList, shipmentOrder, null),
                            'CountryCode' => getValueFromMdt('Shipment.ShipFrom.Address.CountryCode', shipingMetadataList, shipmentOrder, null)
                        }
                    },
                    'PaymentInformation' => new Map<String, Object>{
                        'ShipmentCharge' => new Map<String, Object>{
                            'Type' => getValueFromMdt('PaymentInformation.ShipmentCharge.Type', shipingMetadataList, shipmentOrder, null),
                            'BillShipper' => new Map<String, Object>{
                                'AccountNumber' => getValueFromMdt('PaymentInformation.ShipmentCharge.BillShipper.AccountNumber', shipingMetadataList, shipmentOrder, null)
                            }
                        }
                    },
                    'Service' => new Map<String, Object>{
                        'Code' => getValueFromMdt('Service.Code', shipingMetadataList, shipmentOrder, null),
                        'Description' => getValueFromMdt('Service.Description', shipingMetadataList, shipmentOrder, null)
                    },
                    'Package' => new Map<String, Object>{
                        'Description' => getValueFromMdt('Package.Description', shipingMetadataList, shipmentOrder, null),
                        'Packaging' => new Map<String, Object>{
                            'Code' => getValueFromMdt('Package.Packaging.Code', shipingMetadataList, shipmentOrder, null),
                            'Description' => getValueFromMdt('Package.Packaging.Description', shipingMetadataList, shipmentOrder, null)
                        },
                        'Dimensions' => new Map<String, Object>{
                            'UnitOfMeasurement' => new Map<String, Object>{
                                'Code' => getValueFromMdt('Package.Dimensions.UnitOfMeasurement.Code', shipingMetadataList, shipmentOrder, null),
                                'Description' => getValueFromMdt('Package.Dimensions.UnitOfMeasurement.Description', shipingMetadataList, shipmentOrder, null)
                            },
                            'Length' => getValueFromMdt('Package.Dimensions.Length', shipingMetadataList, shipmentOrder, null),
                            'Width' => getValueFromMdt('Package.Dimensions.Width', shipingMetadataList, shipmentOrder, null),
                            'Height' => getValueFromMdt('Package.Dimensions.Height', shipingMetadataList, shipmentOrder, null)
                        },
                        'PackageWeight' => new Map<String, Object>{
                            'UnitOfMeasurement' => new Map<String, Object>{
                                'Code' => getValueFromMdt('Package.PackageWeight.UnitOfMeasurement.Code', shipingMetadataList, shipmentOrder, null),
                                'Description' => getValueFromMdt('Package.PackageWeight.UnitOfMeasurement.Description', shipingMetadataList, shipmentOrder, null)
                            },
                            'Weight' => getValueFromMdt('Package.PackageWeight.Weight', shipingMetadataList, shipmentOrder, null)
                        }
                    }
                },
                'LabelSpecification' => new Map<String, Object>{
                    'LabelImageFormat' => new Map<String, Object>{
                        'Code' => getValueFromMdt('LabelSpecification.LabelImageFormat.Code', shipingMetadataList, shipmentOrder, null),
                        'Description' => getValueFromMdt('LabelSpecification.LabelImageFormat.Description', shipingMetadataList, shipmentOrder, null)
                    },
                    'HTTPUserAgent' =>getValueFromMdt('LabelSpecification.HTTPUserAgent.HTTPUserAgent', shipingMetadataList, shipmentOrder, null)
                }
            }
        }; 
        String requestBody = JSON.serialize(shipmentRequest);
        return requestBody;
    }

    public HttpResponse callWebService(String requestBody) {
                
        HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json');
        HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:UPS', requestBody);
        System.debug('@@http' + responseHttp);
        return responseHttp;
    }

    public void processResponse(HttpResponse responseHttp, List<Shipment> shipmentOrder, String shipmentId) {
        String response = responseHttp.getBody();
        System.debug('@@response:' + response);

        if (responseHttp.getStatusCode() == 200) {
            Logs.infoShipment('Shipment', 'Create label Ups', responseHttp, response); 

            String startTagLabel = '"GraphicImage"';
            String endTagLabel = '"HTMLImage"';
            SubstringMessage extracteur = new SubstringMessage(response, startTagLabel, endTagLabel); 
            String valeurExtraite = extracteur.extractedError;
            String messageToEncoding = valeurExtraite.replace('"', '').replace(',', '').replace(':', '');
            Blob pdfBlob = EncodingUtil.base64Decode(messageToEncoding);    

            String startTagLabelTrackingNumber = '"TrackingNumber"';
            String endTagLabelTrackingNumber = '"BaseServiceCharge"';
            SubstringMessage extracteurTrackingNumber = new SubstringMessage(response, startTagLabelTrackingNumber, endTagLabelTrackingNumber); 
            String valeurExtraiteTrackingNumber = extracteurTrackingNumber.extractedError;
            String trackingNumber = valeurExtraiteTrackingNumber.replace('"', '').replace(',', '').replace(':', '');
            //System.debug(trackingNumber);  

            ContentVersion cv = new ContentVersion();
            cv.Title = 'UPS Label shipment';
            cv.PathOnClient = 'UpsLabel.gif';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true; 
            cv.FirstPublishLocationId = shipmentId; 
            insert cv;  
            if (trackingNumber != null) {
				shipmentOrder[0].Parcel_Id__c = trackingNumber;
				shipmentOrder[0].TrackingNumber = trackingNumber;
				upsert shipmentOrder;
			}  
        } else {
            //Logs.info('Shipment', 'Create label colissimo', response);
            // user qui fait la, date, service, 200 ou autre, 
            // inserer la response si trop longue dans un fichier
            Logs.infoShipment('Shipment', 'Create label UPS', responseHttp, response); 
            String startTagLabel = '"message"';
            String endTagLabel = '"}]}}';
            SubstringMessage extracteur = new SubstringMessage(response, startTagLabel, endTagLabel);  
            String valeurExtraite = extracteur.extractedError;
            String messageToEncoding = valeurExtraite.replace('"', '').replace(',', '').replace(':', '');
           // System.debug(messageToEncoding);
        }
    }
}