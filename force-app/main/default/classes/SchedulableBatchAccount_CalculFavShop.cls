/** 
* @description Classe qui implemente Schedulable pour le batch de calcul BatchAccount_CalculateFavoriteShop 
*/
global class SchedulableBatchAccount_CalculFavShop implements Schedulable {

    global void execute(SchedulableContext ctx) {
        BatchAccount_CalculateFavoriteShop theBatch = new BatchAccount_CalculateFavoriteShop ();
        Database.executeBatch(theBatch, 50);
    }   
}