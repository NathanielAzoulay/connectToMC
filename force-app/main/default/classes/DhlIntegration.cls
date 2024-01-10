public with sharing class DhlIntegration extends CarrierClass {
    public override void createLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, String carrierService, String fulfillmentId, String shipmentId) { 
		//Get Metadata
		List<Shipment> shipmentOrder = listShipmentMetadata(shipingMetadataList, shipmentId); 
		List<ShipmentItem> shipmentItemOrder = listShipmentItemMetadata(shipingItemMetadataList, shipmentId); 
 
		//Call logic
		String requestBody = DhlInternationalLabel(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
 
		//Call WS
		HTTPResponse responseHttp = callWebService(requestBody); 

		// Traitement 
		processResponse(responseHttp, shipmentOrder, shipmentId);
	}
    public String DhlInternationalLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder,  List<ShipmentItem> shipmentItemOrder) {
        String contentText = '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7kgB3Ini+u1EOxTtSYGuFf0gBbAT/SQFWhDdkwIYRD0pgHvRgRRA3vZ+LygnyOVy+MXf2YalVs7zFs8WhwSRMv8lWKYiU3bFPAGg4GpACmVuZHN0cmVhbQplbmRvYmoKMTUgMCBvYmoKMjEyCmVuZG9iago5IDAgb2JqCjw8L0Jhc2VGb250L1BFU01LTitUVDVCNnQwMC9Gb250RGVzY3JpcHRvciA4IDAgUi9Ub1VuaWNvZGUgMTQgMCBSL1R5cGUvRm9udAovRmlyc3RDaGFyIDEvTGFzdENoYXIgMTEvV2lkdGhzWyA0NTkgNTc5IDUzMyA0ODcgNjQyIDU0MyA0ODggMjI2IDQyMCAyNTIgNjQ2XQovRW5jb2RpbmcgMTYgMCBSL1N1YnR5cGUvVHJ1ZVR5cGU+PgplbmRvYmoKMTYgMCBvYmoKPDwvVHlwZS9FbmNvZGluZy9CYXNlRW5jb2RpbmcvV2luQW5zaUVuY29kaW5nL0RpZmZlcmVuY2VzWwoxL2czOC9nNC9nMTgvZzEwMC9nMTA0L2c5MC9nMjgvZzMvZzYyL2c0Ny9nNjldPj4KZW5kb2JqCjggMCBvYmoKPDwvVHlwZS9Gb250RGVzY3JpcHRvci9Gb250TmFtZS9QRVNNS04rVFQ1QjZ0MDAvRm9udEJCb3hbMCAtOSA1NjEgNjM5XS9GbGFncyA0Ci9Bc2NlbnQgNjM5Ci9DYXBIZWlnaHQgNjM5Ci9EZXNjZW50IC05Ci9JdGFsaWNBbmdsZSAwCi9TdGVtViA4NAovTWlzc2luZ1dpZHRoIDUwNgovRm9udEZpbGUyIDEyIDAgUj4+CmVuZG9iagoyIDAgb2JqCjw8L1Byb2R1Y2VyKEdQTCBHaG9zdHNjcmlwdCA4LjE1KQovQ3JlYXRpb25EYXRlKEQ6MjAyMjAxMDYxNDQ3NDIpCi9Nb2REYXRlKEQ6MjAyMjAxMDYxNDQ3NDIpCi9UaXRsZShcKE1pY3Jvc29mdCBQb3dlclBvaW50IC0gTm91dmVhdSBQclxcMzUxc2VudGF0aW9uIE1pY3Jvc29mdCBQb3dlclBvaW50LnBwdHhcKSkKL0NyZWF0b3IoUFNjcmlwdDUuZGxsIFZlcnNpb24gNS4yLjIpCi9BdXRob3IoZnBhc3NhdmUpPj5lbmRvYmoKeHJlZgowIDE3CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDUyNCAwMDAwMCBuIAowMDAwMDEwNTQxIDAwMDAwIG4gCjAwMDAwMDA0NTYgMDAwMDAgbiAKMDAwMDAwMDI5NiAwMDAwMCBuIAowMDAwMDAwMDE1IDAwMDAwIG4gCjAwMDAwMDAyNzcgMDAwMDAgbiAKMDAwMDAwMDU3MiAwMDAwMCBuIAowMDAwMDEwMzQ1IDAwMDAwIG4gCjAwMDAwMTAwMTYgMDAwMDAgbiAKMDAwMDAwMDYxMyAwMDAwMCBuIAowMDAwMDAwNjQzIDAwMDAwIG4gCjAwMDAwMDA2NzMgMDAwMDAgbiAKMDAwMDAwOTY5MiAwMDAwMCBuIAowMDAwMDA5NzEzIDAwMDAwIG4gCjAwMDAwMDk5OTYgMDAwMDAgbiAKMDAwMDAxMDIyMSAwMDAwMCBuIAp0cmFpbGVyCjw8IC9TaXplIDE3IC9Sb290IDEgMCBSIC9JbmZvIDIgMCBSCi9JRCBbKNReCMMi9VWoB8RcbnAMMyHdKSjUXgjDIvVVqAfEXG5wDDMh3SldCj4+CnN0YXJ0eHJlZgoxMDc5MQolJUVPRgo=';
        String signatureText = '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';
       
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'plannedShippingDateAndTime' => getValueFromMdt('plannedShippingDateAndTime', shipingMetadataList, shipmentOrder, null),
            'pickup' => new Map<String, Object>{
                'isRequested' => Boolean.valueOf(getValueFromMdt('pickup.isRequested', shipingMetadataList, shipmentOrder, null))
            }, 
            'productCode' => getValueFromMdt('productCode', shipingMetadataList, shipmentOrder, null),
            'getRateEstimates' => Boolean.valueOf(getValueFromMdt('getRateEstimates', shipingMetadataList, shipmentOrder, null)),
            'accounts' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'typeCode' => getValueFromMdt('accounts[0].typeCode', shipingMetadataList, shipmentOrder, null),
                    'number' => getValueFromMdt('accounts[0].number', shipingMetadataList, shipmentOrder, null)
                }
            },
            'valueAddedServices' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'serviceCode' => getValueFromMdt('valueAddedServices[0].serviceCode', shipingMetadataList, shipmentOrder, null)
                }
            },
            'outputImageProperties' => new Map<String, Object>{
                'printerDPI' => Decimal.valueOf(getValueFromMdt('outputImageProperties.printerDPI', shipingMetadataList, shipmentOrder, null)),
                'encodingFormat' => getValueFromMdt('outputImageProperties.encodingFormat', shipingMetadataList, shipmentOrder, null),
                'imageOptions' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'typeCode' => getValueFromMdt('outputImageProperties.imageOptions[0].typeCode', shipingMetadataList, shipmentOrder, null),
                        'invoiceType' => getValueFromMdt('outputImageProperties.imageOptions[0].invoiceType', shipingMetadataList, shipmentOrder, null),
                        'templateName' => getValueFromMdt('outputImageProperties.imageOptions[0].templateName', shipingMetadataList, shipmentOrder, null),
                        'isRequested' => Boolean.valueOf(getValueFromMdt('outputImageProperties.imageOptions[0].isRequested', shipingMetadataList, shipmentOrder, null))
                    },
                    new Map<String, Object>{
                        'typeCode' => getValueFromMdt('outputImageProperties.imageOptions[1].typeCode', shipingMetadataList, shipmentOrder, null),
                        'templateName' => getValueFromMdt('outputImageProperties.imageOptions[1].templateName', shipingMetadataList, shipmentOrder, null)
                    }
                }
            },
            'customerReferences' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'value' => getValueFromMdt('customerReferences[0].value', shipingMetadataList, shipmentOrder, null),
                    'typeCode' => getValueFromMdt('customerReferences[0].typeCode', shipingMetadataList, shipmentOrder, null)
                }
            },
            'customerDetails' => new Map<String, Object>{
                'shipperDetails' => new Map<String, Object>{
                    'postalAddress' => new Map<String, Object>{
                        'postalCode' => getValueFromMdt('customerDetails.shipperDetails.postalAddress.postalCode', shipingMetadataList, shipmentOrder, null),
                        'cityName' => getValueFromMdt('customerDetails.shipperDetails.postalAddress.cityName', shipingMetadataList, shipmentOrder, null),
                        'countryCode' => getValueFromMdt('customerDetails.shipperDetails.postalAddress.countryCode', shipingMetadataList, shipmentOrder, null),
                        'addressLine1' => getValueFromMdt('customerDetails.shipperDetails.postalAddress.addressLine1', shipingMetadataList, shipmentOrder, null)
                    },
                    'contactInformation' => new Map<String, Object>{
                        'email' => getValueFromMdt('customerDetails.shipperDetails.contactInformation.email', shipingMetadataList, shipmentOrder, null),
                        'phone' => getValueFromMdt('customerDetails.shipperDetails.contactInformation.phone', shipingMetadataList, shipmentOrder, null),
                        'companyName' => getValueFromMdt('customerDetails.shipperDetails.contactInformation.companyName', shipingMetadataList, shipmentOrder, null),
                        'fullName' => getValueFromMdt('customerDetails.shipperDetails.contactInformation.fullName', shipingMetadataList, shipmentOrder, null)
                    },
                    'registrationNumbers' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'typeCode' => getValueFromMdt('customerDetails.shipperDetails.registrationNumbers[0].typeCode', shipingMetadataList, shipmentOrder, null),
                            'number' => getValueFromMdt('customerDetails.shipperDetails.registrationNumbers[0].number', shipingMetadataList, shipmentOrder, null),
                            'issuerCountryCode' => getValueFromMdt('customerDetails.shipperDetails.registrationNumbers[0].issuerCountryCode', shipingMetadataList, shipmentOrder, null)
                        }
                    },
                    'typeCode' => getValueFromMdt('customerDetails.shipperDetails.typeCode', shipingMetadataList, shipmentOrder, null)
                },
                'receiverDetails' => new Map<String, Object>{
                    'postalAddress' => new Map<String, Object>{
                        'postalCode' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.postalCode', shipingMetadataList, shipmentOrder, null),
                        'cityName' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.cityName', shipingMetadataList, shipmentOrder, null),
                        'countryCode' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.countryCode', shipingMetadataList, shipmentOrder, null),
                        'provinceCode' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.provinceCode', shipingMetadataList, shipmentOrder, null),
                        'addressLine1' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.addressLine1', shipingMetadataList, shipmentOrder, null),
                        'addressLine2' => getValueFromMdt('customerDetails.receiverDetails.postalAddress.addressLine2', shipingMetadataList, shipmentOrder, null)
                    },
                    'contactInformation' => new Map<String, Object>{
                        'phone' => getValueFromMdt('customerDetails.receiverDetails.contactInformation.phone', shipingMetadataList, shipmentOrder, null),
                        'companyName' => getValueFromMdt('customerDetails.receiverDetails.contactInformation.companyName', shipingMetadataList, shipmentOrder, null),
                        'fullName' => getValueFromMdt('customerDetails.receiverDetails.contactInformation.fullName', shipingMetadataList, shipmentOrder, null)
                    },
                    'typeCode' => getValueFromMdt('customerDetails.receiverDetails.typeCode', shipingMetadataList, shipmentOrder, null)
                }
            },
            'content' => new Map<String, Object>{
                'packages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'weight' => Decimal.valueOf(getValueFromMdt('content.packages[0].weight', shipingMetadataList, shipmentOrder, null)),
                        'dimensions' => new Map<String, Object>{
                            'length' => Decimal.valueOf(getValueFromMdt('content.packages[0].dimensions.length', shipingMetadataList, shipmentOrder, null)),
                            'width' => Decimal.valueOf(getValueFromMdt('content.packages[0].dimensions.width', shipingMetadataList, shipmentOrder, null)),
                            'height' => Decimal.valueOf(getValueFromMdt('content.packages[0].dimensions.height', shipingMetadataList, shipmentOrder, null))
                        }
                    }
                },
                'isCustomsDeclarable' => true/*getValueFromMdt('content.isCustomsDeclarable', shipingMetadataList, shipmentOrder, null)*/,
                'declaredValue' =>121.140/* getValueFromMdt('content.declaredValue', shipingMetadataList, shipmentOrder, null)*/,
                'declaredValueCurrency' => getValueFromMdt('content.declaredValueCurrency', shipingMetadataList, shipmentOrder, null),
                'exportDeclaration' => new Map<String, Object>{
                    'lineItems' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'number' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[0].number', shipingMetadataList, shipmentOrder, null)),
                            'description' => getValueFromMdt('content.exportDeclaration.lineItems[0].description', shipingMetadataList, shipmentOrder, null),
                            'price' =>  Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[0].price', shipingMetadataList, shipmentOrder, null)),
                            'priceCurrency' => getValueFromMdt('content.exportDeclaration.lineItems[0].priceCurrency', shipingMetadataList, shipmentOrder, null),
                            'quantity' => new Map<String, Object>{
                                'value' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[0].quantity.value', shipingMetadataList, shipmentOrder, null)),
                                'unitOfMeasurement' => getValueFromMdt('content.exportDeclaration.lineItems[0].quantity.unitOfMeasurement', shipingMetadataList, shipmentOrder, null)
                            },
                            'commodityCodes' => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[0].commodityCodes[0].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[0].commodityCodes[0].value', shipingMetadataList, shipmentOrder, null)
                                },
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[0].commodityCodes[1].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[0].commodityCodes[1].value', shipingMetadataList, shipmentOrder, null)
                                }
                            },
                            'exportReasonType' => getValueFromMdt('content.exportDeclaration.lineItems[0].exportReasonType', shipingMetadataList, shipmentOrder, null),
                            'manufacturerCountry' => getValueFromMdt('content.exportDeclaration.lineItems[0].manufacturerCountry', shipingMetadataList, shipmentOrder, null),
                            'weight' => new Map<String, Object>{
                                'netValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[0].weight.netValue', shipingMetadataList, shipmentOrder, null)),
                                'grossValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[0].weight.grossValue', shipingMetadataList, shipmentOrder, null))
                            }
                        },
                        new Map<String, Object>{
                            'number' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[1].number', shipingMetadataList, shipmentOrder, null)),
                            'description' => getValueFromMdt('content.exportDeclaration.lineItems[1].description', shipingMetadataList, shipmentOrder, null),
                            'price' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[1].price', shipingMetadataList, shipmentOrder, null)),
                            'priceCurrency' => getValueFromMdt('content.exportDeclaration.lineItems[1].priceCurrency', shipingMetadataList, shipmentOrder, null),
                            'quantity' => new Map<String, Object>{
                                'value' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[1].quantity.value', shipingMetadataList, shipmentOrder, null)),
                                'unitOfMeasurement' => getValueFromMdt('content.exportDeclaration.lineItems[1].quantity.unitOfMeasurement', shipingMetadataList, shipmentOrder, null)
                            },
                            'commodityCodes' => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[1].commodityCodes[0].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[1].commodityCodes[0].value', shipingMetadataList, shipmentOrder, null)
                                },
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[1].commodityCodes[1].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[1].commodityCodes[1].value', shipingMetadataList, shipmentOrder, null)
                                }
                            },
                            'exportReasonType' => getValueFromMdt('content.exportDeclaration.lineItems[1].exportReasonType', shipingMetadataList, shipmentOrder, null),
                            'manufacturerCountry' => getValueFromMdt('content.exportDeclaration.lineItems[1].manufacturerCountry', shipingMetadataList, shipmentOrder, null),
                            'weight' => new Map<String, Object>{
                                'netValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[1].weight.netValue', shipingMetadataList, shipmentOrder, null)),
                                'grossValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[1].weight.grossValue', shipingMetadataList, shipmentOrder, null))
                            }
                        },
                        new Map<String, Object>{
                            'number' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[2].number', shipingMetadataList, shipmentOrder, null)),
                            'description' => getValueFromMdt('content.exportDeclaration.lineItems[2].description', shipingMetadataList, shipmentOrder, null),
                            'price' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[2].price', shipingMetadataList, shipmentOrder, null)),
                            'priceCurrency' => getValueFromMdt('content.exportDeclaration.lineItems[2].priceCurrency', shipingMetadataList, shipmentOrder, null),
                            'quantity' => new Map<String, Object>{
                                'value' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[2].quantity.value', shipingMetadataList, shipmentOrder, null)),
                                'unitOfMeasurement' => getValueFromMdt('content.exportDeclaration.lineItems[2].quantity.unitOfMeasurement', shipingMetadataList, shipmentOrder, null)
                            },
                            'commodityCodes' => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[2].commodityCodes[0].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[2].commodityCodes[0].value', shipingMetadataList, shipmentOrder, null)
                                },
                                new Map<String, Object>{
                                    'typeCode' => getValueFromMdt('content.exportDeclaration.lineItems[2].commodityCodes[1].typeCode', shipingMetadataList, shipmentOrder, null),
                                    'value' => getValueFromMdt('content.exportDeclaration.lineItems[2].commodityCodes[1].value', shipingMetadataList, shipmentOrder, null)
                                }
                            },
                            'exportReasonType' => getValueFromMdt('content.exportDeclaration.lineItems[2].exportReasonType', shipingMetadataList, shipmentOrder, null),
                            'manufacturerCountry' => getValueFromMdt('content.exportDeclaration.lineItems[2].manufacturerCountry', shipingMetadataList, shipmentOrder, null),
                            'weight' => new Map<String, Object>{
                                'netValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[2].weight.netValue', shipingMetadataList, shipmentOrder, null)),
                                'grossValue' => Decimal.valueOf(getValueFromMdt('content.exportDeclaration.lineItems[2].weight.grossValue', shipingMetadataList, shipmentOrder, null))
                            }
                        }
                    },
                    'invoice' => new Map<String, Object>{
                    'number' => getValueFromMdt('content.invoice.number', shipingMetadataList, shipmentOrder, null),
                    'date' => getValueFromMdt('content.invoice.date', shipingMetadataList, shipmentOrder, null),
                    'signatureName' => getValueFromMdt('content.invoice.signatureName', shipingMetadataList, shipmentOrder, null),
                    'signatureTitle' => getValueFromMdt('content.invoice.signatureTitle', shipingMetadataList, shipmentOrder, null),
                    'signatureImage' => signatureText
                },
                    'additionalCharges' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'value' => Decimal.valueOf(getValueFromMdt('content.additionalCharges[0].value', shipingMetadataList, shipmentOrder, null)),
                            'caption' => getValueFromMdt('content.additionalCharges[0].caption', shipingMetadataList, shipmentOrder, null),
                            'typeCode' => getValueFromMdt('content.additionalCharges[0].typeCode', shipingMetadataList, shipmentOrder, null)
                        },
                        new Map<String, Object>{
                            'value' => Decimal.valueOf(getValueFromMdt('content.additionalCharges[1].value', shipingMetadataList, shipmentOrder, null)),
                            'caption' => getValueFromMdt('content.additionalCharges[1].caption', shipingMetadataList, shipmentOrder, null),
                            'typeCode' => getValueFromMdt('content.additionalCharges[1].typeCode', shipingMetadataList, shipmentOrder, null)
                        }
                    }
                },
                'description' => getValueFromMdt('content.description', shipingMetadataList, shipmentOrder, null),
                'incoterm' => getValueFromMdt('content.incoterm', shipingMetadataList, shipmentOrder, null),
                'unitOfMeasurement' => getValueFromMdt('content.unitOfMeasurement', shipingMetadataList, shipmentOrder, null)
            },
            'documentImages' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'typeCode' => getValueFromMdt('documentImages[0].typeCode', shipingMetadataList, shipmentOrder, null),
                    'imageFormat' => getValueFromMdt('documentImages[0].imageFormat', shipingMetadataList, shipmentOrder, null),
                    'content' => contentText
                }
            },
            'requestOndemandDeliveryURL' => Boolean.valueOf(getValueFromMdt('requestOndemandDeliveryURL', shipingMetadataList, shipmentOrder, null)),
            'getOptionalInformation' => Boolean.valueOf(getValueFromMdt('getOptionalInformation', shipingMetadataList, shipmentOrder, null))
        };
        
        String requestBody = JSON.serialize(requestBodyMap);
		System.debug('@@' + requestBody);
		return requestBody;
    
    }

    public HttpResponse callWebService (String requestBody) {
		HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json'); 
		HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:Dhl', requestBody);
        String response = responseHttp.getBody();
        System.debug(response);
		return responseHttp; 
	}

    public void processResponse(HttpResponse responseHttp, List<Shipment> shipmentOrder, String shipmentId) {
        String response = responseHttp.getBody();

        if(responseHttp.getStatusCode() == 201) {
		    String startTagLabel = '"content":';
		    String endTagLabel = '"typeCode"';
		    SubstringMessage extractValueLabel = new SubstringMessage(response, startTagLabel, endTagLabel); 
            String valueLabel = extractValueLabel.extractedError;
            String messageToEncoding = valueLabel.replace('"', '').replace(',', '').replace(':', '');
            System.debug(messageToEncoding);
            Blob pdfBlob = EncodingUtil.base64Decode(messageToEncoding);

            String startTagTracking = '"trackingNumber":';
		    String endTagTracking = '"trackingUrl"';
		    SubstringMessage extractTracking = new SubstringMessage(response, startTagTracking, endTagTracking); 
            String valueTrackingNumber = extractTracking.extractedError;
            String trackingNumber = valueTrackingNumber.replace('"', '').replace(',', '').replace(':', '');
            System.debug('@@trackingNumber' + trackingNumber);

            String startTagUrlTracking = '"trackingUrl":';
		    String endTagUrlTracking = '"packages"';
		    SubstringMessage extractUrlTracking = new SubstringMessage(response, startTagUrlTracking, endTagUrlTracking); 
            String valueUrlTrackingNumber = extractUrlTracking.extractedError;
            String urlTrackingNumber = valueUrlTrackingNumber.replace('"', '').replace(',', '').replace(':', '');
            System.debug('urlTrackingNumber' + urlTrackingNumber);

            ContentVersion cv = new ContentVersion();
            cv.Title = 'DHL Label shipment';
            cv.PathOnClient = 'DHLLabel.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true; 
            cv.FirstPublishLocationId = shipmentId; 
            insert cv; 

		    shipmentOrder[0].TrackingNumber = trackingNumber;
		    shipmentOrder[0].TrackingUrl = urlTrackingNumber;
		    upsert shipmentOrder;
            Logs.infoShipment('Shipment', 'Create label dhl', responseHttp, response);
        } else {
            String startTagError = '"detail":';
		    String endTagError = '"title"';
		    SubstringMessage extractError = new SubstringMessage(response, startTagError, endTagError); 
            String valueError = extractError.extractedError;
            String messageError = valueError.replace('"', '').replace(',', '').replace(':', '');
            Logs.infoShipment('Shipment', 'Create label dhl', responseHttp, response);
            System.debug(messageError);
        }
    }
}