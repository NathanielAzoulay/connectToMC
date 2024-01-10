/*
----------------------------------------------------------------------
-- - Name          : BatchSegmentationClientEMEA
-- - Author        : SA
-- - Description   : Batch qui permet de déterminer la segmentation des clients EMEA
--        
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- XX-01-2021   SA                  1.0         Init - SF TMA #1168
-- 11-02-2021   RDB                 1.1         corrections
-- 25-02-2021   RDB                 1.2         corrections bug sur la fréquence 
-- 10-03-2021   RDB                 1.3         #1168 - #43 correction bug sur le calcul de la fréquence qui ne retournait un entier au lieu
--                                              d'un nombre à décimale
--                                                + correction prospect qd le client a retourné ses commandes 
-- 10-03-2021   RDB                 1.4         suite au commentaire #46 pour le client Fréquence = nb commandes - retours
---------------------------------------------------------------------------------------
*/
global class BatchSegmentationClientEMEA implements Database.Batchable <sObject> { 

    private static final String ACCOUNT_RT_DEV_NAME = 'EMEA_Person_Account';

    
    /**
     * 
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id emeaRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RT_DEV_NAME).getRecordTypeId();

        return Database.getQueryLocator([SELECT Id ,Segmentation__c,Created_date_Cgid__c,Date_of_the_first_purchase__pc
                                         FROM Account 
                                         WHERE PersonContactId <> null 
                                         AND Tech_exclude_from_batch_SF__c = false
                                         AND RecordTypeId = :emeaRT
                                        ]) ;
    }
    
    /**
     * 
     */
    global void execute(Database.BatchableContext bc, List<Account> listAccounts) {
        System.debug('[BatchSegmentationClientEMEA][execute] start');

        Map<Id, List<Order>> mapOrdersByAccount = new Map<Id, List<Order>>();
        Set<Id> setAccountId = extractAccountId(listAccounts);

        // recupération des commandes par client 
        for (Order ord : [SELECT ID, Account.Id, EffectiveDate , Name,Status,Total_amount__c,Ticket_ID__c,Total_Quantity__c,Pricebook2Id
                          FROM Order 
                          WHERE AccountId IN: setAccountId
                          ORDER BY EffectiveDate DESC ]) {
                              
            List<Order> listOrdersOfAccount = new List<Order>();
            if(mapOrdersByAccount.containsKey(ord.AccountId)){
                listOrdersOfAccount = mapOrdersByAccount.get(ord.AccountId);
            }
            
            listOrdersOfAccount.add(ord);
            mapOrdersByAccount.put(ord.AccountId, listOrdersOfAccount);
        }

        // on parcourt les clients et on détermine la segmentation en fct des commandes (Orders)
        for(Account acc : listAccounts) {
            System.debug('[BatchSegmentationClientEMEA][execute] On traite le compte : ' + acc.Id);
            List<Order> listOrders = mapOrdersByAccount.get(acc.Id);
            
            acc.Segmentation__c = null;  

            if(listOrders == null) {
                // c'est un prospect = contact sans achat
                System.debug('[BatchSegmentationClientEMEA][execute] Aucune commande, le client est un PROSPECT');
                acc.Segmentation__c = 'PRO';  
            } else if(listOrders != null && listOrders.size()>0) {

                // on calcule le montant total des commandes du client
                Double TotalAmount = calculatTotalAmount(listOrders); 
                System.debug('[BatchSegmentationClientEMEA][execute] Montant total des commandes = ' + TotalAmount);

                if(TotalAmount <= 0) {
                    // on gère le cas ou les commandes ont été retournées
                    // donc la liste des commandes n'est pas vide mais le montant total est = 0
                    // donc le client est considéré sans achats = prospect
                    System.debug('[BatchSegmentationClientEMEA][execute] le client est un PROSPECT');
                    acc.Segmentation__c = 'PRO'; 

                } else if((acc.Created_date_Cgid__c !=  null && acc.Created_date_Cgid__c.daysBetween(date.today()) >= 180) 
                        && TotalAmount >= 1500 
                        && listOrders[0].EffectiveDate.daysBetween(date.today()) > 720 ) {
                    // Passif = si la date du dernier ticket a plus de 720 jours (24 mois) ET montant global >= 1500
                    System.debug('[BatchSegmentationClientEMEA][execute] le client est PASSIF');
                    acc.Segmentation__c = 'PAS';   
                } else if ((acc.Created_date_Cgid__c !=  null && acc.Created_date_Cgid__c.daysBetween(date.today()) >= 180) 
                                && TotalAmount < 1500 
                                && listOrders[0].EffectiveDate.daysBetween(date.today()) > 720 ){
                    // Distant = si la date du dernier ticket a plus de 720 jours (24 mois) ET montant global < 1500
                    System.debug('[BatchSegmentationClientEMEA][execute] le client est DISTANT');
                    acc.Segmentation__c = 'DIS';
                } else {
                    // on stocke ici les commandes des 24 derniers mois
                    List<Order> listOrders24 = new List<Order>();
                    for(Order ord:listOrders){
                        if (ord.EffectiveDate >= Date.today().addMonths(-24)){
                            listOrders24.add(ord); 
                        }
                    }
                    
                    if(listOrders24 != null && listOrders24.size()>0) {
                        Double TotalAmount24 = calculatTotalAmount(listOrders24); 
                        Integer nbrCommandeNegatif = calculateNbrOrdNefatif(listOrders24);
                        Integer frequence = 0;
                        
                        if(nbrCommandeNegatif > 0 && TotalAmount24 <= 0) {
                            frequence = 0;
                        } else if(nbrCommandeNegatif > 0 && TotalAmount24 > 0) {
                            frequence = listOrders24.size() - nbrCommandeNegatif;
                        } else {
                            frequence = listOrders24.size();
                        }
                        

                        System.debug('[BatchSegmentationClientEMEA][execute] Montant total des commandes sur les 24 derniers mois : ' + TotalAmount24);
                        System.debug('[BatchSegmentationClientEMEA][execute] Nb commandes : ' + listOrders24.size());
                        System.debug('[BatchSegmentationClientEMEA][execute] Nb de retours : ' + nbrCommandeNegatif);
                        System.debug('[BatchSegmentationClientEMEA][execute] Fréquence : ' + frequence);

                        if((acc.Created_date_Cgid__c != null && acc.Created_date_Cgid__c.daysBetween(date.today()) < 180) 
                            && (frequence >=1)) {
                            
                            // Nouveau = date de création (cegid) inférieure à 180 jours et au moins 1 achat
                            System.debug('[BatchSegmentationClientEMEA][execute] le client est NOUVEAU');
                            acc.Segmentation__c = 'NEW'; 

                        } else if((acc.Created_date_Cgid__c !=  null && acc.Created_date_Cgid__c.daysBetween(date.today()) >= 180) 
                            && TotalAmount24 < 300 || (TotalAmount24 >=300  && TotalAmount24 < 500 &&  frequence < 4 ) 
                            || (TotalAmount24 >= 500 && TotalAmount24 <1500 && frequence == 1)) {
                            
                            // Occasionnel = si montant < 300 / OU si montant entre 300 et < 500 ET fréquence < 4 / 
                            // OU si montant entre 500 et <1500 mais fréquence de 1 seulement
                            System.debug('[BatchSegmentationClientEMEA][execute] le client est OCCASIONNEL');
                            acc.Segmentation__c = 'OCC'; 

                        } else if ((acc.Created_date_Cgid__c !=  null && acc.Created_date_Cgid__c.daysBetween(date.today()) >= 180) 
                            && (TotalAmount24 >=300 && TotalAmount24 < 500 && frequence >= 4) 
                            || (TotalAmount24 >= 500 && TotalAmount24 < 1500 && frequence >= 2)
                            || (TotalAmount24 >= 1500 && frequence == 1)) {
                            
                            // Fidèle = si montant entre 300 et < 500 ET au moins fréquence de 4 / OU
                            // si montant entre 500 et 1500 ET au moins fréquence de 2 / OU si montant >=1500 mais fréquence de 1 seulement
                            System.debug('[BatchSegmentationClientEMEA][execute] le client est FIDELE');    
                            acc.Segmentation__c = 'FID';

                        } else if((acc.Created_date_Cgid__c !=  null && acc.Created_date_Cgid__c.daysBetween(date.today()) >= 180) 
                            && TotalAmount24 >= 1500 && frequence > 1) {
                            
                            // VIP = si montant >=1500 ET fréquence > 1
                            System.debug('[BatchSegmentationClientEMEA][execute] le client est VIP');
                            acc.Segmentation__c = 'VIP';
                        }
                    }
                }
            }
        } 

        // mise à jour de la segmentation des clients
        Database.update(listAccounts, false);  
    } 
    
    /**
     * 
     */
    global void finish(Database.BatchableContext bc){
        
    }   

    /**
     * 
     */
    public static Set<Id> extractAccountId(List<Account> listAccounts) {
        Set<Id> setAccountId = new Set<Id>();
        
        for (Account acc : listAccounts) {
            setAccountId.add(acc.Id);
        }
        
        return  setAccountId ;
    }

    /**
     * 
     */
    public static integer calculateNbrOrdNefatif (List<Order> listOrders){
        Integer nbrCommandeNegatif = 0;

        if(listOrders != null && listOrders.size() > 0) {
            for(Order ord : listOrders) {
                if(ord.Total_amount__c < 0){
                    nbrCommandeNegatif ++;
                }
                
            }
        }

        return nbrCommandeNegatif;
    }

    /**
     * 
     */
    public static Double calculatTotalAmount (List<Order> listOrders){
        Double TotalAmount = 0;

        if(listOrders != null && listOrders.size() > 0) {
            for(Order ord : listOrders){
                    TotalAmount = TotalAmount + ord.Total_amount__c;
            }
        }

        return  TotalAmount;
    }
}