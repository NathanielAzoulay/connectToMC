public with sharing class AP06_Order_UpdateEffectiveDateForUpdate {
    /*
    ----------------------------------------------------------------------
    -- - Name          : AP06_Order_UpdateEffectiveDateForUpdate
    -- - Author        : AAB
    -- - Description   : Process the Order related Account fields        
    -- Maintenance History:
    --
    -- Date         Name  				Version  	Remarks 
    -- -----------  ----------- 		--------  	---------------------------------------
    -- 03-MAI-2023  FTA                 1.1         Added Account currency calculation
    -- 17-OCT-2017  AAB    				1.0      	Initial version
    ---------------------------------------------------------------------------------------
    */

    public static void updateAccountEffectiveDateAndCurrency(List<Id> myListOfAccountIds) {
        List<Account> myListOfAccount = new List<Account>();
        Database.SaveResult [] srList = new List<Database.SaveResult>();
        
        for (Id accId : myListOfAccountIds) {
           
        }
        
        for (Account acc : [SELECT Id, (SELECT Id, CurrencyIsoCode FROM Orders ORDER BY EffectiveDate DESC) FROM Account WHERE Id IN :myListOfAccountIds]) {
            // Update effective date
            acc.Effective_date_for_update__pc = Date.today();

            // Update Account currency iso code
            String mostRecentCurrencyUsed = '';
            Boolean hasOrdersWithDifferentCurrencies = false;
            for (Order o : acc.Orders) {
                if (String.isEmpty(mostRecentCurrencyUsed)) {
                    mostRecentCurrencyUsed = o.CurrencyIsoCode;
                }

                if (mostRecentCurrencyUsed != o.CurrencyIsoCode) {
                    hasOrdersWithDifferentCurrencies = true;
                }
            }

            if (!String.isEmpty(mostRecentCurrencyUsed)) {
                acc.CurrencyIsoCode = mostRecentCurrencyUsed;
            }

            acc.HasOrdersWithDifferentCurrencies__c = hasOrdersWithDifferentCurrencies;

            myListOfAccount.add(acc);
        }

        if (myListOfAccount.size() > 0) {
            srList = Database.update(myListOfAccount, false);
        }
        
        Check_theDatabaseInsert(srList);
    }
    
    static void Check_theDatabaseInsert(List<Database.SaveResult> srList) {
        
        // Verify that the insertion should process by the trigger 
        // Iterate through each returned result
        System.debug('## >>> Check the Database update  <<< ');
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('The Trigger has been successfully proceed. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}