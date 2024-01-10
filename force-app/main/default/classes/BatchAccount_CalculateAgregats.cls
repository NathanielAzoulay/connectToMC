global class BatchAccount_CalculateAgregats implements Database.Batchable<sObject> {
/*
----------------------------------------------------------------------
-- - Name          : BatchAccount_CalculateAgregats
-- - Author        : AAB
-- - Description   : Batch that calculates agregat values on Accounts (related objects such as Order/Orderitem)        
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 13-MAR-2017  AAB                 1.0         Initial version
-- 15-MAR-2017  AAB                 2.0         Object reference change to Account (PersonAccount) 
---------------------------------------------------------------------------------------
*/
    public Boolean lancementUnitaire; 
    
    global final List<Account> myAccountList = new List<Account>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
        String d = String.valueOf(system.today());

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
            ' AND (Effective_date_for_update__pc = ' + d +
            ' OR Effective_date_for_update__pc = null '+ Label.LABS_PerconAcc_EffectiveDate );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        
        List<Order> myMapofOrders = new List<Order>();
        Set<Id> myKeyset = new Set<Id>();
        
        // process each batch of records
        System.debug('########### Enter execute : my list of Account' + scope);
        

        // Construct the PersonAccount keyset
        for (Account acc : scope) {
            myKeyset.add(acc.PersonContactId);
        }
        
        // Check that we are not on January
        Date currentYear =  
            (System.Today().month() != 1) ?  System.Today() :  System.Today().addYears(-1);
        
        Date start_Annee_AB = date.valueOf(String.valueOf(currentYear.year()) + System.Label.Start_Annee_AB);
        Date start_Annee_AB_1 = start_Annee_AB.addYears(-1);
        
        String queryString = 'Select ID, Account.PersonContactId, ' +
                            ' Name, Total_amount__c, EffectiveDate, CreatedDate, Shop__c,' +
                            ' (Select Id, Product2Id, Quantity, UnitPrice, Product2.Product_line__c From OrderItems)' + 
                            ' From Order Where';
       
        
        System.debug('start_Annee_AB: ' + start_Annee_AB);
        System.debug('start_Annee_AB_1: ' + start_Annee_AB_1);
        
        
            if ((System.Label.IsRepriseDesdonnees).equals('FE')) {
                queryString += ' (EffectiveDate >: start_Annee_AB_1) And ';
            }
        
             queryString += '(Account.PersonContactId != null) And (Account.PersonContactId In : myKeyset)' + 
                 ' Order By Account.PersonContactId, EffectiveDate ASC';
        System.debug('queryString: ' + queryString);
        // Iterate through the account list
        for(Order od : Database.Query(queryString))  {        
               myMapofOrders.add(od);           
        }
        
        System.debug('############ Number of order retrieved : ' + myMapofOrders.size());
        
        AP03_Account_CalculateAgregats.Account_CalculateAgregats(myMapofOrders);
        
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}