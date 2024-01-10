public class ChronopostIntegration extends CarrierClass {	

	public override String createLabel(List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment_Item__mdt> shipingItemMetadataList,  String carrierService, String fulfillmentId, String shipmentId, String getStatusShipment) { 
		
		List<Shipment> shipmentOrder = listShipmentMetadata(shipingMetadataList, shipmentId); 
      // ShipmentItem shipmentItemOrder = listShipmentItemMetadata(shipingItemMetadataList, shipmentId); 

      String requestBody = chronopostLabel(shipingMetadataList, shipmentOrder);

      HTTPResponse responseHttp = callWebService(requestBody);
      
      String variable = processResponse(responseHttp, shipmentOrder, shipmentId);
      return variable;
   }
 
   public String chronopostLabel (List<Shippment_Mapping__mdt> shipingMetadataList, List<Shipment> shipmentOrder) {

      String accountNumber = '{!$Credential.Username}';
      String password = '{!$Credential.Password}';
      String requestBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxf="http://cxf.shipping.soap.chronopost.fr/">' +
         '<soapenv:Header/>' +
         '<soapenv:Body>' +
            '<cxf:shippingMultiParcelV4>' +
               '<headerValue>' +
                  '<accountNumber>' + accountNumber + '</accountNumber>' +
                  '<idEmit>'+ getValueFromMdt('headerValue.idEmit', shipingMetadataList, shipmentOrder, null) +'</idEmit>' +
                  '<identWebPro>'+ getValueFromMdt('headerValue.identWebPro', shipingMetadataList, shipmentOrder, null) +'</identWebPro>' + 
                  '<subAccount>'+ getValueFromMdt('headerValue.subAccount', shipingMetadataList, shipmentOrder, null) +'</subAccount>' +
               '</headerValue>' +
               '<shipperValue>' +
                  '<shipperAdress1>'+ getValueFromMdt('shipperValue.shipperAdress1', shipingMetadataList, shipmentOrder, null) +'</shipperAdress1>' +
                  '<shipperAdress2>'+ getValueFromMdt('shipperValue.shipperAdress2', shipingMetadataList, shipmentOrder, null) +'</shipperAdress2>' +
                  '<shipperCity>'+ getValueFromMdt('shipperValue.shipperCity', shipingMetadataList, shipmentOrder, null) +'</shipperCity>' +
                  '<shipperCivility>'+ getValueFromMdt('shipperValue.shipperCivility', shipingMetadataList, shipmentOrder, null) +'</shipperCivility>' +
                  '<shipperContactName>'+ getValueFromMdt('shipperValue.shipperContactName', shipingMetadataList, shipmentOrder, null) +'</shipperContactName>' +
                  '<shipperCountry>'+ getValueFromMdt('shipperValue.shipperCountry', shipingMetadataList, shipmentOrder, null) +'</shipperCountry>' +
                  '<shipperCountryName>'+ getValueFromMdt('shipperValue.shipperCountryName', shipingMetadataList, shipmentOrder, null) +'</shipperCountryName>' +
                  '<shipperEmail>'+ getValueFromMdt('shipperValue.shipperEmail', shipingMetadataList, shipmentOrder, null) +'</shipperEmail>' +
                  '<shipperMobilePhone>'+ getValueFromMdt('shipperValue.shipperMobilePhone', shipingMetadataList, shipmentOrder, null) +'</shipperMobilePhone>' +
                  '<shipperName>'+ getValueFromMdt('shipperValue.shipperName', shipingMetadataList, shipmentOrder, null) +'</shipperName>' +
                  '<shipperName2>'+ getValueFromMdt('shipperValue.shipperName2', shipingMetadataList, shipmentOrder, null) +'</shipperName2>' +
                  '<shipperPhone>'+ getValueFromMdt('shipperValue.shipperPhone', shipingMetadataList, shipmentOrder, null) +'</shipperPhone>' +
                  '<shipperPreAlert>'+ getValueFromMdt('shipperValue.shipperPreAlert', shipingMetadataList, shipmentOrder, null) +'</shipperPreAlert>' +
                  '<shipperZipCode>'+ getValueFromMdt('shipperValue.shipperZipCode', shipingMetadataList, shipmentOrder, null) +'</shipperZipCode>' +
                  '<shipperType>'+ getValueFromMdt('shipperValue.shipperType', shipingMetadataList, shipmentOrder, null) +'</shipperType>' +
               '</shipperValue>' +
               '<customerValue>' +
                  '<customerAdress1>'+ getValueFromMdt('customerValue.customerAdress1', shipingMetadataList, shipmentOrder, null) +'</customerAdress1>' +
                  '<customerAdress2>'+ getValueFromMdt('customerValue.customerAdress2', shipingMetadataList, shipmentOrder, null) +'</customerAdress2>' +
                  '<customerCity>'+ getValueFromMdt('customerValue.customerCity', shipingMetadataList, shipmentOrder, null) +'</customerCity>' +
                  '<customerCivility>'+ getValueFromMdt('customerValue.customerCivility', shipingMetadataList, shipmentOrder, null) +'</customerCivility>' +
                  '<customerContactName>'+ getValueFromMdt('customerValue.customerContactName', shipingMetadataList, shipmentOrder, null) +'</customerContactName>' +
                  '<customerCountry>'+ getValueFromMdt('customerValue.customerCountry', shipingMetadataList, shipmentOrder, null) +'</customerCountry>' +
                  '<customerCountryName>'+ getValueFromMdt('customerValue.customerCountryName', shipingMetadataList, shipmentOrder, null) +'</customerCountryName>' +
                  '<customerEmail>'+ getValueFromMdt('customerValue.customerEmail', shipingMetadataList, shipmentOrder, null) +'</customerEmail>' +
                  '<customerMobilePhone>'+ getValueFromMdt('customerValue.customerMobilePhone', shipingMetadataList, shipmentOrder, null) +'</customerMobilePhone>' +
                  '<customerName>'+ getValueFromMdt('customerValue.customerName', shipingMetadataList, shipmentOrder, null) +'</customerName>' +
                  '<customerName2>'+ getValueFromMdt('customerValue.customerName2', shipingMetadataList, shipmentOrder, null) +'</customerName2>' +
                  '<customerPhone>'+ getValueFromMdt('customerValue.customerPhone', shipingMetadataList, shipmentOrder, null) +'</customerPhone>' +
                  '<customerPreAlert>'+ getValueFromMdt('customerValue.customerPreAlert', shipingMetadataList, shipmentOrder, null) +'</customerPreAlert>' +
                  '<customerZipCode>'+ getValueFromMdt('customerValue.customerZipCode', shipingMetadataList, shipmentOrder, null) +'</customerZipCode>' +
                  '<printAsSender>'+ getValueFromMdt('customerValue.printAsSender', shipingMetadataList, shipmentOrder, null) +'</printAsSender>' +
               '</customerValue>' +
               '<recipientValue>' +
                  '<recipientName>'+ getValueFromMdt('recipientValue.recipientName', shipingMetadataList, shipmentOrder, null) +'</recipientName>' +
                  '<recipientName2>'+ getValueFromMdt('recipientValue.recipientName2', shipingMetadataList, shipmentOrder, null) +'</recipientName2>' +
                  '<recipientAdress1>'+ getValueFromMdt('recipientValue.recipientAdress1', shipingMetadataList, shipmentOrder, null) +'</recipientAdress1>' +
                  '<recipientAdress2>'+ getValueFromMdt('recipientValue.recipientAdress2', shipingMetadataList, shipmentOrder, null) +'</recipientAdress2>' +
                  '<recipientZipCode>'+ getValueFromMdt('recipientValue.recipientZipCode', shipingMetadataList, shipmentOrder, null) +'</recipientZipCode>' +
                  '<recipientCity>'+ getValueFromMdt('recipientValue.recipientCity', shipingMetadataList, shipmentOrder, null) +'</recipientCity>' +
                  '<recipientCountry>'+ getValueFromMdt('recipientValue.recipientCountry', shipingMetadataList, shipmentOrder, null) +'</recipientCountry>' +
                  '<recipientContactName>'+ getValueFromMdt('recipientValue.recipientContactName', shipingMetadataList, shipmentOrder, null) +'</recipientContactName>' +
                  '<recipientEmail>'+ getValueFromMdt('recipientValue.recipientEmail', shipingMetadataList, shipmentOrder, null) +'</recipientEmail>' +
                  '<recipientPhone>'+ getValueFromMdt('recipientValue.recipientPhone', shipingMetadataList, shipmentOrder, null) +'</recipientPhone>' +
                  '<recipientMobilePhone>'+ getValueFromMdt('recipientValue.recipientMobilePhone', shipingMetadataList, shipmentOrder, null) +'</recipientMobilePhone>' +
                  '<recipientPreAlert>'+ getValueFromMdt('recipientValue.recipientPreAlert', shipingMetadataList, shipmentOrder, null) +'</recipientPreAlert>' +
                  '<recipientType>'+ getValueFromMdt('recipientValue.recipientType', shipingMetadataList, shipmentOrder, null) +'</recipientType>' +
               '</recipientValue>' +
               '<refValue>' +
                  '<customerSkybillNumber>'+ getValueFromMdt('refValue.customerSkybillNumber', shipingMetadataList, shipmentOrder, null) +'</customerSkybillNumber>' +
                  '<recipientRef>'+ getValueFromMdt('refValue.recipientRef', shipingMetadataList, shipmentOrder, null) +'</recipientRef>' +
                  '<shipperRef>'+ getValueFromMdt('refValue.shipperRef', shipingMetadataList, shipmentOrder, null) +'</shipperRef>' +
                  '<idRelais>'+ getValueFromMdt('refValue.idRelais', shipingMetadataList, shipmentOrder, null) +'</idRelais>' +
               '</refValue>' +
               '<skybillValue>' +
                  '<bulkNumber>'+ getValueFromMdt('skybillValue.bulkNumber', shipingMetadataList, shipmentOrder, null) +'</bulkNumber>' +
                  '<codCurrency>'+ getValueFromMdt('skybillValue.codCurrency', shipingMetadataList, shipmentOrder, null) +'</codCurrency>' +
                  '<codValue>'+ getValueFromMdt('skybillValue.codValue', shipingMetadataList, shipmentOrder, null) +'</codValue>' +
                  '<content1>'+ getValueFromMdt('skybillValue.content1', shipingMetadataList, shipmentOrder, null) +'</content1>' +
                  '<content2>'+ getValueFromMdt('skybillValue.content2', shipingMetadataList, shipmentOrder, null) +'</content2>' +
                  '<content3>'+ getValueFromMdt('skybillValue.content3', shipingMetadataList, shipmentOrder, null) +'</content3>' +
                  '<content4>'+ getValueFromMdt('skybillValue.content4', shipingMetadataList, shipmentOrder, null) +'</content4>' +
                  '<content5>'+ getValueFromMdt('skybillValue.content5', shipingMetadataList, shipmentOrder, null) +'</content5>' +
                  '<customsCurrency>'+ getValueFromMdt('skybillValue.customsCurrency', shipingMetadataList, shipmentOrder, null) +'</customsCurrency>' +
                  '<customsValue>'+ getValueFromMdt('skybillValue.customsValue', shipingMetadataList, shipmentOrder, null) +'</customsValue>' +
                  '<evtCode>'+ getValueFromMdt('skybillValue.evtCode', shipingMetadataList, shipmentOrder, null) +'</evtCode>' +
                  '<insuredCurrency>'+ getValueFromMdt('skybillValue.insuredCurrency', shipingMetadataList, shipmentOrder, null) +'</insuredCurrency>' +
                  '<insuredValue>'+ getValueFromMdt('skybillValue.insuredValue', shipingMetadataList, shipmentOrder, null) +'</insuredValue>' +
                  '<latitude>'+ getValueFromMdt('skybillValue.latitude', shipingMetadataList, shipmentOrder, null) +'</latitude>' +
                  '<longitude>'+ getValueFromMdt('skybillValue.longitude', shipingMetadataList, shipmentOrder, null) +'</longitude>' +
                  '<masterSkybillNumber/>' +
                  '<objectType>'+ getValueFromMdt('skybillValue.objectType', shipingMetadataList, shipmentOrder, null) +'</objectType>' +
                  '<portCurrency>'+ getValueFromMdt('skybillValue.portCurrency', shipingMetadataList, shipmentOrder, null) +'</portCurrency>' +
                  '<portValue>'+ getValueFromMdt('skybillValue.portValue', shipingMetadataList, shipmentOrder, null) +'</portValue>' +
                  '<productCode>'+ getValueFromMdt('skybillValue.productCode', shipingMetadataList, shipmentOrder, null) +'</productCode>' +
                  '<qualite>'+ getValueFromMdt('skybillValue.qualite', shipingMetadataList, shipmentOrder, null) +'</qualite>' +
                  '<service>'+ getValueFromMdt('skybillValue.service', shipingMetadataList, shipmentOrder, null) +'</service>' +
                  '<shipDate>'+ getValueFromMdt('skybillValue.shipDate', shipingMetadataList, shipmentOrder, null) +'</shipDate>' +
                  '<shipHour>'+ getValueFromMdt('skybillValue.shipHour', shipingMetadataList, shipmentOrder, null) +'</shipHour>' +
                  '<skybillRank>'+ getValueFromMdt('skybillValue.skybillRank', shipingMetadataList, shipmentOrder, null) +'</skybillRank>' +
                  '<source>'+ getValueFromMdt('skybillValue.source', shipingMetadataList, shipmentOrder, null) +'</source>' +
                  '<weight>'+ getValueFromMdt('skybillValue.weight', shipingMetadataList, shipmentOrder, null) +'</weight>' +
                  '<weightUnit>'+ getValueFromMdt('skybillValue.weightUnit', shipingMetadataList, shipmentOrder, null) +'</weightUnit>' +
                  '<height>'+ getValueFromMdt('skybillValue.height', shipingMetadataList, shipmentOrder, null) +'</height>' +
                  '<length>'+ getValueFromMdt('skybillValue.length', shipingMetadataList, shipmentOrder, null) +'</length>' +
                  '<width>'+ getValueFromMdt('skybillValue.width', shipingMetadataList, shipmentOrder, null) +'</width>' +
                  '<as>'+ getValueFromMdt('skybillValue.as', shipingMetadataList, shipmentOrder, null) +'</as>' +
                  '<subAccount>'+ getValueFromMdt('skybillValue.subAccount', shipingMetadataList, shipmentOrder, null) +'</subAccount>' +
                  '<toTheOrderOf>'+ getValueFromMdt('	skybillValue.toTheOrderOf', shipingMetadataList, shipmentOrder, null) +'</toTheOrderOf>' +
                  '<skybillNumber>'+ getValueFromMdt('skybillValue.skybillNumber', shipingMetadataList, shipmentOrder, null) +'</skybillNumber>' +
                  '<carrier>'+ getValueFromMdt('skybillValue.carrier', shipingMetadataList, shipmentOrder, null) +'</carrier>' +
                  '<skybillBackNumber>'+ getValueFromMdt('skybillValue.skybillBackNumber', shipingMetadataList, shipmentOrder, null) +'</skybillBackNumber>' +
                  '<alternateProductCode>'+ getValueFromMdt('skybillValue.alternateProductCode', shipingMetadataList, shipmentOrder, null) +'</alternateProductCode>' +
                  '<labelNumber>'+ getValueFromMdt('skybillValue.labelNumber', shipingMetadataList, shipmentOrder, null) +'</labelNumber>' +
               '</skybillValue>' +
               '<skybillParamsValue>' +
                  '<duplicata>'+ getValueFromMdt('skybillParamsValue.duplicata', shipingMetadataList, shipmentOrder, null) +'</duplicata>' +
                  '<mode>'+ getValueFromMdt('skybillParamsValue.mode', shipingMetadataList, shipmentOrder, null) +'</mode>' + 
                  '<withReservation>'+ getValueFromMdt('skybillParamsValue.withReservation', shipingMetadataList, shipmentOrder, null) +'</withReservation>' +
               '</skybillParamsValue>' +
               '<password>' + password + '</password>' +
               '<modeRetour>'+ getValueFromMdt('modeRetour', shipingMetadataList, shipmentOrder, null) +'</modeRetour>' +
               '<numberOfParcel>'+ getValueFromMdt('numberOfParcel', shipingMetadataList, shipmentOrder, null) +'</numberOfParcel>' +
               '<version>'+ getValueFromMdt('version', shipingMetadataList, shipmentOrder, null) +'</version>' +
               '<multiParcel>'+ getValueFromMdt('multiParcel', shipingMetadataList, shipmentOrder, null) +'</multiParcel>' +
            '</cxf:shippingMultiParcelV4>' +
         '</soapenv:Body>' +
      '</soapenv:Envelope>';
      return requestBody;
   }

      public HttpResponse callWebService (String requestBody) {
         HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/xml');
		   HTTPResponse responseHttp = HttpRequestApiCreateLabel.postData('callout:Chronopost', requestBody);
         return responseHttp;
      }

      public String processResponse(HttpResponse responseHttp, List<Shipment> shipmentOrder, String shipmentId) {
		   String response = responseHttp.getBody();
         System.debug('responseHttp.getBody()' + response);

         if (responseHttp.getStatusCode() == 200) {
            String responseXml = responseHttp.getBody();
            String startTagError = '<errorCode>';
            String endTagError = '</errorCode>';

            SubstringMessage extracteur = new SubstringMessage(responseXml, startTagError, endTagError);

            // Accédez à la valeur extraite
            String valeurExtraite = extracteur.extractedError;
            System.debug('getStatusCode = ' + valeurExtraite);

            if (valeurExtraite == '0') {   
               String startTagTrackingNumber = '<geoPostNumeroColis>';
               String endTagTrackingNumber = '</geoPostNumeroColis>';

               Integer startIndexTrackingNumber = responseXml.indexOf(startTagTrackingNumber);
               Integer endIndexTrackingNumber = responseXml.indexOf(endTagTrackingNumber, startIndexTrackingNumber);
               String trackingNumber = responseXml.substring(startIndexTrackingNumber + startTagTrackingNumber.length(), endIndexTrackingNumber).trim();

               String startTagLabel = '<pdfEtiquette>';
               String endTagLabel = '</pdfEtiquette>';

               Integer startIndexLabel = responseXml.indexOf(startTagLabel);
               Integer endIndexLabel = responseXml.indexOf(endTagLabel, startIndexLabel);
               String extractedLabel = responseXml.substring(startIndexLabel + startTagLabel.length(), endIndexLabel).trim();
               Blob pdfBlob = EncodingUtil.base64Decode(extractedLabel);
               
               ContentVersion cv = new ContentVersion();
               cv.Title = 'Chronopost shipment PDF';
               cv.PathOnClient = 'label.pdf';
               cv.VersionData = pdfBlob;
               cv.IsMajorVersion = true;
		         cv.FirstPublishLocationId = shipmentId; 
		         insert cv;


               String idFile = String.ValueOf(cv.Id);
               System.debug(idFile);
               
               if (trackingNumber != null) {
                  shipmentOrder[0].TrackingNumber = trackingNumber;
                  upsert shipmentOrder;
               }
               Logs.infoShipment('Shipment', 'Create label chronopost', responseHttp, response);
               return idFile;
            } else {
               String errorMessage = valeurExtraite;
               Logs.infoShipment('Shipment', 'Create label chronopost', responseHttp, response);
            }
         }
      return null;
      } 
}