/*
----------------------------------------------------------------------
-- - Name          : BatchAccount_CalculatePromophilie
-- - Author        : SA
-- - Description   : Batch qui permet de savoir si un client est promophile ou non
--        
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- XX-O7-2020   SA                  1.0         Init - SF TMA #849
-- 28-10-2020   RDB                 2.0         corrections
---------------------------------------------------------------------------------------
*/
global class BatchAccount_CalculatePromophilie implements Database.Batchable <sObject> {      
    

    /**
     * 
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id ,promophilie__c 
                                        FROM Account 
                                        WHERE PersonContactId <> null 
                                        AND Tech_exclude_from_batch_SF__c = false ]) ;
    }
    
    /**
     * 
     */
    global void execute(Database.BatchableContext bc, List<Account> listAccounts) {
        List <Order> listAllOrders = new List<Order>();
        
        Map<Id, List<Order>> mapOrdersByAccount = new Map<Id, List<Order>>();
        Map<Id,List<OrderItem>> mapProductByOrder = new  Map<Id,List<OrderItem>>();

        Set<Id> setAccountId = extractAccountId(listAccounts);
        
        
        // on va récupérer les commandes (Order) par client (Account) sur les 2 années glissante
        for (Order ord : [SELECT ID, Account.Id, EffectiveDate , Name,Status,Total_amount__c,Ticket_ID__c,Total_Quantity__c,Pricebook2Id
                            FROM Order 
                            WHERE AccountId IN: setAccountId
                            AND EffectiveDate >= :Date.today().addMonths(-24)
                            ORDER BY AccountId,  EffectiveDate]) {
            
            List<Order> listOrdersOfAccount = new List<Order>();
            if(mapOrdersByAccount.containsKey(ord.AccountId)){
                listOrdersOfAccount = mapOrdersByAccount.get(ord.AccountId);
            }

            listOrdersOfAccount.add(ord);
            mapOrdersByAccount.put(ord.AccountId, listOrdersOfAccount);

            listAllOrders.add(ord);
        }
        
        
        // on va récuperer les produit commandés (OrderItem) par commande Order              
        Set <Id> setOrderId = exctractOrderId(listAllOrders);
        for (OrderItem ordItem : [SELECT ID, Order.Id, Discount__c FROM OrderItem WHERE OrderId IN :setOrderId ORDER BY Order.Id]){
            
            List<OrderItem> listOrdItem = new List<OrderItem>();
            if(mapProductByOrder.containsKey(ordItem.Order.Id)){
                listOrdItem = mapProductByOrder.get(ordItem.Order.Id) ;
            }

            listOrdItem.add(ordItem);
            mapProductByOrder.put(ordItem.Order.Id, listOrdItem);
        }

        //on va parcourir chaque client et compter le nombre de produit acheté lors des commande (Order)
        for(Account acc : listAccounts) {
            Double nbrProduitAvecRemise = 0 ;
            Double tauxProduitAvecRemise = 0;
            
            List<Order> listOrders = mapOrdersByAccount.get(acc.Id);
            List<OrderItem> listOrderItemOfAccount = new List<OrderItem>();

            if(listOrders != null && listOrders.size() > 0)  {
                // parcourir chaque commande et recuperer la liste des produits
                for(Order ord : listOrders){
                    List<OrderItem> listOrderItem = mapProductByOrder.get(ord.Id); 
                    if(listOrderItem != null) {
                        listOrderItemOfAccount.addAll(listOrderItem);
                    }
                }
            }
            
            if( listOrderItemOfAccount != null && listOrderItemOfAccount.size() >= 2){
                for (OrderItem ordItem : listOrderItemOfAccount){
                    if(ordItem.Discount__c != null && ordItem.Discount__c > 0 ){
                        nbrProduitAvecRemise ++;
                    }
                }
                tauxProduitAvecRemise =  (nbrProduitAvecRemise/listOrderItemOfAccount.size())*100;
            } 
            
            //A revoir selon règles fournies par Agnès B (ex : nb art < 2 doit arriver sur 1)
            if (listOrderItemOfAccount.size() >= 2 && tauxProduitAvecRemise <= 25){
                acc.promophilie__c = 0;
            } else if((listOrderItemOfAccount.size() >= 2 && tauxProduitAvecRemise > 25 && tauxProduitAvecRemise <=50) || listOrderItemOfAccount.size() < 2 ){
                acc.promophilie__c = 1;
            } else if(listOrderItemOfAccount.size() >= 2 && tauxProduitAvecRemise > 50) {
                acc.promophilie__c = 2;
            }
            
            System.debug(' tauxProduitAvecRemise'+ tauxProduitAvecRemise);
            System.debug(' ******Promophilie'+ acc.promophilie__c);
        }

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
    private Set<Id> extractAccountId(List<Account> listAccounts) {
        Set<Id> setAccountId = new Set<Id>();
        
        for (Account acc : listAccounts) {
            setAccountId.add(acc.Id);
        }
        
        return  setAccountId ;
    }

    /**
     * 
     */
    private Set <Id> exctractOrderId (List<Order> listOrders){
        Set<Id> setOrderId = new Set<id>();
        for(Order ord :listOrders){
            setOrderId.add(ord.id);
        }
        return setOrderId;
    }
    
}