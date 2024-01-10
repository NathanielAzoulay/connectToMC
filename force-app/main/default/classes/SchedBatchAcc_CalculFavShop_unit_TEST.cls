@isTest
private class SchedBatchAcc_CalculFavShop_unit_TEST {
    
     // tous les 1ers du mois à 8h
    public static String CRON_EXP = '0 0 8 1 * ?';
  
    @isTest static void testSchedule()  {
        // Schedule the test job
        String jobId = System.schedule('SchedulableBatchAcc_CalculFavShop_unit',
                        CRON_EXP, 
                        new SchedulableBatchAcc_CalculFavShop_unit());
    }
}