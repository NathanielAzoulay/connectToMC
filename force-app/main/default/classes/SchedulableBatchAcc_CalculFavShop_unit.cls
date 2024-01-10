/** 
* @description Classe qui implemente Schedulable pour le batch de calcul BatchAccount_CalculateFavoriteShop en mode unitaire
*/
global class SchedulableBatchAcc_CalculFavShop_unit implements Schedulable {

    global void execute(SchedulableContext ctx) {
        BatchAccount_CalculateFavoriteShop theBatch = new BatchAccount_CalculateFavoriteShop ();
        theBatch.lancementUnitaire = true;
        Database.executeBatch(theBatch, 1);
    }   
}