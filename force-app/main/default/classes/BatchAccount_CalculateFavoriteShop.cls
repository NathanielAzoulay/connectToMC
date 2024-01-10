global class BatchAccount_CalculateFavoriteShop implements Database.Batchable<sObject> {
    
    Public  Integer choixBatch {get; set;} 
    public Boolean lancementUnitaire; 
    
    
    //global final List<Account> myAccountList = new List<Account>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
        String d = String.valueOf(system.today() );

        String complRequ = ' AND Tech_unitary_batch_SF__c = ';

        if (lancementUnitaire != null && lancementUnitaire){
            complRequ += 'true ';
        }
        else {
            complRequ += 'false ';
        }
        
        
        String query = 'SELECT Id, PersonContactId , Date_Calc_Favorite_calculated_shop__c  FROM Account WHERE PersonContactId != null ' +
            ' AND Tech_exclude_from_batch_SF__c = false ' + complRequ +
            ' AND (Effective_date_for_update__pc = ' + d +
            ' OR Effective_date_for_update__pc = null ';
        
        if (choixBatch == 0) {
           query += Label.LABS_PerconAcc_EffectiveDate_2 ;
        }
        
        else {
            query += Label.LABS_PerconAcc_EffectiveDate ;
            
        }
        
        return Database.getQueryLocator(query) ;
    }


    global void execute(Database.BatchableContext bc, List<Account> scope){

         List<Order> myMapofOrdersForFavoriteShop = new List<Order>();
        Set<Id> myKeyset = new Set<Id>();
        
        // process each batch of records
        System.debug('########### Enter execute : my list of Account' + scope);
        

        // Construct the PersonAccount keyset
        for (Account acc : scope) {
            myKeyset.add(acc.PersonContactId);
        }

        AP08_Account_FavoriteCalculatedShop.Account_FavoriteCalculatedShop(myKeyset);
    }    

    global void finish(Database.BatchableContext bc){
        BatchAccount_CalculateLastDateActivity calculteLastActivitybatch = new BatchAccount_CalculateLastDateActivity() ;
        if (lancementUnitaire != null && lancementUnitaire){
            calculteLastActivitybatch.lancementUnitaire = true;
            Database.executeBatch(calculteLastActivitybatch, 1);
        }
        else {
            Database.executeBatch(calculteLastActivitybatch);
        }
        
    }    

}