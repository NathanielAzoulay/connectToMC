public with sharing class AP03_Account_CalculateAgregats {
/*
----------------------------------------------------------------------
-- - Name          : AP03_Account_CalculateAgregats
-- - Author        : AAB
-- - Description   : Process the agregat computing on Account         
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 13-MAR-2017  AAB    				1.0      	Initial version
-- 17-OCT-2017  AAB    				1.2      	Modify the field affected to the Favorite product Line
---------------------------------------------------------------------------------------
*/
    
    
    public static Map<Id, List<Order>> orderToProcess{get;set;}
    
    public static void Account_CalculateAgregats(List<Order> myOrderList) {
        ID currentaccount;
        List<Order> myOrders = new List<Order>();
        orderToProcess = new Map<Id, List<Order>>();

        
        for (Order ord : myOrderList) {
            // Fill in my list of order (group by AccountId)
            if (currentaccount != ord.Account.PersonContactId)
            {
                //System.debug('############## debug : ' + );
                if (myOrders.size() > 0) {
                    orderToProcess.put(currentaccount, new List<Order>(myOrders));
                    myOrders.clear();
                } 
            }
            currentaccount = ord.Account.PersonContactId;
            myOrders.add(ord);
		}
        
        if (myOrders.size() > 0) {
                    orderToProcess.put(currentaccount, new List<Order>(myOrders));
        } 
        
        Map<Id,Contact> myNewAccount = new Map<Id,Contact>();
        Contact acc = new Contact();
        
        // Check that we are not on January
        Date currentYear =  
            (System.Today().month() != 1) ?  System.Today() :  System.Today().addYears(-1);   
        
        
        // Define the current year period and seasons
        Date start_Annee_AB = date.valueOf(String.valueOf(currentYear.year()) + System.Label.Start_Annee_AB);
        Date end_Annee_AB = date.valueOf(String.valueOf((start_Annee_AB.addYears(1)).year()) + System.Label.End_Annee_AB);
        Date passage_Saison_1 = start_Annee_AB;
        Date passage_Saison_2 = date.valueOf(String.valueOf(start_Annee_AB.year()) + System.Label.Passage_Saison_Hiver);
        Date start_Annee_AB_1 = start_Annee_AB.addYears(-1);
        
        if (System.today() < passage_Saison_2) {
            passage_Saison_1 = passage_Saison_2.addYears(-1);
            passage_Saison_2 = start_Annee_AB;
        }
        
        
        System.debug('########## start_Annee_AB :' + start_Annee_AB);
        System.debug('########## end_Annee_AB :' + end_Annee_AB);
        System.debug('########## passage_Saison :' + passage_Saison_1);
        System.debug('########## start_Annee_AB_1 :' + start_Annee_AB_1);
        System.debug('########## orderToProcess :' + orderToProcess);
        
        
        
        // Loop through the map to constuct the agregat fields 
        for (Id accId : orderToProcess.keySet()) {
            // My list of order to process (calculate the different agregat fields)
            List<Order> myList = orderToProcess.get(accId);
            Integer tab_size = myList.size();
            List<Id> myshopList = new List<Id>();
                 
            acc.Effective_date_for_update__c = System.today();
            
            
            List<Order> myCurrentSeasonOrders = new List<Order>();
            List<Order> myPreviousSeasonOrders = new List<Order>();
            List<Order> myPreviousYearOrders = new List<Order>();
            
            Map<String,Integer> elCount = new Map<String,Integer>();
			Map<String,Date> elCountDate = new Map<String,Date>();
            Map<String,Integer> elCountItems = new Map<String,Integer>();
			Map<String,Double> elCountItemsPrice = new Map<String,Double>();
            
            
            
            for (Order myOrder : myList) {
                
                // Check if the value is already in the map
                if (!elCount.containsKey(myOrder.Shop__c) && myOrder.Shop__c != null) {
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
                    
                
                // Filter the order with the reference date witch coreponds to the shift date between seasons  
                // If the value is positive it means that the current season is the Summer
                /*System.debug('########### myOrder.EffectiveDate : ' + 
                                 myOrder.EffectiveDate);
                System.debug('########### passage_Saison_Hiver.daysBetween(myOrder.EffectiveDate) : ' 
                                 +  passage_Saison_Hiver.daysBetween(myOrder.EffectiveDate));*/
    
    			
                if (passage_Saison_2.daysBetween(myOrder.EffectiveDate) > 0) {
                   myCurrentSeasonOrders.add(myOrder);
                }
                else if (passage_Saison_1.daysBetween(myOrder.EffectiveDate) > 0) {
                    myPreviousSeasonOrders.add(myOrder);
                }
                else if (start_Annee_AB_1.daysBetween(myOrder.EffectiveDate) > 0) {
                    myPreviousYearOrders.add(myOrder);
                }
                else {
                    System.debug('######### out of current and previous year :' + myOrder.EffectiveDate);
                }
            }
            
            // Number of visits
            acc.Number_of_visits_of_the_current_season__c = myCurrentSeasonOrders.size(); 
            acc.Number_of_visits_last_season__c = myPreviousSeasonOrders.size();

            acc.Turnover_current_season__c = 0;
            acc.Turn_over_last_season__c = 0;
            acc.Turn_over_last_year__c = 0;
            
            acc.Number_of_items_current_season__c = 0;
            acc.Number_of_items_last_season__c = 0;
            acc.Number_of_items_last_year__c = 0;  
            
            
            // compute the turnover current season
            for (Order odw : myCurrentSeasonOrders) {
                acc.Turnover_current_season__c += ((odw.Total_amount__c == null) ? 0 : odw.Total_amount__c);
                acc.Number_of_items_current_season__c += (odw.OrderItems).size();
            }
            
            for (Order ods : myPreviousSeasonOrders) {
                //System.debug('############### : ods.Total_amount__c' + ods.Total_amount__c + 
                             //'my_Turnover_sum_season' + my_Turnover_sum_season);
                acc.Turn_over_last_season__c += ((ods.Total_amount__c == null) ? 0 : ods.Total_amount__c);
                acc.Number_of_items_last_season__c += (ods.OrderItems).size();
            }
            
            
            for (Order odpy : myPreviousYearOrders) {
                //System.debug('############### : ods.Total_amount__c' + ods.Total_amount__c + 
                             //'my_Turnover_sum_season' + my_Turnover_sum_season);
                acc.Turn_over_last_year__c += ((odpy.Total_amount__c == null) ? 0 : odpy.Total_amount__c);
                acc.Number_of_items_last_year__c += (odpy.OrderItems).size();
            }

            
            if (start_Annee_AB.daysBetween(passage_Saison_2) == 0) {
                acc.N_of_visits_during_the_current_year__c = acc.Number_of_visits_of_the_current_season__c;
                acc.Number_of_visits_last_year__c = myPreviousYearOrders.size() + acc.Number_of_visits_last_season__c  ;
                
                acc.Turn_over_current_year__c = acc.Turnover_current_season__c;
                acc.Turn_over_last_year__c += acc.Turn_over_last_season__c;
                
                acc.Number_of_items_during_the_current_year__c = acc.Number_of_items_current_season__c;
                acc.Number_of_items_last_year__c += acc.Number_of_items_last_season__c; 
            }
            else {
                acc.N_of_visits_during_the_current_year__c = acc.Number_of_visits_of_the_current_season__c + 
                acc.Number_of_visits_last_season__c;
                acc.Number_of_visits_last_year__c = myPreviousYearOrders.size();
                
                acc.Turn_over_current_year__c = acc.Turnover_current_season__c + acc.Turn_over_last_season__c;
                //acc.Turn_over_last_year__pc = acc.Turnover_current_season__c;
                
                
                acc.Number_of_items_during_the_current_year__c = acc.Number_of_items_current_season__c + 
                    acc.Number_of_items_last_season__c;
            }
            
            // Fill in the new Accounts with the new calculated fields values
            if (accId != null) {

                Integer numberOfOccurence = 0;
                /*
                
                acc.Favorite_calculated_shop__c = null;
 
                // Calculate the favorite shop
                for(String key : elCount.keySet())
                {
                    if(elCount.get(key) >  numberOfOccurence)
                    {
                    	acc.Favorite_calculated_shop__c = key;
                         numberOfOccurence = elCount.get(key);
                    }
                    else if ((elCount.get(key) == numberOfOccurence) && elCountDate.containsKey(acc.Favorite_calculated_shop__c) && (elCountDate.get(key)).daysBetween(elCountDate.get(acc.Favorite_calculated_shop__c)) < 0){
                        acc.Favorite_calculated_shop__c = key;
                         numberOfOccurence = elCount.get(key);
                        
                    }
                }

                */
				
                /*
                 numberOfOccurence = 0;
                acc.Favorite_product_line__c = '';
                for(String key : elCountItems.keySet())
                {
                    if(elCountItems.get(key) >  numberOfOccurence)
                    {
                    	acc.Favorite_product_line__c = key;
                         numberOfOccurence = elCountItems.get(key);
                    }
                    else if (elCountItems.get(key) ==  numberOfOccurence){
                        if (elCountItemsPrice.get(key) > elCountItemsPrice.get(acc.Favorite_product_line__c)) {
                            acc.Favorite_product_line__c = key;
                         numberOfOccurence = elCountItems.get(key);
                        }     
                    }
                }
                */
             
              
            myNewAccount.put(accId, new Contact (Id = accId,
                Date_of_the_first_purchase__c = acc.Date_of_the_first_purchase__c,
            	Date_of_the_last_purchase__c = acc.Date_of_the_last_purchase__c,
                Number_of_visits_of_the_current_season__c = acc.Number_of_visits_of_the_current_season__c,
            	Number_of_visits_last_season__c = acc.Number_of_visits_last_season__c,
                N_of_visits_during_the_current_year__c = acc.N_of_visits_during_the_current_year__c,
				Number_of_visits_last_year__c = acc.Number_of_visits_last_year__c,
            	Turnover_current_season__c = acc.Turnover_current_season__c,
                Turn_over_last_season__c = acc.Turn_over_last_season__c,
                Turn_over_current_year__c = acc.Turn_over_current_year__c,
                Turn_over_last_year__c = acc.Turn_over_last_year__c, 
				Number_of_items_current_season__c = acc.Number_of_items_current_season__c,
                Number_of_items_last_season__c = acc.Number_of_items_last_season__c,
                Number_of_items_during_the_current_year__c = acc.Number_of_items_during_the_current_year__c,
                Number_of_items_last_year__c = acc.Number_of_items_last_year__c,
				//Favorite_calculated_shop__c = acc.Favorite_calculated_shop__c,
				//Favorite_product_line__c = acc.Favorite_product_line__c,
                Effective_date_for_update__c = acc.Effective_date_for_update__c));
            }
        }
        
        if (myNewAccount.size() > 0) {
            System.debug('############ update myNewAccount : ' + myNewAccount);
            update myNewAccount.values();
        }
	}


}