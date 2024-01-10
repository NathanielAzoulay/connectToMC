@isTest(SeeAllData=false)
private class BatchSegmentationClientEMEA_Test {
    static testMethod void testSegmentationClientEMEA(){
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'BatchTest',
            Created_date_Cgid__c =Date.newInstance(2020, 11, 9),
            RecordTypeId ='0120Y000000YWbMQAW',
            Tech_exclude_from_batch_SF__c = false
            
        );
        insert acc;
        
    
        Account acc2 = new Account(
            FirstName = 'Test1',
            LastName = 'BatchTest',
            RecordTypeId ='0120Y000000YWbMQAW',
            Tech_exclude_from_batch_SF__c = false
            
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
        Order o3 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-24), Name='My order2', Status ='Completed', Total_amount__c = 200, Ticket_ID__c='Ticket3', Total_Quantity__c=1,Pricebook2Id = pricebookId);
        insert o3;
       
        Test.startTest();
        BatchSegmentationClientEMEA batch = new BatchSegmentationClientEMEA();
        Database.executeBatch(batch,10);
        Test.stopTest();
        
        acc = [SELECT Id, Segmentation__c FROM Account WHERE Id = :acc.Id];
        acc2 = [SELECT Id, Segmentation__c FROM Account WHERE Id = :acc2.Id];
     
        List<Order> listO = new list <Order>();
        listO.add(o1);
        listO.add(o2);
        List<Account> listA = new list <Account>();
        ListA.add(acc);
        BatchSegmentationClientEMEA.extractAccountId(listA);
        
        System.assertEquals(400, BatchSegmentationClientEMEA.calculatTotalAmount(listO));
        System.assertEquals(0, BatchSegmentationClientEMEA.calculateNbrOrdNefatif(listO));
    }
}