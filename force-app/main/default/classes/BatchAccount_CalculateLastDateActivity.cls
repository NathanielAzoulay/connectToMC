global class BatchAccount_CalculateLastDateActivity implements Database.Batchable<sObject> {
    
    //global final List<Account> myAccountList = new List<Account>();
    public Boolean lancementUnitaire; 

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
        
        return Database.getQueryLocator(
            'SELECT Id, PersonContactId ' +
            'FROM Account ' +
            'WHERE PersonContactId != null AND Tech_exclude_from_batch_SF__c = false ' + complRequ +
            + Label.LABS_PerconAcc_LastActivityDate
         );
    }


    global void execute(Database.BatchableContext bc, List<Account> scope){

        List<Order> myMapofOrdersForFavoriteShop = new List<Order>();
        Set<Id> myKeyset = new Set<Id>();
        
        // process each batch of records
        //System.debug('########### Enter execute : my list of Account' + scope);
        

        // Construct the PersonAccount keyset
        for (Account acc : scope) {
            myKeyset.add(acc.PersonContactId);
        }

            AP10_Account_LastActivtyDateCalculate.Account_LastActivtyDateCalculate(myKeyset);
            AP11_Account_Agr_Shop.getAccount_Agr_Shop(myKeyset);   
            AP13_Account_TendanceSegmentation.getAccount_TendanceSegmentation(myKeyset);

    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}