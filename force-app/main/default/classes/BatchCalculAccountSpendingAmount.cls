/*
----------------------------------------------------------------------
-- - Name          : BatchCalculAccountSpendingAmount
-- - Author        : RDB
-- - Description   : Calcule les montants dépensés par client et par période
--         
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 17-02-2020   RDB                 1.0         Initial version
---------------------------------------------------------------------------------------
*/
global class BatchCalculAccountSpendingAmount  implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('[BatchCalculAccountSpendingAmount][start] start');
        return Database.getQueryLocator([SELECT Id, PersonContactId, L3M_spending__c, L6M_spending__c, L9M_spending__c, 
                                                L12M_spending__c , L13_24M_Spending__c
                                        FROM Account
                                        WHERE PersonContactId <> null 
                                        AND Tech_exclude_from_batch_SF__c = false
                                        AND RecordTypeId = :System.Label.LABS_PerconAcc_RT_APAC]) ;
    }

    global void execute(Database.BatchableContext bc, List<Account> listAccounts){      
        System.debug('[BatchCalculAccountSpendingAmount][execute] execute');  
        Map<Account, List<Order>> mapOrdersByAccount = new Map<Account, List<Order>>();
        Set<Id> setPersonContactId = extractPersonContactId(listAccounts);

        // on va récupérer les commandes (Order) par client (Account) sur les 24 derniers mois glissants
        // et on les met dans une Map indexée par client
        for(Order ord : [SELECT ID, Account.PersonContactId, EffectiveDate, Total_amount__c                       
                        FROM Order 
                        WHERE 
                        Account.PersonContactId IN :setPersonContactId 
                        AND EffectiveDate >= :Date.today().addMonths(-24)
                        ORDER BY Account.PersonContactId, EffectiveDate]) {
            
            List<Order> listOrders = new List<Order>();
            if(mapOrdersByAccount.containsKey(ord.Account)) {
                listOrders = mapOrdersByAccount.get(ord.Account);
            }
            listOrders.add(ord);
            mapOrdersByAccount.put(ord.Account, listOrders);
        }

        // on va parcourir chaque client et compter les montants dépensés lors des commandes (Order)
        for (Account acc : listAccounts) {
            System.debug('[BatchCalculAccountSpendingAmount][execute] On traite le compte : ' + acc);  
            List<Order> listOrders = mapOrdersByAccount.get(acc);
            
            // on réinitialise tout à 0
            acc.L3M_spending__c = 0;
            acc.L6M_spending__c = 0;
            acc.L9M_spending__c = 0;
            acc.L12M_spending__c = 0;
            acc.L13_24M_Spending__c = 0;

            if(listOrders != null  && listOrders.size() > 0) {
                System.debug('[BatchCalculAccountSpendingAmount][execute] Nbre de commandes : ' + listOrders.size()); 
                for (Order ord : listOrders) {
                    // montant dépensé sur les 3 derniers mois
                    if(ord.EffectiveDate >= Date.today().addMonths(-3)) {
                        acc.L3M_spending__c = acc.L3M_spending__c  + ord.Total_amount__c;
                    }        
                    // montant dépensé sur les 6 derniers mois            
                    if(ord.EffectiveDate >= Date.today().addMonths(-6)) {
                        acc.L6M_spending__c = acc.L6M_spending__c  + ord.Total_amount__c;
                    }                    
                    // montant dépensé sur les 9 derniers mois            
                    if(ord.EffectiveDate >= Date.today().addMonths(-9)) {
                        acc.L9M_spending__c = acc.L9M_spending__c  + ord.Total_amount__c;
                    }                    
                    // montant dépensé sur les 12 derniers mois            
                    if(ord.EffectiveDate >= Date.today().addMonths(-12)) {
                        acc.L12M_spending__c = acc.L12M_spending__c  + ord.Total_amount__c;
                    }                    
                    // montant dépensé entre les 13 et 24 derniers mois            
                    if(ord.EffectiveDate >= Date.today().addMonths(-24) && ord.EffectiveDate <= Date.today().addMonths(-13)) {
                        acc.L13_24M_Spending__c = acc.L13_24M_Spending__c  + ord.Total_amount__c;
                    }                    
                }

                System.debug('[BatchCalculAccountSpendingAmount][execute] Montant dépensé sur les 3 derniers mois : ' + acc.L3M_spending__c); 
                System.debug('[BatchCalculAccountSpendingAmount][execute] Montant dépensé sur les 6 derniers mois : ' + acc.L6M_spending__c); 
                System.debug('[BatchCalculAccountSpendingAmount][execute] Montant dépensé sur les 9 derniers mois : ' + acc.L9M_spending__c); 
                System.debug('[BatchCalculAccountSpendingAmount][execute] Montant dépensé sur les 12 derniers mois : ' + acc.L12M_spending__c); 
                System.debug('[BatchCalculAccountSpendingAmount][execute] Montant dépensé entre les 13 et 24 derniers mois : ' + acc.L13_24M_Spending__c); 

            } else {
                System.debug('[BatchCalculAccountSpendingAmount][execute] Pas de commandes pour ce compte '); 
            }
        }

        // sauvegarde des clients avec leur montant dépensé
        Database.update(listAccounts, false);
    }    

    global void finish(Database.BatchableContext bc){
        System.debug('[BatchCalculAccountSpendingAmount][finish] finish'); 
    }    

    private Set<Id> extractPersonContactId(List<Account> listAccounts) {
        Set<Id> setPersonContactId = new Set<Id>();

        for (Account acc : listAccounts) {
            setPersonContactId.add(acc.PersonContactId);
        }

        return setPersonContactId;
    }
}