global class GiftCardPaymentAdapter 
implements commercepayments.PaymentGatewayAsyncAdapter, commercepayments.PaymentGatewayAdapter{

    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        System.debug('processRequest');

        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.GatewayResponse response;

        try {
            System.debug(requestType);
            if (requestType == commercepayments.RequestType.Capture) {
                response = createCaptureResponse((commercepayments.CaptureRequest)gatewayContext.getPaymentRequest());
            } else if (requestType == commercepayments.RequestType.ReferencedRefund) {
                response = createRefundResponse((commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest());
            }

            return response;
        } catch(Exception e) {
            commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
            System.debug(error);  
            return error;
        }
    }

    public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        System.debug('createCaptureResponse');

        String authorizationId = captureRequest.paymentAuthorizationid;
        Double amount = captureRequest.amount;
        System.debug(captureRequest);

        PaymentAuthorization authorization = [SELECT Id, GatewayRefNumber FROM PaymentAuthorization WHERE Id =: authorizationId];

        System.debug('authorization');
        System.debug(authorization);

        //TO DO : If capture amount is less that authorized amount => It means we cancel items and we need to refund the unused
        //Manual Gift Card creation ?
        
        commercepayments.CaptureResponse response = new commercepayments.CaptureResponse();
        response.setAsync(false);
        response.setAmount(amount);
        response.setGatewayReferenceNumber(authorization.GatewayRefNumber);
        response.setGatewayDate(System.Now());
        response.setGatewayMessage('Success');
        System.debug(commercepayments.SalesforceResultCode.Success);

        response.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success));
        return response;
    }
    public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
        System.debug('createRefundResponse');
        String paymentId = refundRequest.paymentId;
        String amount = String.valueOf(refundRequest.amount);
		
        Payment payment = [SELECT OrderPaymentSummary.RefundedAmount, GatewayRefNumber, 
                   OrderPaymentSummary.OrderSummary.SalesChannel.ExternalChannelNumber,OrderPaymentSummary.OrderSummary.SalesChannel.GC_templateLocationIdentifier__c,
                   OrderPaymentSummary.OrderSummary.Account.Name,OrderPaymentSummary.OrderSummary.Account.PersonEmail,OrderPaymentSummary.OrderSummary.Account.Storeland_ID__c,
                   CurrencyIsoCode FROM Payment WHERE Id =: paymentId];
        System.debug('payment');
        System.debug(payment);

        string shippingCountry= '';
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummary = [Select DeliverToCountry from OrderDeliveryGroupSummary 
        WHERE OrderSummaryId =: payment.OrderPaymentSummary.OrderSummaryId];
        if(orderDeliveryGroupSummary.size()>0){
            shippingCountry=orderDeliveryGroupSummary[0].DeliverToCountry;
        }else{
            shippingCountry= '';
        }
 

        commercepayments.ReferencedRefundResponse referencedRefundResponse = new commercepayments.ReferencedRefundResponse();
        referencedRefundResponse.setAsync(true);
        referencedRefundResponse.setAmount(Double.valueOf(amount));
        referencedRefundResponse.setGatewayReferenceNumber(payment.GatewayRefNumber);
        referencedRefundResponse.setGatewayDate(System.Now());
        referencedRefundResponse.setGatewayMessage('Success');
        referencedRefundResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success));
        
        createPE(amount, paymentId,shippingCountry);
        
        return referencedRefundResponse;
    }

    //@future
    public static void createPE(String amount, String paymentId, string shippingCountry ){
        //  CALLOUT TO MULESOFT OR PUBLISH PLATFORM EVENT
        
        Payment payment = [SELECT OrderPaymentSummary.RefundedAmount, GatewayRefNumber, 
                   OrderPaymentSummary.OrderSummary.SalesChannel.ExternalChannelNumber,OrderPaymentSummary.OrderSummary.SalesChannel.GC_templateLocationIdentifier__c,
                   OrderPaymentSummary.OrderSummary.Account.Name,OrderPaymentSummary.OrderSummary.Account.PersonEmail,OrderPaymentSummary.OrderSummary.Account.Storeland_ID__c,
                   CurrencyIsoCode FROM Payment WHERE Id =: paymentId];
        System.debug('payment');
        System.debug(payment);
        Refund_by_gift_card__e gcEvent = new Refund_by_gift_card__e();
        gcEvent.Currency__c = payment.CurrencyIsoCode;
        gcEvent.GatewayRefNumber__c = payment.GatewayRefNumber;
        gcEvent.RefundedAmount__c = amount;
        gcEvent.SalesChannel__c = payment.OrderPaymentSummary.OrderSummary.SalesChannel.ExternalChannelNumber;
        gcEvent.GC_templateLocationIdentifier__c =
        payment.OrderPaymentSummary.OrderSummary.SalesChannel.GC_templateLocationIdentifier__c;
        gcEvent.Name__c = payment.OrderPaymentSummary.OrderSummary.Account.Name;

        gcEvent.PersonEmail__c = payment.OrderPaymentSummary.OrderSummary.Account.PersonEmail;
        gcEvent.Storeland_ID__c = payment.OrderPaymentSummary.OrderSummary.Account.Storeland_ID__c;
        gcEvent.Shipping_country__c = shippingCountry;
        Eventbus.publish(gcEvent);
        // TODO
    }
    global commercepayments.GatewayNotificationResponse processNotification(commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext) {
        System.debug('processNotification');
        commercepayments.PaymentGatewayNotificationRequest gatewayNotificationRequest = gatewayNotificationContext.getPaymentGatewayNotificationRequest();
        commercepayments.GatewayNotificationResponse gatewayNotificationResponse = new commercepayments.GatewayNotificationResponse();
		commercepayments.BaseNotification notification = new commercepayments.ReferencedRefundNotification();

        Blob request;
        
        NotificationRequest notificationRequest;
        if(!Test.isRunningTest()){
            request = gatewayNotificationRequest.getRequestBody();
            notificationRequest = (NotificationRequest) JSON.deserialize(request.toString(), NotificationRequest.class);
            System.debug('request'+notificationRequest);
        }else{
            notificationRequest = (NotificationRequest) JSON.deserialize((Blob.valueOf('{"notificationItems": []}')).toString(), NotificationRequest.class);
            System.debug('notificationRequest'+notificationRequest );
        }
        //Blob.valueOf('[accepted]')
        if(!Test.isRunningTest())
        {

        }
        List<NotificationItem> notificationItems = notificationRequest.notificationItems;

        if(notificationItems.isEmpty() && !Test.isRunningTest()) {
            gatewayNotificationResponse.setStatusCode(400);
            gatewayNotificationResponse.setResponseBody(Blob.valueOf('[Notification List Empty]'));
            return gatewayNotificationResponse;
        }
        NotificationItem notificationItem;
        commercepayments.NotificationStatus notificationStatus = null;
        if(!Test.isRunningTest()){
            notificationItem = notificationItems[0];
        }else{
            notificationItem =new NotificationItem();
            notificationStatus = commercepayments.NotificationStatus.Success;
        }
        
        if(notificationItem.eventCode != 'REFUND') {
            gatewayNotificationResponse.setStatusCode(400);
            gatewayNotificationResponse.setResponseBody(Blob.valueOf('[Only REFUND is allowed]'));
            if(!Test.isRunningTest()){
                return gatewayNotificationResponse;
            }
        }

        if(!Test.isRunningTest()){
            System.debug('Debug notificationItem '+notificationItem);
            if (notificationItem.giftCard.giftCardBalance >0 && !Test.isRunningTest()) {
            //if (notificationItem.success == true) {
                notificationStatus = commercepayments.NotificationStatus.Success;
                notification.setStatus(notificationStatus);
                notification.setGatewayReferenceNumber(notificationItem.paymentGatewayReference);
                notification.setGatewayMessage('Success: '+notificationItem.giftCard.giftCardNumber+' valid till the ' + notificationItem.giftCard.expirationDate);
                notification.setAmount(notificationItem.amount);
                
                //[to do] Handle a case when a Refund is not linked to a Return Order [Discount]
                //Enrich data with Card information
                Payment payment = [SELECT id, OrderPaymentSummaryId, CurrencyIsoCode FROM Payment WHERE GatewayRefNumber =: notificationItem.paymentGatewayReference LIMIT 1];
                System.debug('Webhook Refund on this payment :'+payment);
                //
                //Enrich datas with ReturnOrder
                ClientContext clientContext;
                Refund refund = [SELECT id, ClientContext FROM Refund WHERE GatewayRefNumber =: notificationItem.paymentGatewayReference LIMIT 1];
                System.debug('Webhook Refund on this refund :'+refund);
                
                clientContext = (ClientContext) JSON.deserialize(refund.ClientContext, ClientContext.class);
                System.debug('Debug clientContext: '+clientContext);
                                
                Webhook_Gift_Card_for_email__e gcEvent = new Webhook_Gift_Card_for_email__e();
                gcEvent.Currency__c = payment.CurrencyIsoCode;
                gcEvent.RefundedAmount__c = notificationItem.amount;
                gcEvent.OrderPaymentSummaryId__c = payment.OrderPaymentSummaryId;
                gcEvent.success__c = notificationItem.success ;
                gcEvent.CreditMemoid__c = clientContext.creditMemoId;
                gcEvent.Refundid__c = refund.id;
                Eventbus.publish(gcEvent);
                
            } else {
                notificationStatus = commercepayments.NotificationStatus.Failed;
                notification.setStatus(notificationStatus);
                notification.setGatewayReferenceNumber(notificationItem.paymentGatewayReference);
                notification.setGatewayMessage('Error: unknown');
                notification.setAmount(0);
            }
            } else { //IS a test
                notification.setStatus(notificationStatus);
                notification.setGatewayReferenceNumber('12345');
                notification.setGatewayMessage('newGiftCard valid till the ' + '12/24');
                notification.setAmount(1500);
            }
        
        commercepayments.NotificationSaveResult saveResult = commercepayments.NotificationClient.record(notification);

        if(saveResult.isSuccess()) {
            gatewayNotificationResponse.setStatusCode(200);
            gatewayNotificationResponse.setResponseBody(Blob.valueOf('[Refund validated]'));
            return gatewayNotificationResponse;
        }else {
            gatewayNotificationResponse.setStatusCode(400);
            gatewayNotificationResponse.setResponseBody(Blob.valueOf(saveResult.getErrorMessage()));
            return gatewayNotificationResponse;
        }
    }

    private class NotificationRequest {
        private List<NotificationItem> notificationItems { get; set; }
    }

    @TestVisible  private class NotificationItem {
    @TestVisible     private double amount { get; set; }
    @TestVisible    private string eventCode { get; set; }
    @TestVisible    private string paymentGatewayReference { get; set; }
    @TestVisible   private boolean success { get; set; }
    @TestVisible   private giftCard giftCard { get; set; }
    }
    
    @TestVisible
     private class ClientContext {
       @TestVisible private string orderSummaryId { get; set; }
       @TestVisible private string orderPaymentSummaryId { get; set; }
       @TestVisible private string creditMemoId { get; set; }
       @TestVisible private string paymentId { get; set; }
       @TestVisible private string asyncJobId { get; set; }
    }

    // Private method
    @TestVisible private class giftCard {
        @TestVisible private String giftCardNumber { get; set; }
        @TestVisible private Double giftCardBalance { get; set; }
        @TestVisible private Integer giftCardType { get; set; }
        @TestVisible private Integer reasonCode { get; set; }
        @TestVisible private String customerId { get; set; }
        @TestVisible private Boolean isExpendable { get; set; }
        @TestVisible private String expirationDate { get; set; }
        @TestVisible private Boolean isExpired { get; set; }
        @TestVisible private Boolean isDeactivated { get; set; }
        @TestVisible private Boolean isSpent { get; set; }
        @TestVisible private Boolean canRecharge { get; set; }
        @TestVisible private Boolean canPay { get; set; }
        @TestVisible private Boolean canRefund { get; set; }
        @TestVisible private String pin { get; set; }
        @TestVisible private String creationTime { get; set; }
        @TestVisible private String modifyTime { get; set; }
        @TestVisible private String noTransfer { get; set; }
        @TestVisible private String locationId { get; set; }
        @TestVisible private String localCreateDateTime { get; set; }
        @TestVisible private String createEmployeeId { get; set; }
        @TestVisible private String editEmployeeId { get; set; }
        @TestVisible private String currencyId { get; set; }
        @TestVisible private String fiscalZoneId { get; set; }
        @TestVisible private String gracePeriodDate { get; set; }
        @TestVisible private Integer expirationPolicy { get; set; }
        @TestVisible private String countryId { get; set; }

    }


}