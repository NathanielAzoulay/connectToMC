global class BatchAccount_CalculatePromo_Schedul implements Schedulable {
 global void execute(SchedulableContext SC) {
     
        BatchAccount_CalculatePromophilie myBatch = new BatchAccount_CalculatePromophilie();
        Id batchinstanceid = database.executeBatch(myBatch, 100); 
}
}