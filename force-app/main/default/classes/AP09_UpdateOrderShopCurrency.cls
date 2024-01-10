/** 
* @author Pauline
* @description classe qui permet de mettre à jour les devises des commandes et boutiques
*/
public with sharing class AP09_UpdateOrderShopCurrency
{ 
    /**
    * @description MAJ de la devise des commandes à partir des boutiques
    * @param list id order
    * @return void retourne rien
    */
    public static void updateCurrencyForOrders(List<Order> listOrders, List<Id> listShopIds){
        System.debug('*** AP09_UpdateOrderCurrency - updateCurrencyForOrders ' + listOrders.size());

        Map<Id, Shop__c> mapShops = new Map<Id, Shop__c>([SELECT Id, CurrencyIsoCode FROM Shop__c WHERE Id IN :listShopIds]);
        for(Order anOrder : listOrders) {
            if (anOrder.shop__c != null
                && mapShops.get(anOrder.shop__c) != null
                && !String.isBlank(mapShops.get(anOrder.shop__c).CurrencyIsoCode)) {

                anOrder.CurrencyIsoCode = mapShops.get(anOrder.shop__c).CurrencyIsoCode;
            }
        }
    }

    /**
    * @description MAJ de la devise des boutiques
    * @param list boutique
    * @return void retourne rien
    */
    public static void updateCurrencyForShops(List<Shop__c> listShops){
        System.debug('*** AP09_UpdateOrderCurrency - updateCurrencyForShops' + listShops.size());
        List <Shop__c> lisShopToUpd = new List <Shop__c> ();
        
        for(Shop__c aShop : listShops){
            if (!String.isBlank(aShop.Currency__c)){
                aShop.CurrencyIsoCode = aShop.Currency__c;
               // lisShopToUpd.add(aShop);
            }
        }
        /*if (lisShopToUpd.size() > 0){
            update lisShopToUpd;
        }*/
    }

}