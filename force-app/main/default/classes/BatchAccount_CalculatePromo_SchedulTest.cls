@istest
public class BatchAccount_CalculatePromo_SchedulTest {



 static testmethod void testFunc() {
  Test.StartTest();
   
BatchAccount_CalculatePromo_Schedul sh1 = new BatchAccount_CalculatePromo_Schedul();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchAccount_CalculatePromo_Schedul', sch, sh1);
Test.stopTest();
   
}
    }