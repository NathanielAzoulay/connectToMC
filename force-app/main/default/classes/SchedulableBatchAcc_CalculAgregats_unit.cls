/** 
* @description Classe qui implemente Schedulable pour le batch de calcul BatchAccount_CalculateAgregats en mode unitaire
*/
global class SchedulableBatchAcc_CalculAgregats_unit implements Schedulable {

    global void execute(SchedulableContext ctx) {
        BatchAccount_CalculateAgregats theBatch = new BatchAccount_CalculateAgregats();
        theBatch.lancementUnitaire = true;
        Database.executeBatch(theBatch, 1);
    }   
}