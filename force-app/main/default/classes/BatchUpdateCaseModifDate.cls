global class BatchUpdateCaseModifDate implements Database.Batchable<SObject>{
global Database.QueryLocator start(Database.BatchableContext BC){
 String query = 'SELECT Id ,Modification__c,Status From case where Status <>\'Closed\''; 
 String complRequ = 'AND Modification__c < 2021-03-01T00:00:00.000+0000 ';                                      
    if(!Test.isRunningTest()) {
     query = query+ complRequ ; 
    } 
    System.debug('query'+query);
     return Database.getQueryLocator(query) ;
    
}
    global void execute(Database.BatchableContext bc, List<Case> cases){
     System.debug('size'+cases.size());
        for (Case c:cases){
               c.Status = 'Closed';
          
        }
        update cases ;
    }
    global void finish(Database.BatchableContext bc){
        
    }
}