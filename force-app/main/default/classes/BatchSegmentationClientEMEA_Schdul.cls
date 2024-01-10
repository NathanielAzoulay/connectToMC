global class BatchSegmentationClientEMEA_Schdul implements Schedulable {
 global void execute(SchedulableContext SC) {
     
        BatchSegmentationClientEMEA myBatch = new BatchSegmentationClientEMEA();
        Id batchinstanceid = database.executeBatch(myBatch, 100); 
}
}