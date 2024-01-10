@istest
public class BatchSegmentationClientEMEA_Schdul_Test {




 static testmethod void testFunc() {
  Test.StartTest();
   
BatchSegmentationClientEMEA_Schdul sh1 = new BatchSegmentationClientEMEA_Schdul();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchSegmentationClientEMEA_Schdul', sch, sh1);
Test.stopTest();
   
}
    }