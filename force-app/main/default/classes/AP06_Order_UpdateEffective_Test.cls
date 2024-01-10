@isTest
public class AP06_Order_UpdateEffective_Test {
/*
----------------------------------------------------------------------
-- - Name          : AP06_Order_UpdateEffective_Test
-- - Author        : AAB
-- - Description   : Test class related to the trigger cited below
					- AP06_Order_UpdateEffective
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 17-OCT-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
    
     public static List<Shop__c> createShop(Integer nbShop) {
        List<Shop__c> shops = new List<Shop__c>();
        Integer i;
        
        for(i= 0; i<nbShop; i++) {
            Shop__c a = new Shop__c(
            	Shop_Number__c = '12' + i,
         		Name = 'Myshop ' + i);
            
            shops.add(a);
        }

        insert shops;
         
        return shops;
    }
    
    public static List<Account> createAccounts(Integer nbAcc) {
        List<Account> accs = new List<Account>();
        Integer i;
        
        for(i= 0; i<nbAcc; i++) {
            Account a = new Account(
            	FirstName = 'Fred' + i,
         		LastName = 'Smith',
         		RecordTypeId = System.label.APAC_Person_Account,                 
    	 		Effective_date_for_update__pc = System.today());
            
            accs.add(a);
        }

        insert accs;
         
        return accs;
    }
    
    public static List<Order> createOrders(Integer nbOrder,Account acct, Shop__c myshop) {
        List<Order> orders = new List<Order>();
        Integer i = 0;
		Date d = System.today();
        
        for(i= 0; i< nbOrder; i++) {
            Order a = new Order(
                AccountId = acct.Id,
                EffectiveDate = d.addMonths(-1),
                Name = 'My order' + i + acct.FirstName,
                Status = 'Completed',
                Ticket_ID__c = '2010-11-13-F44-4' + i +  acct.Id,
                Pricebook2Id = System.label.StandardPricebook2Id,
                Total_Quantity__c = 2,
                Total_amount__c = 200,
            	Shop__c = myshop.id);
           
            orders.add(a);
        }
        
        insert orders;
         
        return orders;
    }


    @TestSetup static void setupData() {
        // Create Shops
        List<Shop__c> shops = new List<Shop__c>();
        Shop__c shop1 = new Shop__c(
            	Shop_Number__c = '999',
         		Name = 'Test Shop 999',
                Currency__c = 'USD',
                CurrencyIsoCode = 'USD',
                BillingCountry__c = 'US');
        Shop__c shop2 = new Shop__c(
                Shop_Number__c = '998',
                Name = 'Test Shop 998',
                Currency__c = 'JPY',
                CurrencyIsoCode = 'JPY',
                BillingCountry__c = 'JP');   
        shops.add(shop1);
        shops.add(shop2);
        insert shops;

        // Create Account
        Account acc = new Account(
            	FirstName = 'Richard', 
         		LastName = 'Hendricks',
                CurrencyIsoCode = 'EUR',
         		RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('EMEA_Person_Account').getRecordTypeId(),                 
    	 		Effective_date_for_update__pc = System.today());
        insert acc;
    }

    @IsTest static void updateAccountEffectiveDateAndCurrency_OneOrder() {
        Id accountId = [Select Id from Account LIMIT 1].Id;
        Id shopUsdId = [Select Id from Shop__c where CurrencyIsoCode = 'USD' LIMIT 1].Id;
        Date d = System.today();

        Order o = new Order(
            AccountId = accountId,
            EffectiveDate = d.addMonths(-1),
            Name = 'My Order updateAccountEffectiveDateAndCurrency 1',
            Status = 'Completed',
            Ticket_ID__c = '2023-05-03-F44-4' + accountId,
            Pricebook2Id = System.label.StandardPricebook2Id,
            Total_Quantity__c = 2,
            Total_amount__c = 200,
            Shop__c = shopUsdId,
            CurrencyIsoCode = 'USD');

        Test.startTest();

        insert o;

        Test.stopTest();

        Account acc = [Select Id, CurrencyIsoCode from Account where Id = :accountId LIMIT 1];

        Assert.areEqual('USD', acc.CurrencyIsoCode);
    }

    @IsTest static void updateAccountEffectiveDateAndCurrency_OrdersWithDifferentCurrencies() {
        Id accountId = [Select Id from Account LIMIT 1].Id;
        Id shopUsdId = [Select Id from Shop__c where CurrencyIsoCode = 'USD' LIMIT 1].Id;
        Id shopJpyId = [Select Id from Shop__c where CurrencyIsoCode = 'JPY' LIMIT 1].Id;
        Date d = System.today();

        List<Order> orders = new List<Order>();
        Order orderJpy = new Order(
            AccountId = accountId,
            EffectiveDate = d,
            Name = 'My Order updateAccountEffectiveDateAndCurrency JPY',
            Status = 'Completed',
            Ticket_ID__c = '2023-05-03-F44-3' + accountId,
            Pricebook2Id = System.label.StandardPricebook2Id,
            Total_Quantity__c = 2,
            Total_amount__c = 200,
            Shop__c = shopJpyId,
            CurrencyIsoCode = 'JPY');
        orders.add(orderJpy);

        Order orderUsd = new Order(
            AccountId = accountId,
            EffectiveDate = d.addMonths(-1),
            Name = 'My Order updateAccountEffectiveDateAndCurrency USD',
            Status = 'Completed',
            Ticket_ID__c = '2023-05-03-F44-2' + accountId,
            Pricebook2Id = System.label.StandardPricebook2Id,
            Total_Quantity__c = 2,
            Total_amount__c = 200,
            Shop__c = shopUsdId,
            CurrencyIsoCode = 'USD');
        orders.add(orderUsd);

        Test.startTest();

        insert orders;

        Test.stopTest();

        Account acc = [Select Id, CurrencyIsoCode, HasOrdersWithDifferentCurrencies__c from Account where Id = :accountId LIMIT 1];
        
        // Most recent currency is used
        Assert.areEqual('JPY', acc.CurrencyIsoCode);
        // Flagged as account with orders with different currencies
        Assert.isTrue(acc.HasOrdersWithDifferentCurrencies__c);
    }

    @IsTest static void updateAccountEffectiveDateAndCurrency_OrdersWithSameCurrencies() {
        Id accountId = [Select Id from Account LIMIT 1].Id;
        Id shopUsdId = [Select Id from Shop__c where CurrencyIsoCode = 'USD' LIMIT 1].Id;
        Id shopJpyId = [Select Id from Shop__c where CurrencyIsoCode = 'JPY' LIMIT 1].Id;
        Date d = System.today();

        List<Order> orders = new List<Order>();
        Order orderJpy = new Order(
            AccountId = accountId,
            EffectiveDate = d,
            Name = 'My Order updateAccountEffectiveDateAndCurrency USD',
            Status = 'Completed',
            Ticket_ID__c = '2023-05-03-F44-1' + accountId,
            Pricebook2Id = System.label.StandardPricebook2Id,
            Total_Quantity__c = 2,
            Total_amount__c = 200,
            Shop__c = shopUsdId,
            CurrencyIsoCode = 'USD');
        orders.add(orderJpy);

        Order orderUsd2 = new Order(
            AccountId = accountId,
            EffectiveDate = d.addMonths(-2),
            Name = 'My Order updateAccountEffectiveDateAndCurrency USD2',
            Status = 'Completed',
            Ticket_ID__c = '2023-05-03-F44-9' + accountId,
            Pricebook2Id = System.label.StandardPricebook2Id,
            Total_Quantity__c = 2,
            Total_amount__c = 200,
            Shop__c = shopUsdId,
            CurrencyIsoCode = 'USD');
        orders.add(orderUsd2);

        Test.startTest();

        insert orders;

        Test.stopTest();

        Account acc = [Select Id, CurrencyIsoCode, HasOrdersWithDifferentCurrencies__c from Account where Id = :accountId LIMIT 1];
        
        // Most recent currency is used
        Assert.areEqual('USD', acc.CurrencyIsoCode);
        // Flagged as account with orders with different currencies
        Assert.isFalse(acc.HasOrdersWithDifferentCurrencies__c);
    }
}