global class SchedulableBatchAccount_CalculFavShop_2 implements Schedulable {
    
      global void execute(SchedulableContext ctx) 
    {
        
        BatchAccount_CalculateFavoriteShop theBatch_2 = new BatchAccount_CalculateFavoriteShop ();
        theBatch_2.choixBatch = 0;
        Database.executeBatch(theBatch_2, 100);
    }   

}