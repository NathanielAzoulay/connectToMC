public class ColissimoIntegration extends CarrierClass {	

	public override String createLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, String carrierService, String fulfillmentId, String shipmentId, String getTypeShipment) { 
		//Get Metadata
		List<Shipment> shipmentOrder = listShipmentMetadata(shipingMetadataList, shipmentId); 
		List<ShipmentItem> shipmentItemOrder = listShipmentItemMetadata(shipingItemMetadataList, shipmentId); 
		System.debug(getTypeShipment);
		//Call logic
		String requestBody = '';
		if (getTypeShipment == 'Shipping' && carrierService == 'International') {  
			requestBody = colissimoInternationalLabel(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
		} else if (getTypeShipment == 'Shipping' && carrierService == 'Out of home delivery') {
			requestBody = colissimoOutOfHomeDelivery(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
		} else if (getTypeShipment == 'Return' && carrierService == 'International') {
			requestBody = colissimoReturnOutsideEU(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
		} else if (getTypeShipment == 'Return' && carrierService == 'InsideEU') {
			requestBody = colissimoReturnInsideEU(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
		} else if (getTypeShipment == 'Return' && carrierService == 'National') {
			requestBody = colissimoReturnFrance(shipingMetadataList, shipingItemMetadataList, shipmentOrder,  shipmentItemOrder);
		}

		//Call WS
		HTTPResponse responseHttp = callWebService(requestBody); 

		// Traitement 
		String variable = processResponse(responseHttp, shipmentOrder, shipmentId);
		return variable;
	}

	public String colissimoInternationalLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder,  List<ShipmentItem> shipmentItemOrder) {

		String accountNumber = '{!$Credential.Username}';
        String password = '{!$Credential.Password}';
		System.debug('International');
				
		Map<String, Object> requestBodyMap = new Map<String, Object>{
			'contractNumber' => accountNumber,
			'password' => password,
			'outputFormat' => new Map<String, Object>{
				'x' => getValueFromMdt('outputFormat.x', shipingMetadataList, shipmentOrder, null),
				'y' => getValueFromMdt('outputFormat.y', shipingMetadataList, shipmentOrder, null),
				'outputPrintingType' => getValueFromMdt('outputFormat.outputPrintingType', shipingMetadataList, shipmentOrder, null)
			},
			'letter' => new Map<String, Object>{
				'service' => new Map<String, Object>{
					'productCode' => getValueFromMdt('letter.service.productCode', shipingMetadataList, shipmentOrder, null),
					'depositDate' => getValueFromMdt('letter.service.depositDate', shipingMetadataList, shipmentOrder, null),
					'transportationAmount' => getValueFromMdt('letter.service.transportationAmount', shipingMetadataList, shipmentOrder, null),
					'totalAmount' => getValueFromMdt('letter.service.totalAmount', shipingMetadataList, shipmentOrder, null),
					'orderNumber' => getValueFromMdt('letter.service.orderNumber', shipingMetadataList, shipmentOrder, null),
					'commercialName' => getValueFromMdt('clientletter.service.commercialName', shipingMetadataList, shipmentOrder, null),
					'returnTypeChoice' => getValueFromMdt('letter.service.returnTypeChoice', shipingMetadataList, shipmentOrder, null)
				},
				'parcel' => new Map<String, Object>{
					'weight' => getValueFromMdt('letter.parcel.weight', shipingMetadataList, shipmentOrder, null)
				},
				'customsDeclarations' => new Map<String, Object>{
					'includeCustomsDeclarations' => Integer.valueOf(getValueFromMdt('letter.customsDeclarations.includeCustomsDeclarations', shipingMetadataList, shipmentOrder, null)), 
					'contents' => new Map<String, Object>{ 
						'article' => updateArticlesListInRequestBody('Expedition', shipmentItemOrder, shipingItemMetadataList),
						'category' => new Map<String, Object>{
							'value' => Integer.valueOf(getValueFromMdt('letter.customsDeclarations.contents.category.value.Expedition', shipingMetadataList, shipmentOrder, null))
						}
					}
				},
				'sender' => new Map<String, Object>{
					'senderParcelRef' => getValueFromMdt('letter.sender.senderParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'companyName' => getValueFromMdt('letter.sender.address.companyName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.sender.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.sender.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.sender.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.sender.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.sender.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.sender.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.sender.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				},
				'addressee' => new Map<String, Object>{
					'addresseeParcelRef' => getValueFromMdt('letter.addressee.addresseeParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'lastName' => getValueFromMdt('letter.addressee.address.lastName', shipingMetadataList, shipmentOrder, null),
						'firstName' => getValueFromMdt('letter.addressee.address.firstName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.addressee.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.addressee.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.addressee.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.addressee.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.addressee.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.addressee.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.addressee.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				}
			}
		};
		
		String requestBody = JSON.serialize(requestBodyMap);
		System.debug('@@' + requestBody);
		return requestBody;
		
	}

	public String colissimoOutOfHomeDelivery(List<Shippment_Mapping__mdt> shipingMetadataList,  List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder, List<ShipmentItem> shipmentItemOrder) {

		String accountNumber = '{!$Credential.Username}';
        String password = '{!$Credential.Password}';

		System.debug('OutOfHome');

		Map<String, Object> shipmentRequest  = new Map<String, Object>{
			'contractNumber' => accountNumber,
			'password' => password, 
			'outputFormat' => new Map<String, Object>{
				'x' => getValueFromMdt('outputFormat.x', shipingMetadataList, shipmentOrder, null),
				'y' => getValueFromMdt('outputFormat.y', shipingMetadataList, shipmentOrder, null),
				'outputPrintingType' => getValueFromMdt('outputFormat.outputPrintingType', shipingMetadataList, shipmentOrder, null)
			},
			'letter' => new Map<String, Object>{
				'service' => new Map<String, Object>{
					'productCode' => getValueFromMdt('letter.service.productCode', shipingMetadataList, shipmentOrder, null),
					'depositDate' => getValueFromMdt('letter.service.depositDate', shipingMetadataList, shipmentOrder, null),
					'orderNumber' => getValueFromMdt('letter.service.orderNumber', shipingMetadataList, shipmentOrder, null),
					'commercialName' => getValueFromMdt('clientletter.service.commercialName', shipingMetadataList, shipmentOrder, null)
				},
				'parcel' => new Map<String, Object>{
					'weight' => getValueFromMdt('letter.parcel.weight', shipingMetadataList, shipmentOrder, null),
					'pickupLocationId' => getValueFromMdt('letter.parcel.pickupLocationId', shipingMetadataList, shipmentOrder, null)
				},
				'sender' => new Map<String, Object>{
					'senderParcelRef' => getValueFromMdt('letter.sender.senderParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'companyName' => getValueFromMdt('letter.sender.address.companyName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.sender.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.sender.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.sender.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.sender.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.sender.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.sender.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.sender.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				},
				'addressee' => new Map<String, Object>{
					'addresseeParcelRef' => getValueFromMdt('letter.addressee.addresseeParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'lastName' => getValueFromMdt('letter.addressee.address.lastName', shipingMetadataList, shipmentOrder, null),
						'firstName' => getValueFromMdt('letter.addressee.address.firstName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.addressee.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.addressee.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.addressee.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.addressee.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.addressee.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.addressee.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.addressee.address.zipCode', shipingMetadataList, shipmentOrder, null),
						'mobileNumber' => getValueFromMdt('letter.addressee.address.mobileNumber', shipingMetadataList, shipmentOrder, null),
						'email' =>	getValueFromMdt('letter.addressee.address.email', shipingMetadataList, shipmentOrder, null)
					}
				} 
			}
		};

		String jsonMapping  = JSON.serialize(shipmentRequest); 
		System.debug('@@' + jsonMapping);
		return jsonMapping;
	}

	public String colissimoReturnFrance(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder,  List<ShipmentItem> shipmentItemOrder) {

		String accountNumber = '{!$Credential.Username}';
        String password = '{!$Credential.Password}';

		Map<String, Object> shipmentRequest  = new Map<String, Object>{
			'contractNumber' => accountNumber,
			'password' => password,
			'outputFormat' => new Map<String, Object>{
				'x' => getValueFromMdt('outputFormat.x', shipingMetadataList, shipmentOrder, null),
				'y' => getValueFromMdt('outputFormat.y', shipingMetadataList, shipmentOrder, null),
				'outputPrintingType' => getValueFromMdt('outputFormat.outputPrintingType', shipingMetadataList, shipmentOrder, null)
			},
			'letter' => new Map<String, Object>{
				'service' => new Map<String, Object>{
					'productCode' => getValueFromMdt('letter.service.productCode.ReturnFr', shipingMetadataList, shipmentOrder, null),
					'depositDate' => getValueFromMdt('letter.service.depositDate', shipingMetadataList, shipmentOrder, null),
					'orderNumber' => getValueFromMdt('letter.service.orderNumber', shipingMetadataList, shipmentOrder, null),
					'commercialName' => getValueFromMdt('clientletter.service.commercialName', shipingMetadataList, shipmentOrder, null)
				},
				'parcel' => new Map<String, Object>{
					'weight' => getValueFromMdt('letter.parcel.weight', shipingMetadataList, shipmentOrder, null)
				},
				'sender' => new Map<String, Object>{
					'senderParcelRef' => getValueFromMdt('letter.sender.senderParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'lastName' => getValueFromMdt('letter.sender.address.lastName', shipingMetadataList, shipmentOrder, null),
						'firstName' => getValueFromMdt('letter.sender.address.firstName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.sender.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.sender.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.sender.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.sender.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.sender.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.sender.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.sender.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				},
				'addressee' => new Map<String, Object>{
					'addresseeParcelRef' => getValueFromMdt('letter.addressee.addresseeParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'companyName' => getValueFromMdt('letter.addressee.address.companyName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.addressee.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.addressee.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.addressee.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.addressee.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.addressee.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.addressee.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.addressee.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				} 
			}
		};

		String jsonMapping  = JSON.serialize(shipmentRequest); 
		System.debug('@@ReturnFR' + jsonMapping);
		return jsonMapping;
	}

	public String colissimoReturnInsideEU(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder,  List<ShipmentItem> shipmentItemOrder) {

		System.debug('colissimoReturnInsideEU');

		String accountNumber = '{!$Credential.Username}';
        String password = '{!$Credential.Password}';

		Map<String, Object> shipmentRequest  = new Map<String, Object>{
			'contractNumber' => accountNumber,
			'password' => password,
			'outputFormat' => new Map<String, Object>{
				'x' => getValueFromMdt('outputFormat.x', shipingMetadataList, shipmentOrder, null),
				'y' => getValueFromMdt('outputFormat.y', shipingMetadataList, shipmentOrder, null),
				'outputPrintingType' => getValueFromMdt('outputFormat.outputPrintingType.ReturnEU', shipingMetadataList, shipmentOrder, null)
			},
			'letter' => new Map<String, Object>{
				'service' => new Map<String, Object>{
					'productCode' => getValueFromMdt('letter.service.productCode.ReturnEU', shipingMetadataList, shipmentOrder, null),
					'depositDate' => getValueFromMdt('letter.service.depositDate', shipingMetadataList, shipmentOrder, null)
				},
				'parcel' => new Map<String, Object>{
					'weight' => getValueFromMdt('letter.parcel.weight', shipingMetadataList, shipmentOrder, null)
				},
			'sender' => new Map<String, Object>{
				'address' => new Map<String, Object>{
					'lastName' => getValueFromMdt('letter.sender.address.lastName', shipingMetadataList, shipmentOrder, null),
					'firstName' => getValueFromMdt('letter.sender.address.firstName', shipingMetadataList, shipmentOrder, null),
					'line2' => getValueFromMdt('letter.sender.address.line2.ReturnEU', shipingMetadataList, shipmentOrder, null),
					'countryCode' => getValueFromMdt('letter.sender.address.countryCode', shipingMetadataList, shipmentOrder, null),
					'city' => getValueFromMdt('letter.sender.address.city', shipingMetadataList, shipmentOrder, null),
					'zipCode' => getValueFromMdt('letter.sender.address.zipCode', shipingMetadataList, shipmentOrder, null)
				}
			},
			'addressee' => new Map<String, Object>{
				'address' => new Map<String, Object>{
					'companyName' => getValueFromMdt('letter.addressee.address.companyName', shipingMetadataList, shipmentOrder, null),
					'line2' => getValueFromMdt('letter.addressee.address.line2.ReturnEU', shipingMetadataList, shipmentOrder, null),
					'countryCode' => getValueFromMdt('letter.addressee.address.countryCode', shipingMetadataList, shipmentOrder, null),
					'city' => getValueFromMdt('letter.addressee.address.city', shipingMetadataList, shipmentOrder, null),
					'zipCode' => getValueFromMdt('letter.addressee.address.zipCode', shipingMetadataList, shipmentOrder, null)
				}
			}
		}
		};

		String jsonMapping  = JSON.serialize(shipmentRequest); 
		System.debug('@@colissimoReturnInsideEU' + jsonMapping);
		return jsonMapping;
	}

	public String colissimoReturnOutsideEU(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList, List<Shipment> shipmentOrder,  List<ShipmentItem> shipmentItemOrder) {

		System.debug('colissimoReturnOutsideEU');

		String accountNumber = '{!$Credential.Username}';
        String password = '{!$Credential.Password}';

		Map<String, Object> shipmentRequest  = new Map<String, Object>{
			'contractNumber' => accountNumber,
			'password' => password,
			'outputFormat' => new Map<String, Object>{
				'x' => getValueFromMdt('outputFormat.x', shipingMetadataList, shipmentOrder, null),
				'y' => getValueFromMdt('outputFormat.y', shipingMetadataList, shipmentOrder, null),
				'outputPrintingType' => getValueFromMdt('outputFormat.outputPrintingType.ReturnInternational', shipingMetadataList, shipmentOrder, null)
			},
			'letter' => new Map<String, Object>{
				'service' => new Map<String, Object>{
					'productCode' => getValueFromMdt('letter.service.productCode.ReturnInternational', shipingMetadataList, shipmentOrder, null),
					'depositDate' => getValueFromMdt('letter.service.depositDate', shipingMetadataList, shipmentOrder, null),
					'orderNumber' => getValueFromMdt('letter.service.orderNumber', shipingMetadataList, shipmentOrder, null),
					'commercialName' => getValueFromMdt('clientletter.service.commercialName', shipingMetadataList, shipmentOrder, null)
				},
				'parcel' => new Map<String, Object>{
					'weight' => getValueFromMdt('letter.parcel.weight', shipingMetadataList, shipmentOrder, null)
				},
				'customsDeclarations' => new Map<String, Object>{
					'includeCustomsDeclarations' => Integer.valueOf(getValueFromMdt('letter.customsDeclarations.includeCustomsDeclarations', shipingMetadataList, shipmentOrder, null)), 
					'contents' => new Map<String, Object>{
						'article' => updateArticlesListInRequestBody('Return', shipmentItemOrder, shipingItemMetadataList),
						'category' => new Map<String, Object>{
							'value' => Integer.valueOf(getValueFromMdt('letter.customsDeclarations.contents.category.value.Return', shipingMetadataList, shipmentOrder, null))
						},
						'original' => new List<Map<String, Object>>{
							new Map<String, Object>{
								'originalIdent' => getValueFromMdt('letter.customsDeclarations.contents.original.originalIdent', shipingMetadataList, shipmentOrder, null),
								'originalInvoiceNumber' => getValueFromMdt('letter.customsDeclarations.contents.original.originalInvoiceNumber', shipingMetadataList, shipmentOrder, null),
								'originalInvoiceDate' => getValueFromMdt('letter.customsDeclarations.contents.original.originalInvoiceDate', shipingMetadataList, shipmentOrder, null),
								'originalParcelNumber' => getValueFromMdt('letter.customsDeclarations.contents.original.originalParcelNumber', shipingMetadataList, shipmentOrder, null)
							}
						}
					}
				},
				'sender' => new Map<String, Object>{
					'senderParcelRef' => getValueFromMdt('letter.sender.senderParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'lastName' => getValueFromMdt('letter.sender.address.lastName', shipingMetadataList, shipmentOrder, null),
						'firstName' => getValueFromMdt('letter.sender.address.firstName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.sender.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.sender.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.sender.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.sender.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.sender.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.sender.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.sender.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				},
				'addressee' => new Map<String, Object>{
					'addresseeParcelRef' => getValueFromMdt('letter.addressee.addresseeParcelRef', shipingMetadataList, shipmentOrder, null),
					'address' => new Map<String, Object>{
						'companyName' => getValueFromMdt('letter.addressee.address.companyName', shipingMetadataList, shipmentOrder, null),
						'line0' => getValueFromMdt('letter.addressee.address.line0', shipingMetadataList, shipmentOrder, null),
						'line1' => getValueFromMdt('letter.addressee.address.line1', shipingMetadataList, shipmentOrder, null),
						'line2' => getValueFromMdt('letter.addressee.address.line2', shipingMetadataList, shipmentOrder, null),
						'line3' => getValueFromMdt('letter.addressee.address.line3', shipingMetadataList, shipmentOrder, null),
						'countryCode' => getValueFromMdt('letter.addressee.address.countryCode', shipingMetadataList, shipmentOrder, null),
						'city' => getValueFromMdt('letter.addressee.address.city', shipingMetadataList, shipmentOrder, null),
						'zipCode' => getValueFromMdt('letter.addressee.address.zipCode', shipingMetadataList, shipmentOrder, null)
					}
				} 
			}
		};

		String jsonMapping  = JSON.serialize(shipmentRequest); 
		System.debug('@@colissimoReturnOutsideEU' + jsonMapping);
		return jsonMapping;
	}

	public HttpResponse callWebService (String requestBody) {
		HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json'); 
		HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:Colissimo', requestBody);
		return responseHttp; 
	}

	public String processResponse(HttpResponse responseHttp, List<Shipment> shipmentOrder, String shipmentId) {
		String response = responseHttp.getBody();
		System.debug(response);
		String startTag = 'Content-ID: <jsonInfos>';
		String endTag = '--uuid';
		SubstringMessage extracteur = new SubstringMessage(response, startTag, endTag);
	    String valeurExtraite = extracteur.extractedError;
		System.debug('valeurExtraite: ' + valeurExtraite);

		if(responseHttp.getStatusCode()==200) {
			Logs.infoShipment('Shipment', 'Create label colissimo', responseHttp, response); 
 
			Map<String, Object> extractedMap = (Map<String, Object>) JSON.deserializeUntyped(valeurExtraite);
			List<Object> messages = (List<Object>) extractedMap.get('messages');
			Map<String, Object> labelV2Response = (Map<String, Object>) extractedMap.get('labelV2Response');
			String trackingNumber = (String) labelV2Response.get('parcelNumber');

			Map<String, Object> firstMessage = (Map<String, Object>) messages[0];
			String messageContent = (String) firstMessage.get('messageContent');  
 
			System.debug('Message Content: ' + messageContent);
			String titleAttachment = 'Colissimo'+' '+ label.name_pdf_shipment;
			ContentVersion cv = new ContentVersion();
			cv.Title = titleAttachment;
			cv.PathOnClient = 'label.pdf';
			cv.VersionData =  responseHttp.getBodyAsBlob();
			cv.IsMajorVersion = true; 
			cv.FirstPublishLocationId = shipmentId;  
			insert cv; 
			if (trackingNumber != null) {
				shipmentOrder[0].TrackingNumber = trackingNumber;
				upsert shipmentOrder;
			}  
			String idFile = String.ValueOf(cv.Id);
			System.debug(idFile);
			//insertInformationShipment(shipmentOrder, 'Colissimo', responseHttp,  trackingNumber, shipmentId);
		} else {
			Logs.infoShipment('Shipment', 'Create label colissimo', responseHttp, response); 

			System.debug('@@@Response: ' + responseHttp.getBody());
		}
		return null;
	}
	
}