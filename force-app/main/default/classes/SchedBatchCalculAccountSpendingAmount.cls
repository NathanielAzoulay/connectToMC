/*
----------------------------------------------------------------------
-- - Name          : SchedBatchCalculAccountSpendingAmount
-- - Author        : RDB
-- - Description   : Batch schedulable qui va se déclencher tous les jours     
--					 pour calculer les montants dépensés par compte
-- Maintenance History: 
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 25-05-2020   RDB                 1.0         Init
---------------------------------------------------------------------------------------
*/
global class SchedBatchCalculAccountSpendingAmount implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        BatchCalculAccountSpendingAmount theBatch = new BatchCalculAccountSpendingAmount();
        Database.executeBatch(theBatch, 100);
    }   
}