@isTest (SeeAllData = false)
public class AP09_UpdateOrderShopCurrency_Test {
/*
----------------------------------------------------------------------
-- - Name          : AP09_UpdateOrderCurrency_Test 
-- - Author        : PJI
-- - Description   : Test class related to the trigger cited below
          - AP09_UpdateOrderCurrency_Test
-- Maintenance History:
--
-- Date         Name          Version    Remarks 
-- -----------  -----------     --------    ---------------------------------------
-- 05-SEPT-2018  PJI            1.0        Initial version 
---------------------------------------------------------------------------------------
*/
    public static Shop__c aShop1, aShop2;
    public static Order order1, Order2;
    
    static void initData(){
        List<Shop__c> shops = new List<Shop__c>();
        
        aShop1 = new Shop__c(
              Shop_Number__c = '111',
              Name = 'Myshop 1', BillingCountry__c = 'HK');
              
        shops.add(aShop1);
        
        aShop2 = new Shop__c(
              Shop_Number__c = '112',
              Name = 'Myshop 2', BillingCountry__c = 'GB');           
        
        shops.add(aShop2);
        
        insert shops;
         
        Account a = new Account(
              FirstName = 'Fred',
             LastName = 'Smith',
             RecordTypeId = System.label.APAC_Person_Account,                 
           Effective_date_for_update__pc = System.today());

        insert a;
        
        List<Order> orders = new List<Order>();
        Date d = System.today();
        
        order1 = new Order(
                AccountId = a.Id,
                EffectiveDate = d.addMonths(-1),
                Name = 'My order 1' + a.FirstName,
                Status = 'Completed',
                Ticket_ID__c = '2010-11-13-F44-4' +  a.Id,
                Pricebook2Id = System.label.StandardPricebook2Id,
                Total_Quantity__c = 2,
                Total_amount__c = 200,
              Shop__c = aShop1.id);
              
         orders.add(order1);
         
         order2 = new Order(
                AccountId = a.Id,
                EffectiveDate = d.addMonths(-1),
                Name = 'My order 2' + a.FirstName,
                Status = 'Completed',
                Ticket_ID__c = '2010-11-13-F44-5' +  a.Id,
                Pricebook2Id = System.label.StandardPricebook2Id,
                Total_Quantity__c = 2,
                Total_amount__c = 200,
              Shop__c = aShop2.Id);
              
         orders.add(order2);      
         insert orders;
    }
   
    

     static testMethod void testUpdateCurrencyForOrdersCreated()
    {
        Test.startTest();
        
        initData();
        
        Test.stopTest(); 
        
        if (Label.LABS_SF_MULTI_CURRENCIES.equals('true')){
            order1 = [Select Id, CurrencyIsoCode FROM Order where Id = :order1.Id];
            System.assertEquals('HKD', order1.CurrencyIsoCode);
            
            order2 = [Select Id, CurrencyIsoCode FROM Order where Id = :order2.Id];
            System.assertEquals('GBP', order2.CurrencyIsoCode);   
         }
     }
     
    static testMethod void testUpdateCurrencyForOrdersUpdated()
    {
        Test.startTest();
        
        initData();
        order1.Shop__c = aShop2.Id;
        update order1;
        
        Test.stopTest(); 
        if (Label.LABS_SF_MULTI_CURRENCIES.equals('true')){
            order1 = [Select Id, CurrencyIsoCode FROM Order where Id = :order1.Id];
            System.assertEquals('GBP', order1.CurrencyIsoCode);
         }
     }
     
    static testMethod void testUpdateCurrencyForShops()
    {
        Test.startTest();
        
        initData();
        
        Test.stopTest(); 
        
        aShop1= [Select Id, CurrencyIsoCode FROM Shop__c where Id = :aShop1.Id];
        System.assertEquals('HKD', aShop1.CurrencyIsoCode);
     }
}