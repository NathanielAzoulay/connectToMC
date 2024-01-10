@isTest
private class BatchUpdateCaseModifDate_TEST {
    
    static testMethod void testCaseUpdate(){
        Account acc = new Account(
            FirstName = 'Test1',
            LastName = 'BatchTest'
        );
        insert acc;
        Case c = new Case(
            AccountId = acc.Id, 
            Subject = 'Test subject' + acc.Name,
            Description = 'Hello !',
            Origin = 'E-mail',
            Status = 'NEW'
        );
        insert c ;
        Test.startTest();
        BatchUpdateCaseModifDate batch = new  BatchUpdateCaseModifDate();
        Database.executeBatch(batch,200);
        Test.stopTest();
        
        
        System.assertEquals('NEW', c.status);
        
    }
}