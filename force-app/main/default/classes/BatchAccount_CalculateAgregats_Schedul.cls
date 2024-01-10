global class BatchAccount_CalculateAgregats_Schedul implements Schedulable {
   global void execute(SchedulableContext SC) {
     
        BatchAccount_CalculateAgregats myBatch = new BatchAccount_CalculateAgregats();
        Id batchinstanceid = database.executeBatch(myBatch, 100); 
   }
}