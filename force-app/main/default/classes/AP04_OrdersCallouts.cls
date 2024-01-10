public with sharing class AP04_OrdersCallouts {
    
    public Map < String, orderInfoClass > orderToOrderItem {get;set;}
    public Account myAccount {get;set;}
    public String accountId {get;set;}
    public List<orderInfoClass> orders;
    public List<List<orderInfoClass>> fullorders;
    
    private Set<String> skuSet;
    private Map<String, Status__c> mStatus;
    
    public orderInfoClass orderCourant {get;set;} 
       
    public Map<Integer, List<OrderInfoClass>> ordersSorted{get;set;}
    public Integer showParam {get;set;}
    public Integer pagesNumber{get;set;}
    public Integer currentPage{get;set;}
    public Integer recordCount{get;set;}
    
 public AP04_OrdersCallouts(ApexPages.StandardController stdController) {

    // Standard constructor (add the needed fields to retrieve)
    if (!Test.isRunningTest()) {
     stdController.addFields(new List < String > {
        'Id',
        'Account_Number__c',
        'PersonEmail'
     });
    } else {
     System.debug('Running test !');
    }

    if (myAccount == null)
     this.myAccount = (Account) stdController.getRecord();

    this.orders = null;
    this.orderToOrderItem = null;
    this.fullorders = null;
     
    //orderCourant = null;
 }



 public AP04_OrdersCallouts() {
    // Get the selected order
        String accountId = ApexPages.currentPage().getParameters().get('Accid');
        System.Debug('Accid' + accountId);


    if (myAccount == null)
     this.myAccount = [Select id, Account_Number__c, PersonEmail, Salutation , Name , Phone  
                        from Account 
                            where id =:accountId];


    System.debug('My current Account = ' + myAccount);
}




    public void initbis() {
        // Get the related orders
        getorders();
        
        // Get the selected order
        String ord = ApexPages.currentPage().getParameters().get('urlparmOrder');
        System.Debug('urlparmOrder' + ord);
        
        orderCourant = orderToOrderItem.get(ord);
        
        findSku();
        
        System.Debug('##### initbis() : ' + 'the current order is =' + orderCourant);
    }



    public void init() {
        showParam = 5;
        getorders();
        System.Debug('##### init() : ' + 'showParam =' + showParam);        
    }

 
    public void findSku(){
        Product2[] products = [SELECT Id, SKu__c FROM PRoduct2 WHERE SKu__c IN: skuSet];
        system.debug(skuset);
        Map<String, String> mapSku = new Map<String, String>();
        
        for(Product2 aProduct : products){
            mapSku.put(aProduct.SKU__c, aProduct.Id);
        }
        
        if(orderCourant != null && orderCourant.listOrdersItems != null){
            for(OrderItem anItem : orderCourant.listOrdersItems){
                if(mapSku.containsKey(anItem.sku)){
                    anItem.idSalesforce = mapSku.get(anItem.sku);
                }
            }
        }
    }



    public List <orderInfoClass> getorders() {
    
        findStatus();
    
        pagesNumber = 1;
        ordersSorted = new Map<Integer, List<OrderInfoClass>>();            
        List<orderInfoClass> currentOrdersPage = new List<orderInfoClass>();

        if (orderToOrderItem == null) {

            orderToOrderItem = new Map < String, orderInfoClass > ();
            String idSession;
            
            /**
            * get session Id
            */
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Label.LABS_SF_EndpointMagnento);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml');
            string body = '' + '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">' + '<soapenv:Header/>' + '<soapenv:Body>' + '<urn:login soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' + '<username xsi:type="xsd:string">'+Label.LABS_SF_usernameMagento+'</username>' + '<apiKey xsi:type="xsd:string">'+Label.LABS_SF_apiKeyMagento+'</apiKey>' + '</urn:login>' + '</soapenv:Body>' + '</soapenv:Envelope>';
            req.setBody(body);

            HttpResponse res;

            if (!Test.isRunningTest()) {
                res = h.send(req);
                System.debug('**** reponse ---> ' + res.getBodyDocument());
                idSession = res.getBodyDocument().getRootElement().getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').getChildElement('loginResponse', 'urn:Magento').getChildElement('loginReturn', null).getText();
            } else {
                idSession = '123456';
            }

            System.debug('**** Id session ---> ' + idSession);

            /**
            * get orders
            */
            req.setEndpoint(Label.LABS_SF_EndpointMagnento);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml');
            body = '' + '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">' + '<soapenv:Header/>' + '<soapenv:Body>' + '<urn:salesforceGetCustomerInfo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' + '<sessionId xsi:type="xsd:string">' + idSession + '</sessionId>' + '<email xsi:type="xsd:string">' + myAccount.PersonEmail + '</email>' + '</urn:salesforceGetCustomerInfo>' + '</soapenv:Body>' + '</soapenv:Envelope>';
            req.setBody(body);

            dom.Document resContent = null;

            if (!Test.isRunningTest()) {
               res = h.send(req);
               resContent = res.getBodyDocument();
               System.debug('-- res : ' + resContent.toXmlString());
            } else {
               StaticResource sr = [select id, body from StaticResource Where Id = : Label.LABS_SF_MockUp_Order];

               resContent = new Dom.Document();
               resContent.load(sr.body.ToString());
               System.debug(sr.body.toString());
               //resContent = sr.body.toString();
            }


            try {
               DOM.XMLNode salesforceGetCustomerInfoResponse = resContent.getRootElement().
               getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/').
               getChildElement('salesforceGetCustomerInfoResponse', 'urn:Magento');

               List < DOM.XMLNode > xmlOrders;
               DOM.XMLNode xmlCustomerInfo;
                   
               if (salesforceGetCustomerInfoResponse != null) {
                   
                xmlOrders = salesforceGetCustomerInfoResponse.getChildElement('result', null).
                getChildElement('orders', null).getChildElements();
                xmlCustomerInfo = salesforceGetCustomerInfoResponse.getChildElement('result', null).getChildElement('customerInfo', null);
                   
                   if (xmlCustomerInfo != null && xmlCustomerInfo.getChildElement('customer_id', null) != null && myAccount.Account_Number__c == null) {
                       myAccount.Account_Number__c = xmlCustomerInfo.getChildElement('customer_id', null).getText();  
                       update new Account(Id = myAccount.Id, Account_Number__c = myAccount.Account_Number__c);
                   }  
               }
               
               skuSet = new Set<String>();
                
               if (xmlOrders != null) {
                    for (DOM.XMLNode aOrder: xmlOrders) {
                        if (aOrder != null) {
                            System.debug('New order found');
                            String id = aOrder.getChildElement('quote_id', null).getText();
                            System.debug('New order : ' + id);

                            String createdDate = aOrder.getChildElement('created_at', null).getText();

                            String storeName = aOrder.getChildElement('store_name', null).getText();

                            String Statut = aOrder.getChildElement('status', null).getText();

                            String MontantTotal = aOrder.getChildElement('grand_total', null).getText();
                            

                            orderInfoClass orderInfo = new orderInfoClass();

                            DOM.XMLNode trackingURL = aOrder.getChildElement('tracking_urls', null);

                            // get the tracking information
                            if (trackingURL != null) {
                                DOM.XMLNode trackingURLItem = trackingURL.getChildElement('item', null);
                                
                                orderInfo.suivi = trackingURLItem.getChildElement('complete_url', null) != null ?
                                trackingURLItem.getChildElement('complete_url', null).getText() : null;
                                
                                orderInfo.nameTransporter = trackingURLItem.getChildElement('carrier', null) != null ?
                                trackingURLItem.getChildElement('carrier', null).getText() : null;

                                orderInfo.trackingNumber = trackingURLItem.getChildElement('tracking_number', null) != null ?
                                trackingURLItem.getChildElement('tracking_number', null).getText() : null;
                            }
                            
                            // Shopping Cart rule
                            DOM.XMLNode shoppingCartRule = aOrder.getChildElement('shopping_cart_rules', null);
                            if(shoppingCartRule != null){
                                DOM.XMLNode shoppingCartRuleItem = shoppingCartRule.getChildElement('item', null);
                                
                                orderInfo.shoppingCartRule = shoppingCartRuleItem != null ? shoppingCartRuleItem.getChildElement('rule_name', null).getText() : null;
                            }


                            orderInfo.myCurrency = aOrder.getChildElement('base_currency_code', null).getText();

                            // get the billing @ 
                            DOM.XMLNode xmlBillingAdd = aOrder.getChildElement('billing_address', null);

                            orderInfo.accountBillingFirstname = xmlBillingAdd.getChildElement('firstname', null).getText();
                            orderInfo.accountBillingLastname = xmlBillingAdd.getChildElement('lastname', null).getText();
                            orderInfo.accountBillingStreet = xmlBillingAdd.getChildElement('street', null).getText();
                            orderInfo.accountBillingCity = xmlBillingAdd.getChildElement('city', null).getText();
                            
                            if (xmlBillingAdd.getChildElement('telephone', null) != null) {
                                orderInfo.accountBillingPhone = xmlBillingAdd.getChildElement('telephone', null).getText();
                            }
                            
                            orderInfo.accountBillingState = xmlBillingAdd.getChildElement('region', null) != null ?
                            xmlBillingAdd.getChildElement('region', null).getText() : null;
                            orderInfo.accountBillingPostalCode = xmlBillingAdd.getChildElement('postcode', null).getText();
                            orderInfo.accountBillingCountry = xmlBillingAdd.getChildElement('country_id', null).getText();


                            // get the shipping @ 
                            DOM.XMLNode xmlShippingAdd = aOrder.getChildElement('shipping_address', null);

                            orderInfo.accountShippingFirstname = xmlShippingAdd.getChildElement('firstname', null).getText();
                            orderInfo.accountShippingLastname = xmlShippingAdd.getChildElement('lastname', null).getText();
                            orderInfo.accountShippingStreet = xmlShippingAdd.getChildElement('street', null).getText();
                            orderInfo.accountShippingCity = xmlShippingAdd.getChildElement('city', null).getText();
                            
                            if (xmlShippingAdd.getChildElement('telephone', null) != null) {
                                orderInfo.accountShippingPhone = xmlShippingAdd.getChildElement('telephone', null).getText();
                            }
                            
                            orderInfo.accountShippingState = xmlShippingAdd.getChildElement('region', null) != null ?
                            xmlShippingAdd.getChildElement('region', null).getText() : null;
                            orderInfo.accountShippingPostalCode = xmlShippingAdd.getChildElement('postcode', null).getText();
                            orderInfo.accountShippingCountry = xmlShippingAdd.getChildElement('country_id', null).getText();

                            DOM.XMLNode xmlisGift = aOrder.getChildElement('gift_data', null);


                            for (DOM.XMLNode message: aOrder.getChildElement('gift_data', null).getChildElements()) {
                                orderInfo.GiftMessage = message.getText();
                            }

                            orderInfo.Goodies = Integer.valueOf(aOrder.getChildElement('include_condoms', null).getText()) +
                            Integer.valueOf(aOrder.getChildElement('include_points', null).getText());
                            orderInfo.ShippingPrice = Decimal.valueOf((aOrder.getChildElement('shipping_amount', null).getText()).substring(
                            0, (aOrder.getChildElement('shipping_amount', null).getText()).length() - 2));

                            orderInfo.orderNumber = id;
                            orderInfo.orderDate = DateTime.valueOf(createdDate);
                            
                            orderInfo.orderStatut = Statut;
                            if(mStatus != null && mStatus.containsKey(orderInfo.orderStatut)){
                                System.debug(mStatus.get(orderInfo.orderStatut));
                                orderInfo.orderColor = mStatus.get(orderInfo.orderStatut).Color__c;
                                orderInfo.orderStatut = mStatus.get(orderInfo.orderStatut).Salesforce_Translation__c;
                            }
                            
                            orderInfo.orderStore = storeName;
                            orderInfo.Montant = Decimal.valueOf(MontantTotal);
                            orderInfo.subtotal = Decimal.valueOf(aOrder.getChildElement('subtotal', null).getText());
                            orderInfo.discount = Decimal.valueOf(aOrder.getChildElement('discount_amount', null).getText());
                            

                            for (DOM.XMLNode aOrderItem: aOrder.getChildElement('items', null).getChildElements()) {
                                System.debug('My item : ' + aOrderItem.getChildElement('sku', null).getText());
                                orderItem ord = new orderItem();
                                ord.productName = aOrderItem.getChildElement('name', null).getText();
                                
                                ord.sku = aOrderITem.getChildElement('sku', null).getText();
                                skuSet.add(ord.sku);
                                
                                ord.Qty = Integer.valueOf(aOrderItem.getChildElement('qty_ordered', null).getText());

                                ord.rowTotal = ((aOrderItem.getChildElement('row_total', null) != null) ?
                                Decimal.valueOf((aOrderItem.getChildElement('row_total', null).getText()).substring(0, (aOrderItem.getChildElement('row_total', null).getText()).length() - 2)) : null);


                                DOM.XMLNode discountData = aOrderITem.getChildElement('discount_amount', null);

                                ord.Discount = 0.00;

                                // get the discount information
                                if (discountData != null) {
                                    ord.Discount = Decimal.valueOf(discountData.getText());
                                }                                                               

                                ord.totalPrice = ord.Qty * ord.rowTotal - ord.Discount;
                                ord.size = aOrderItem.getChildElement('size', null) != null ?aOrderItem.getChildElement('size', null).getText() : null;
                                orderInfo.listOrdersItems.add(ord);

                            }

                            orderToOrderItem.put(orderInfo.orderNumber, orderInfo);
                            currentOrdersPage.add(orderInfo);
                            
                            System.debug(currentOrdersPage.size() + ' - ' + showParam);
                            if(currentOrdersPage.size() == showParam){
                                System.debug('in');
                                ordersSorted.put(pagesNumber, currentOrdersPage);
                                pagesNumber += 1;
                                currentOrdersPage = new List<orderinfoclass>();
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('***** Error ----> ' + e.getMessage() + e.getLineNumber());
            }
        }
        //System.debug('My list of orders : ' + orders.size());
        //System.debug('My map of orders : ' + orderToOrderItem.size());
        
        System.debug(currentOrdersPage.size() + ' -- ' + showParam);
        if(currentOrdersPage.size() > 0){
            ordersSorted.put(pagesNumber, currentOrdersPage);
        }
        
        recordCount = orderToOrderItem.size();
        
        pagesNumber = ordersSorted.size();
        System.debug('pagesNumber : ' + pagesNumber);
        
        return orderToOrderItem.values();
        //return this.orders;
    }
    
    public void findStatus(){
        Status__c[] allStatus = [SELECT Id, Magento_Value__c, Salesforce_Translation__c, Color__c FROM Status__c];
        
        mStatus = new Map<String, Status__c>();
        
        for(Status__c aStatus : allStatus){
            mStatus.put(aStatus.Magento_Value__c, aStatus);
        }
    }

 public List < Integer > getPaginateNav() {
    List < Integer > pageList = new List < Integer > ();
    /*Integer pageloop = 0;
    Double resultSize = ordersSet.getResultSize();
    Double pageSize = ordersSet.getPageSize();
    Double nbPages = resultSize / pageSize;
    if(nbPages > nbPages.intValue())
            pageloop = nbPages.intValue() + 1;
    else
            pageloop = nbPages.intValue();

    for(Integer i=0; i<pageloop;i++)
            pageList.add(i+1);
    */
    return pageList;
 }


    // returns the previous page of records
    public PageReference previous() {
        if(currentPage > 1){
            currentPage -= 1;
            
        }
        
        return null;
    }

    // returns the next page of records
    public PageReference next() {
        System.debug('next');
        if(pagesNumber > currentPage) {
            currentPage += 1;
            
        }   
        
        return null;     
    }

    public List<orderInfoClass> getOrdersToDisplay(){
        if(currentPage == null){
            currentPage = 1;
        }
        
        if(ordersSorted.containsKey(currentPage)){
            System.debug('Retourne page ' + ordersSorted.get(currentPage));
            return ordersSorted.get(currentPage);
        }
        
        return null;
    }


 // My inner customerInfo class
 class orderInfoClass {

    /**
     * Infos orders et comptes
     */

    // Done
    public String customerId {get;set;}
     
     
    // Done
    public String orderNumber {get;set;}
    public DateTime orderDate {get;set;}
    public String orderStore {get;set;}
    public String orderColor {get;set;}
    public String orderStatut {get;set;}
    public Decimal Montant {get;set;}
    public Decimal discount{get;set;}
    public Decimal subtotal {get;set;}
    public String suivi {get;set;}   
    
    public String shoppingCartRule {get;set;} 

    public String accountName {get;set;}
    public String accountEmail {get;set;}
    public String accountMobile {get;set;}
    public String accountPhone {get;set;}
    public String myCurrency {get;set;}

    public String accountBillingFirstname {get;set;}
    public String accountBillingLastname {get;set;}
    public String accountBillingStreet {get;set;}
    public String accountBillingCity {get;set;}
    public String accountBillingState {get;set;}
    public String accountBillingPostalCode {get;set;}
    public String accountBillingCountry {get;set;}
    public String accountBillingPhone {get;set;}

    public String accountShippingFirstname {get;set;}
    public String accountShippingLastname {get;set;}
    public String accountShippingStreet {get;set;}
    public String accountShippingCity {get;set;}
    public String accountShippingState {get;set;}
    public String accountShippingPostalCode {get;set;}
    public String accountShippingCountry {get;set;}
    public String accountShippingPhone {get;set;}

    public String nameTransporter {get;set;}
    public String trackingNumber {get;set;}
    public Integer Goodies {get;set;}
    public Decimal shippingPrice {get;set;}

    public String RecipeName {get;set;}
    public String GiftMessage {get;set;}

    public List < orderItem > listOrdersItems {get;set;}
    
    public orderInfoClass() {
     listOrdersItems = new List < orderItem > ();
    }

 }

 // Order Item
 class orderItem {

    public String productName {get;set;}
    public Integer Qty {get;set;}
    public Decimal totalPrice {get;set;}
    public Decimal Discount {get;set;}
    public Decimal rowTotal {get;set;}
    public String sku{get;set;}
    public Id idSalesforce {get;set;}
    public String size {get;set;}

    public orderItem() {

    }

 }
}