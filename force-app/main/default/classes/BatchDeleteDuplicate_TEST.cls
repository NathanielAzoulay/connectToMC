@isTest(SeeAllData=false)
public class BatchDeleteDuplicate_TEST {
    @testSetup
    public static void initData() {
        
        Account acc1 = new Account(Lastname ='master Account',Communication_Language__pc ='fr',AccountSource ='BOUT' );
        insert acc1;
        Account acc2 = new Account(Lastname ='duplicate Account', Communication_Language__pc ='fr', tech_Master_Id__c = acc1.Id ,AccountSource ='BOUT');
        insert acc2;
        Case aCase = new Case(Origin='Manual Entry', Subject = ' test ' , Description =' description ', accountId = acc2.Id);
        insert aCase ;
    }
    
  @IsTest
    public static void voidtestBatch() {   
        Test.startTest(); 
        BatchDeleteDuplicate bc = new BatchDeleteDuplicate() ;
        bc.param = 'LIMIT 1';
    	Database.executebatch(bc,1);
        Test.stopTest();
        List<Account> lAccount = [SELECT id from Account];
        System.assertEquals(1,lAccount.size());
        Case aCase = [SELECT id, AccountId  from Case];
        System.assertEquals(lAccount[0].Id  ,aCase.AccountId );
        
    }
}