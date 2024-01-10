/*
----------------------------------------------------------------------
-- - Name          : BatchDeleteDuplicate
-- - Author        : Ahmed Derbel
-- - Description   : Delete duplicate Accounts 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 13-09-2019   A.D    				1.0      	Initial version
---------------------------------------------------------------------------------------
*/
global class BatchDeleteDuplicate  implements Database.Batchable<sObject>, Database.Stateful {
    public String  param {get; set;} 
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT ID, Tech_Master_Id__c FROM Account WHERE Tech_Master_Id__c != null ' ;
        if(param != null){
            query += param ;
        }
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        System.debug('[BatchDeleteDuplicate][execute] Starts ');
        Map<Id,Account> mIdToAccount = new Map<Id,Account>(scope);
        System.debug('##	account maps '+mIdToAccount.keyset());
        List<Case> lCase = [SELECT Id,AccountId,ContactId FROM Case WHERE AccountId IN : mIdToAccount.keyset()];
        Set<String>sMasterAccount	= new Set<String>();
        for(Account anAccount : scope ){
            sMasterAccount.add(anAccount.Tech_Master_Id__c);
        } 
        List<Contact> lMasterContact = [SELECT ID , AccountId FROM Contact WHERE AccountId IN :sMasterAccount ];
        Map<String,Contact> mAccIdToContact = new Map<String,Contact>();
        for(Contact aContact : lMasterContact){
            mAccIdToContact.put(aContact.AccountId, aContact);
        }
        for (Case aCase : lCase){
            aCase.AccountId = mIdToAccount.get(aCase.AccountId).Tech_Master_Id__c ;
            aCase.ContactId = mAccIdToContact.get(aCase.AccountId).Id;
        }       
        System.debug('	##	zerezrze	') ;
        try{
            Update lCase ;
            Delete mIdToAccount.values();
        }catch(exception e ){
            system.debug('##  error during the update '+ e );
        }
        System.debug('[BatchDeleteDuplicate][execute] Ends ');
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}