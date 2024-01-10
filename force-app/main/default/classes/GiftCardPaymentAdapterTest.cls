@isTest
public with sharing class GiftCardPaymentAdapterTest {

    
    @TestSetup
    static void makeData(){
        GiftCardPaymentAdapter.giftCard gc = new  GiftCardPaymentAdapter.giftCard();
        gc.giftCardNumber ='ggg';
        gc.giftCardBalance =5.2;
        gc.giftCardType =2;
        gc.reasonCode =1;
        gc.customerId ='56432678';
        gc.isExpendable =true;
        gc.expirationDate ='';
        gc.isExpired= false;
        gc.isDeactivated= false;
        gc.isSpent= false;
        gc.canRecharge= false;
        gc.canPay= false;
        gc.canRefund= false;
        gc.pin='1234';
        gc.creationTime='565';
        gc.modifyTime='666';
        gc.noTransfer='677';
        gc.locationId='566';
        gc.localCreateDateTime='5666';
        gc.createEmployeeId ='createEmployeeId';
        gc.editEmployeeId ='';
        gc.currencyId ='';
        gc.fiscalZoneId ='';
        gc.gracePeriodDate ='';
        gc.expirationPolicy = 12;
        gc.countryId = '';


    
    }

    @isTest 
    static void testCaptureRequest() {
        CardPaymentMethod cpm = new CardPaymentMethod(Status='Active', ProcessingMode='External', ExpiryYear = 2029, ExpiryMonth = 8);
        insert cpm;
        
        PaymentAuthorization auth = initializeAuthObject();
        auth.PaymentMethodId = cpm.Id;
        insert auth;

        Test.startTest();
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        

        //Create an capture request
        commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(80, auth.id);
        commercepayments.paymentGatewayContext pgc = new commercepayments.paymentGatewayContext(captureRequest, commercepayments.RequestType.Capture);
        GiftCardPaymentAdapter adapter = new GiftCardPaymentAdapter();
        commercepayments.GatewayResponse captureResponse = adapter.processRequest(pgc);
        //system.assert(captureResponse instanceOf commercepayments.CaptureResponse, 'Response is not a valid Capture response');
        Test.stopTest();
    }
    
    @isTest 
    static void testRefund() {
        CardPaymentMethod cpm = new CardPaymentMethod(Status='Active', ProcessingMode='External', ExpiryYear = 2029, ExpiryMonth = 8);
        insert cpm;
        
        PaymentAuthorization auth = initializeAuthObject();
        auth.PaymentMethodId = cpm.Id;
        insert auth;

        Test.startTest();
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        

        //Create an capture request
        commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(80, auth.id);
        commercepayments.paymentGatewayContext pgc = new commercepayments.paymentGatewayContext(refundRequest, commercepayments.RequestType.ReferencedRefund);
        GiftCardPaymentAdapter adapter = new GiftCardPaymentAdapter();
        commercepayments.GatewayResponse captureRefund = adapter.processRequest(pgc);
        //system.assert(captureResponse instanceOf commercepayments.CaptureResponse, 'Response is not a valid Capture response');
        Test.stopTest();
    }

    @isTest 
    static void testProcessNotification() {
        CardPaymentMethod cpm = new CardPaymentMethod(Status='Active', ProcessingMode='External', ExpiryYear = 2029, ExpiryMonth = 8);
        insert cpm;
        
        PaymentAuthorization auth = initializeAuthObject();
        auth.PaymentMethodId = cpm.Id;
        insert auth;

        Test.startTest();
        // Set mock callout class 
        //Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Create an capture request
        //
        CommercePayments.PaymentGatewayNotificationContext gatewayNotificationContext = new CommercePayments.PaymentGatewayNotificationContext(null);
        commercepayments.PaymentGatewayNotificationRequest gatewayNotificationRequest = gatewayNotificationContext.getPaymentGatewayNotificationRequest();
        GiftCardPaymentAdapter adapter = new GiftCardPaymentAdapter();
        commercepayments.GatewayNotificationResponse notifcationResp = adapter.processNotification(gatewayNotificationContext);
        //system.assert(captureResponse instanceOf commercepayments.CaptureResponse, 'Response is not a valid Capture response');
        Test.stopTest();
    }
    
    public static testmethod void testReferencedRefundRequest() {
        Payment pmt = initializePaymentObject();
        insert pmt;
        //Dmls and http request can't be performed in a single transaction in apex
        //segreagating the transaction by starting a test context
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Create an capture request
        commercepayments.ReferencedRefundRequest refundRequest = new commercepayments.ReferencedRefundRequest(80, pmt.id);

        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(refundRequest, commercepayments.RequestType.referencedrefund);
        GiftCardPaymentAdapter adapter = new GiftCardPaymentAdapter();

        commercepayments.GatewayResponse refundResponse = adapter.processRequest(p);
        //system.assert(refundResponse instanceOf commercepayments.ReferencedRefundResponse, 'Response is not a valid Refund response');
        Test.stopTest();
    }


    @isTest 
    static void testNotExistingRequest() {
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
        GiftCardPaymentAdapter adapter = new GiftCardPaymentAdapter();
        commercepayments.GatewayResponse captureResponse = adapter.processRequest(p);
        //system.assert(captureResponse instanceOf commercepayments.GatewayErrorResponse);
    }
    

    private static PaymentAuthorization initializeAuthObject(){
        PaymentAuthorization auth = new PaymentAuthorization();
        auth.amount = 1500;
        auth.Status = 'Processed';
        auth.ProcessingMode = 'External';
        auth.GatewayRefNumber = 'testreferencenumber';
        auth.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return auth;
    
    }
      private static Payment initializePaymentObject()
    {
        Payment pmt = new Payment();
        pmt.amount = 1500;
        pmt.Status = 'Processed';
        pmt.ProcessingMode = 'External';
        pmt.GatewayRefNumber = 'testreferencenumber';
        pmt.Type = 'Capture';
        pmt.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return pmt;    
    }
    
     @isTest static void makeDataToCc(){
        GiftCardPaymentAdapter.ClientContext cc = new GiftCardPaymentAdapter.ClientContext();
        cc.orderSummaryId ='';
        cc.orderPaymentSummaryId ='';
        cc.creditMemoId ='';
        cc.paymentId ='';
        cc.asyncJobId ='';
    }
    
    @isTest static void makeDataToNotifItem(){
       // GiftCardPaymentAdapter.giftCard gi = new GiftCardPaymentAdapter.giftCard();
        GiftCardPaymentAdapter.NotificationItem ni = new GiftCardPaymentAdapter.NotificationItem();
        ni.amount = 3.12;
        ni.paymentGatewayReference = '3.12';
        ni.success = true;
        
    }
}