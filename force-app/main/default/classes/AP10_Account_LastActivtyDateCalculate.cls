public with sharing class AP10_Account_LastActivtyDateCalculate {
    

     public static void Account_LastActivtyDateCalculate(Set<Id> setPersonContactId) {

        Map<Account, List<Order>> orderToProces = new Map<Account, List<Order>>();
        Map<Account, List<Case>> caseToProces = new Map<Account, List<Case>>();
        Map<id, List<et4ae5__IndividualEmailResult__c>> emailToProces = new Map<id, List<et4ae5__IndividualEmailResult__c>>();
        Map<Account, List<et4ae5__IndividualEmailResult__c>> emailToProcess = new Map<Account, List<et4ae5__IndividualEmailResult__c>>();

        Map<Id, Date> accountLastActivityDate = new Map<Id, Date>();        

        Map<id,Integer> listOfAccount = new Map<id,Integer>();
        Map<id,account> idAccount = new Map<id,account>();


        

        String queryStringAccount = 'Select ID, Date_of_the_last_purchase__pc, CreatedDate, LastDateActivity__pc,  PersonContactId ' + 
                            ' From Account Where ' +
                            ' PersonContactId In : setPersonContactId ' + 
                            ' Order By PersonContactId, Date_of_the_last_purchase__pc DESC';
                            
        String queryStringCase = 'Select ID, Account.PersonContactId, Account.LastDateActivity__pc,CreatedDate' +
                            ', Account.RecordTypeId ' +                         
                            ' From Case Where ' +
                            ' Account.PersonContactId In : setPersonContactId' + 
                            ' Order By Account.PersonContactId, CreatedDate DESC';
                            
        String queryStringEmail = 'Select ID,et4ae5__Contact__c ,et4ae5__DateOpened__c' +                    
                            ' From et4ae5__IndividualEmailResult__c Where ' +
                            ' et4ae5__Contact__c In : setPersonContactId' + 
                            ' Order By et4ae5__Contact__c, et4ae5__DateOpened__c DESC';                 


        
        
        List<Case> listCases;
        for(Case cse : Database.Query(queryStringCase))  {        
                listCases = caseToProces.get(cse.Account);
                if(listCases==null){
                 listCases = new List<Case>();  
                }
                listCases.add(cse);
                caseToProces.put(cse.Account, listCases);
        }       
        List<et4ae5__IndividualEmailResult__c> listEmails ;
        for(et4ae5__IndividualEmailResult__c  mail : Database.Query(queryStringEmail))  {        
                listEmails= emailToProces.get(mail.et4ae5__Contact__c);
                if(listEmails==null){
                 listEmails = new List<et4ae5__IndividualEmailResult__c>();
                }
                listEmails.add(mail);
                emailToProces.put(mail.et4ae5__Contact__c, listEmails);
        }
        
        
        List<Account> Acctns = [Select Id , PersonContactId from account where PersonContactId in :emailToProces.keySet()];
        List<et4ae5__IndividualEmailResult__c>  emails =  new list <et4ae5__IndividualEmailResult__c>() ;
        for (Account ac : Acctns ) {  
            emails = emailToProces.get(ac.PersonContactId);
            emailToProcess.put(ac,emails);
        }

        if(Database.Query(queryStringAccount).size() > 0){
            for(Account acc : Database.Query(queryStringAccount)){             
                    idAccount.put(acc.id,acc);
                    listOfAccount.put(acc.id, 0);
					System.debug( 'ListOfAccountInitial' + listOfAccount);
                
                //////////////////////// Calcul Date_of_the_last_activity__pc
                if (acc.Date_of_the_last_purchase__pc != null ){
                           accountLastActivityDate.put(acc.Id, acc.Date_of_the_last_purchase__pc);
                           listOfAccount.put(acc.id, 1);
                    }

                    else{
                 System.debug(' Last Date Activity -> ' + acc.Id + ' ' + acc.Date_of_the_last_purchase__pc);
                    }              

            

                    //****************************************************
                    //Une fois le compte traité, on ne le conserve pas dans la Map pour libérer de la mémoire
                    orderToProces.remove(acc);
                    
                }
            }
            
            
            
            
            
        if(CaseToProces.size() > 0){
            for(Account acc : CaseToProces.keySet()){  
                
                for (Case myCase : CaseToProces.get(acc)) {             
                //////////////////////// Calcul Date_of_the_last_activity__pc
                    
                  if(!accountLastActivityDate.containsKey(acc.Id)||  accountLastActivityDate.get(acc.Id) < myCase.CreatedDate){
                     accountLastActivityDate.put(acc.Id, myCase.CreatedDate.date());
                     listOfAccount.put(acc.id, 1);
                     System.debug( 'ListOfAccount' + listOfAccount);
                  }
                    else{
                         System.debug('*****' + accountLastActivityDate.get(acc.Id));     	
                    }              
                }
                    //****************************************************
                    //Une fois le compte traité, on ne le conserve pas dans la Map pour libérer de la mémoire
                    CaseToProces.remove(acc);
                    
                }
            }
            
            if(emailToProcess.size() > 0){
            for(Account acc : emailToProcess.keySet()){        
              for (et4ae5__IndividualEmailResult__c myEmail : emailToProcess.get(acc)) {
               if(myEmail.et4ae5__DateOpened__c != null &&
                    (!accountLastActivityDate.containsKey(acc.Id) || accountLastActivityDate.get(acc.Id) < myEmail.et4ae5__DateOpened__c)){
                  accountLastActivityDate.put(acc.Id, myEmail.et4ae5__DateOpened__c.date());
                  listOfAccount.put(acc.id, 1);
               }
                else{
				  system.debug('Last Activity Date *****' + accountLastActivityDate.get(acc.Id))   ;                 }              
                }
                    
                }
            }
                         
        if(listOfAccount.size() > 0){
            List<Account> listAccountToUpdate = new List<Account>();
           
            for(id idAcc : listOfAccount.keySet()){  
                
               account accountReadyToUpdate  = idAccount.get(idAcc);
                
                    if(listOfAccount.get(idAcc)==1){
                        accountReadyToUpdate.LastDateActivity__pc = accountLastActivityDate.get(idAcc);
                    }else{
                        accountReadyToUpdate.LastDateActivity__pc = accountReadyToUpdate.createddate.date();
                    }

                    listAccountToUpdate.add(accountReadyToUpdate);
                }

            update listAccountToUpdate;
        }
             
     }

     
}