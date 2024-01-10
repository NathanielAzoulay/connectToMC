@isTest(Seealldata=false)
private class  SchedBatchCalculAccSpendingAmt_TEST {

    // tous les jours à 8h
    public static String CRON_EXP = '0 0 8 * * ?';
  
    @isTest static void testSchedule()  {
        // Schedule the test job
        String jobId = System.schedule('SchedBatchCalculAccSpendingAmt',
                        CRON_EXP, 
                        new SchedBatchCalculAccountSpendingAmount());
    }
}