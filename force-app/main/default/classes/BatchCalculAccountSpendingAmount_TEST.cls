@isTest
private class BatchCalculAccountSpendingAmount_TEST {
    

    static testMethod void testCalculSpendingAmount() {
        Account acc = new Account(
            	FirstName = 'Fred',
         		LastName = 'Smith',
                RecordTypeId = System.Label.LABS_PerconAcc_RT_APAC);
        insert acc;

        Order o1 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-20), Name='My order1', Status ='Completed', Total_amount__c = 200,
                        Ticket_ID__c='Ticket1', Total_Quantity__c=1);
        insert o1;
        Order o2 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-11), Name='My order2', Status ='Completed', Total_amount__c = 200,
                        Ticket_ID__c='Ticket2', Total_Quantity__c=1);
        insert o2;
        Order o3 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-8), Name='My order3', Status ='Completed', Total_amount__c = 200,
                        Ticket_ID__c='Ticket3', Total_Quantity__c=1);
        insert o3;
        Order o4 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-5), Name='My order4', Status ='Completed', Total_amount__c = 200,
                        Ticket_ID__c='Ticket4', Total_Quantity__c=1);
        insert o4;
        Order o5 = new Order(AccountId = acc.Id, EffectiveDate = Date.today().addMonths(-2), Name='My order5', Status='Completed', Total_amount__c = 200,
                        Ticket_ID__c='Ticket5', Total_Quantity__c=1);
        insert o5;
        
        Test.startTest();
        BatchCalculAccountSpendingAmount batch = new BatchCalculAccountSpendingAmount();
        Database.executeBatch(batch);
        Test.stopTest();

        acc = [SELECT Id, PersonContactId, L3M_spending__c, L6M_spending__c, L9M_spending__c, 
                        L12M_spending__c , L13_24M_Spending__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(o5.Total_amount__c, acc.L3M_spending__c);
        System.assertEquals(o5.Total_amount__c+o4.Total_amount__c, acc.L6M_spending__c);
        System.assertEquals(o5.Total_amount__c+o4.Total_amount__c+o3.Total_amount__c, acc.L9M_spending__c);
        System.assertEquals(o5.Total_amount__c+o4.Total_amount__c+o3.Total_amount__c+o2.Total_amount__c, acc.L12M_spending__c);
        System.assertEquals(o1.Total_amount__c, acc.L13_24M_Spending__c);
    }
    

}