public with sharing class AP08_Account_FavoriteCalculatedShop {
    

     public static void Account_FavoriteCalculatedShop(Set<Id> setPersonContactId) {

        Map<Account, List<Order>> orderToProces = new Map<Account, List<Order>>();

        Map<Id, String> accountFavoriteShop = new Map<Id, String>();
        Map<Id, String> accountProductLine = new Map<Id, String>();
        Map<Id, Decimal> accountTotalAmount = new Map<Id, Decimal>();
        Map<Id, Date> accountFirstPurchase = new Map<Id, Date>();
        Map<Id, Date> accountLastPurchase = new Map<Id, Date>();
        Map<Id, Date> accountPenultimatePurchase = new Map<Id, Date>();

        Map<Account,Integer> listOfAccount = new Map<Account,Integer>();

        Map <Id, Account> mapIdAccount = new Map<Id, Account> ([SELECT Id, Effective_date_for_update__pc FROM Account WHERE PersonContactId IN :setPersonContactId]);

        //Filtre pour exclure les comptes APAC de la MAJ de l'accumulated spending amount
        Map <Id, Boolean> mapIdAccUpdAccumSpendAmount = new Map <Id, Boolean> ();

        String queryStringFavoriteShop = 'Select ID, Account.PersonContactId, Account.Favorite_calculated_shop__pc,' +
                            ' EffectiveDate, Shop__c, Total_amount__c, Account.Date_of_the_first_purchase__pc,' +
                            ' Account.Date_of_the_last_purchase__pc, Account.Penultimate_date_of_purchase__pc, Account.RecordTypeId, ' + 
                            ' (Select Id, Product2Id, Quantity, UnitPrice, Product2.Product_line__c From OrderItems)' +                           
                            ' From Order Where ' +
                            ' Account.PersonContactId In : setPersonContactId ' + 
                            ' Order By Account.PersonContactId, EffectiveDate DESC';


        for(Order ord : Database.Query(queryStringFavoriteShop))  {        
            if(orderToProces.containsKey(ord.Account)){
                List<Order> listOrders = orderToProces.get(ord.Account);
                listOrders.add(ord);
                orderToProces.put(ord.Account, listOrders);
            }
            else{
                List<Order> listOrders = new List<Order>();
                listOrders.add(ord);
                orderToProces.put(ord.Account, listOrders);
            } 
        }

        if(orderToProces.size() > 0){
            for(Account acc : orderToProces.keySet()){

                //Vérification si filtre APAC
                System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - AccumSpendAmount RT : ' + acc.RecordTypeId);
                   
                if (acc.RecordTypeId != Label.LABS_PerconAcc_RT_APAC){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - MAJ AccumSpendAmount : TODO');
                    mapIdAccUpdAccumSpendAmount.put(acc.Id, true);
                }
                else{
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - MAJ AccumSpendAmount : NO');
                    mapIdAccUpdAccumSpendAmount.put(acc.Id, false);
                }

                Date effectiveDate = Date.today();

                if (mapIdAccount.get(acc.Id).Effective_date_for_update__pc != null) {
                    effectiveDate = mapIdAccount.get(acc.Id).Effective_date_for_update__pc;
                }  
                System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - effectiveDate -> ' + effectiveDate);

                Date last3years = effectiveDate.addYears(-3);
                System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - last3years -> ' + last3years);

                Map<String,Integer> elCount = new Map<String,Integer>();
                Map<String,Date> elCountDate = new Map<String,Date>();
                Map<String,Integer> elCountItems = new Map<String,Integer>();
                Map<String,Double> elCountItemsPrice = new Map<String,Double>();
                
                for (Order myOrder : orderToProces.get(acc)) {
                    //////////////////////// Calcul accumulated spending amount
                    if(myOrder.Total_amount__c != null){
                        if(accountTotalAmount.containsKey(acc.Id)){
                            accountTotalAmount.put(acc.Id, accountTotalAmount.get(acc.Id) + myOrder.Total_amount__c);
                        }
                        else{
                            accountTotalAmount.put(acc.Id, myOrder.Total_amount__c);
                        }
                        listOfAccount.put(acc, 1);
                    }

                   //////////////////////// Calcul Date_of_the_first_purchase__pc
                    if (myOrder.Account.Date_of_the_first_purchase__pc == null || (myOrder.EffectiveDate != null && myOrder.Account.Date_of_the_first_purchase__pc > myOrder.EffectiveDate)){
                        if(!accountFirstPurchase.containsKey(acc.Id) || accountFirstPurchase.get(acc.Id) > myOrder.EffectiveDate){
                           accountFirstPurchase.put(acc.Id, myOrder.EffectiveDate);
                           listOfAccount.put(acc, 1);
                       }
                    }
                    
                    //////////////////////// Calcul Date_of_the_last_purchase__pc
                    if (myOrder.Account.Date_of_the_last_purchase__pc == null || (myOrder.EffectiveDate != null && myOrder.Account.Date_of_the_last_purchase__pc < myOrder.EffectiveDate)){
                        if(!accountLastPurchase.containsKey(acc.Id) || accountLastPurchase.get(acc.Id) < myOrder.EffectiveDate){
                           accountLastPurchase.put(acc.Id, myOrder.EffectiveDate);
                           listOfAccount.put(acc, 1);
                       }
                    }

                    //////////////////////// Calcul Penultimate_date_of_purchase__c
                    if (myOrder.Account.Penultimate_date_of_purchase__pc == null || (myOrder.EffectiveDate != null && myOrder.Account.Penultimate_date_of_purchase__pc < myOrder.EffectiveDate)){
                        //Si qu'une commande, ne pas mettre à jour la date d'avant-dernier achat
                        if(!accountPenultimatePurchase.containsKey(acc.Id)){
                           accountPenultimatePurchase.put(acc.Id,null);
                       }
                       //Ajout de la date de l'avant-dernier achat - si inférieure à la dernière date d'achat
                       else if(accountPenultimatePurchase.get(acc.Id) == null && accountLastPurchase.get(acc.Id) > myOrder.EffectiveDate){
                            accountPenultimatePurchase.put(acc.Id,myOrder.EffectiveDate);
                            listOfAccount.put(acc, 1);
                        }
                    }

                    ////////////////////////
                    if(myOrder.EffectiveDate >= last3years){
                            // Check if the value is already in the map
                        if (myOrder.Shop__c != null && !elCount.containsKey(myOrder.Shop__c)) {
                            elCount.put(myOrder.Shop__c, 1);
                            elCountDate.put(myOrder.Shop__c, myOrder.EffectiveDate);
                        }
                        // Else, update the number of times a shop had been visited
                        else if (myOrder.Shop__c != null){
                            elCount.put(myOrder.Shop__c, elCount.get(myOrder.Shop__c) +1);
                            if ((elCountDate.get(myOrder.Shop__c)).daysBetween(myOrder.EffectiveDate) > 0) {
                                elCountDate.put(myOrder.Shop__c, myOrder.EffectiveDate);
                            }
                        }

                    }
                    else{
                         System.debug('***** AP08_Account_FavoriteCalculatedShop - Account_FavoriteCalculatedShop - Order non pris en compte -> ' + myOrder.Id + ' - ' + myOrder.EffectiveDate);
                    }              

                    //*****************************************************************************
                    // Calculate the favorite items
                    for (OrderItem od : myOrder.OrderItems) {
                        
                        // Check if the value is already in the map
                        if (!elCountItems.containsKey(od.Product2.Product_line__c) && od.Product2Id != null && 
                           od.Product2.Product_line__c != null) {
                            elCountItems.put(od.Product2.Product_line__c, 1);
                            elCountItemsPrice.put(od.Product2.Product_line__c, od.Quantity*od.UnitPrice);
                        }
                        // Else, update the number of times a article had been buy
                        else if (od.Product2Id != null && od.Product2.Product_line__c != null){
                            elCountItems.put(od.Product2.Product_line__c, elCountItems.get(od.Product2.Product_line__c) +1);
                            elCountItemsPrice.put(od.Product2.Product_line__c, elCountItemsPrice.get(od.Product2.Product_line__c) + od.Quantity*od.UnitPrice);
                        }
                    }
                    
                    System.debug('######### my map of favorite product line : ' + elCountItems);
                    System.debug('######### my map of favorite product line : ' + elCountItemsPrice);

                    //*****************************************************************************

                }

                Integer numberOfOccurence = 0;

                acc.Favorite_calculated_shop__pc = null;
     
                    // Calculate the favorite shop
                    for(String key : elCount.keySet())
                    {
                        if((elCount.get(key) > numberOfOccurence) || ((elCount.get(key) == numberOfOccurence) && elCountDate.containsKey(acc.Favorite_calculated_shop__pc) && (elCountDate.get(key)).daysBetween(elCountDate.get(acc.Favorite_calculated_shop__pc)) < 0))
                        {
                            acc.Favorite_calculated_shop__pc = key;
                            accountFavoriteShop.put(acc.Id, key);
                            numberOfOccurence = elCount.get(key);
                            listOfAccount.put(acc, 1);
                        }                    
                    }

                    //****************************************************
                    numberOfOccurence = 0;
                    acc.Favorite_product_line__pc = '';
                    for(String key : elCountItems.keySet())
                    {
                        if(elCountItems.get(key) >  numberOfOccurence)
                        {
                            acc.Favorite_product_line__pc = key;
                             numberOfOccurence = elCountItems.get(key);
                        }
                        else if (elCountItems.get(key) ==  numberOfOccurence){
                            if (elCountItemsPrice.get(key) > elCountItemsPrice.get(acc.Favorite_product_line__pc)) {
                                acc.Favorite_product_line__pc = key;
                                accountProductLine.put(acc.Id, key);
                                numberOfOccurence = elCountItems.get(key);
                                listOfAccount.put(acc, 1);
                            }     
                        }
                    }
                    //Une fois le compte traité, on ne le conserve pas dans la Map pour libérer de la mémoire
                    orderToProces.remove(acc);
                    
                }
            }

        if(listOfAccount.size() > 0){
            List<Account> listAccountToUpdate = new List<Account>();

            for(Account aAccount : listOfAccount.keySet()){                
                if(!listAccountToUpdate.contains(aAccount)){
                    listAccountToUpdate.add(aAccount);
                }
            }

            for(Account aAccount : listAccountToUpdate){
                
                
                aAccount.Date_Calc_Favorite_calculated_shop__c = Date.today(); 
                
                
                //On ne met à jour que les comptes dans la mapIdAccUpdAccumSpendAmount (donc hors APAC) pour Accumulated_spending_amount__pc
                if(accountTotalAmount.get(aAccount.Id) != null && mapIdAccUpdAccumSpendAmount.get(aAccount.Id)){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Accumulated_spending_amount__pc -> ' + aAccount.Id+ ' -  '+ accountTotalAmount.get(aAccount.Id));
                    aAccount.Accumulated_spending_amount__pc = accountTotalAmount.get(aAccount.Id);
                }

                if(accountFavoriteShop.get(aAccount.Id) != null){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Favorite_calculated_shop__pc -> '  + aAccount.Id+ ' -  '+ accountFavoriteShop.get(aAccount.Id));
                    aAccount.Favorite_calculated_shop__pc = accountFavoriteShop.get(aAccount.Id);
                }
                
                if(accountProductLine.get(aAccount.Id) != null){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Favorite_product_line__pc -> '  + aAccount.Id+ ' -  '+  accountProductLine.get(aAccount.Id));
                    aAccount.Favorite_product_line__pc = accountProductLine.get(aAccount.Id);
                }

                if(accountFirstPurchase.get(aAccount.Id) != null){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - FirstPurchase -> '  + aAccount.Id+ ' -  '+  accountFirstPurchase.get(aAccount.Id));
                    aAccount.Date_of_the_first_purchase__pc = accountFirstPurchase.get(aAccount.Id);
                }

                if(accountLastPurchase.get(aAccount.Id) != null){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - LastPurchase -> '  + aAccount.Id+ ' -  '+  accountLastPurchase.get(aAccount.Id));
                    aAccount.Date_of_the_last_purchase__pc = accountLastPurchase.get(aAccount.Id);
                }
                //Mise à jour uniquement si date d'avant dernier achat différent de premier achat
                if(accountPenultimatePurchase.get(aAccount.Id) != null && accountPenultimatePurchase.get(aAccount.Id) > aAccount.Date_of_the_first_purchase__pc){
                    System.debug('***** AP08_Account_FavoriteCalculatedShop - Penultimate_date_of_purchase__pc -> '  + aAccount.Id+ ' -  '+  accountPenultimatePurchase.get(aAccount.Id));
                    aAccount.Penultimate_date_of_purchase__pc = accountPenultimatePurchase.get(aAccount.Id);
                }

                System.debug('AcoountToUpdate' + aAccount);
            }
            
           
            update listAccountToUpdate;
        }       
        
     }
}