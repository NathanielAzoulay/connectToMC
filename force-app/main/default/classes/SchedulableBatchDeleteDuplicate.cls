global class SchedulableBatchDeleteDuplicate implements Schedulable  {
    
    global void execute(SchedulableContext ctx) {
        BatchDeleteDuplicate theBatch = new BatchDeleteDuplicate ();
        theBatch.param = null ;
        Database.executeBatch(theBatch, 100);
    }
}