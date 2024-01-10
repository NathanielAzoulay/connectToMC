@isTest(SeeAllData=false)

private class BatchAccount_CalculatePromophilie_test {
    static testMethod void testCalculPromophilie(){
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'BatchTest'
        );
        insert acc;
        
          Account acc2 = new Account(
            FirstName = 'Test',
            LastName = 'BatchTest'
        );
        insert acc2;
        
         
      
        
      
      
        Product2 prod = new Product2(Name = 'Jeans',  SKU__c = 'P287UM20_000-0',	CurrencyIsoCode='EUR');
        insert  prod;  
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);  
        insert standardPrice;
        
        Order o1 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-24), Name='My order1', Status ='Completed', Total_amount__c = 200, Ticket_ID__c='Ticket1', Total_Quantity__c=1,Pricebook2Id = pricebookId);
        
        insert o1;
        
        Order o2 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-24), Name='My order2', Status ='Completed', Total_amount__c = 200, Ticket_ID__c='Ticket2', Total_Quantity__c=1,Pricebook2Id = pricebookId);
        insert o2;
        Order o3 = new Order(AccountId = acc2.Id, EffectiveDate = Date.today().addMonths(-24), Name='My order2', Status ='Completed', Total_amount__c = 200, Ticket_ID__c='Ticket3', Total_Quantity__c=1,Pricebook2Id = pricebookId);
        insert o3;
         
       
        
        OrderItem oItem1 = new  OrderItem (OrderId = o1.Id, Discount__c = 0, PricebookEntryId = standardPrice.id,UnitPrice = 10000, Quantity=1); 	
        insert oItem1 ;
        
      OrderItem oItem2 = new  OrderItem (OrderId = o2.Id, Discount__c = 0, PricebookEntryId = standardPrice.id,UnitPrice = 10000, Quantity=1);
        insert oItem2 ;
        OrderItem oItem3 = new  OrderItem (OrderId = o1.Id, Discount__c = 22, PricebookEntryId = standardPrice.id,UnitPrice = 10000,Quantity=1);
        insert oItem3 ;
        OrderItem oItem4 = new  OrderItem (OrderId = o1.Id, Discount__c = 0, PricebookEntryId = standardPrice.id,UnitPrice = 10000,Quantity=1);
        insert oItem4 ;
         OrderItem oItem5 = new  OrderItem (OrderId = o3.Id, Discount__c = 0, PricebookEntryId = standardPrice.id,UnitPrice = 10000,Quantity=1);
        insert oItem5 ;
      
          
   
        Test.startTest();
        BatchAccount_CalculatePromophilie batch = new BatchAccount_CalculatePromophilie();
        Database.executeBatch(batch);
        Test.stopTest();
        acc = [SELECT Id, promophilie__c FROM Account WHERE Id = :acc.Id];
          acc2 = [SELECT Id, promophilie__c FROM Account WHERE Id = :acc2.Id];
    
        System.assertEquals(1, acc2.promophilie__c);
     
       
        
    }
    
    
}