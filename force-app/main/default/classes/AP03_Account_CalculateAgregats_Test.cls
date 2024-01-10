@isTest
private class AP03_Account_CalculateAgregats_Test {
/*
----------------------------------------------------------------------
-- - Name          : BatchAccount_CalculateAgregats_Test
-- - Author        : AAB
-- - Description   : Test class related to the batch cited below
					- BatchAccount_CalculateAgregats
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 16-MAR-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
static testMethod void TestBatchAccount_CalculateAgregats() {
         // Test data setup
		 List<Account> newPersonAccount = new List<Account>();
		 List <Order> newOrder = new List<Order>();
    	 List <Shop__c> newShop = new List<Shop__c>();
         OrderItem newOrderItem = new OrderItem();
        
    
    	// create the list of Accounts 
         newPersonAccount = createAccounts(2);
    
    	// Create a shop to associate with the order
    	newShop = createShop(1);
    
    	// Create  the according orders
    	newOrder = createOrders(3, newPersonAccount[0], newShop[0]);
    	newOrder.addAll(createOrders(3, newPersonAccount[1], newShop[0]));
    	newOrderItem = createOrderItem(newOrder[0]);
    	
    	newOrder[3].EffectiveDate = (newOrder[0].EffectiveDate).addMonths(-24);
    	newOrder[4].EffectiveDate = (newOrder[0].EffectiveDate).addMonths(-7);
    	newOrder[5].EffectiveDate = (newOrder[0].EffectiveDate).addMonths(-13);
            
        update newOrder;
    	
    	
    	/* First scenarios
    	 * We have a 2 personal Accounts
    	 * The first one with three orders at the current season 
    	 * The second with three orders on different season (two on the current yaer and one on the previous year)
		*/
        Test.startTest();
        System.debug('## >>> Perform test  <<< ');
		        
    	BatchAccount_CalculateAgregats_Schedul sh1 = new BatchAccount_CalculateAgregats_Schedul();     
     	String sch = '0  00 1 3 * ?';
       	system.schedule('Test', sch, sh1);
    
    	BatchAccount_CalculateAgregats myBatch = new BatchAccount_CalculateAgregats();
		Id batchinstanceid = database.executeBatch(myBatch);
    	
        System.debug('## >>> Perform test  <<< ');
        Test.stopTest();
    
    	List<Account> myAccountList  = [Select id,CreatedDate, N_of_visits_during_the_current_year__pc, 
                                   Number_of_visits_of_the_current_season__pc,
                                   Number_of_visits_last_season__pc,
                                   Number_of_visits_last_year__pc,
                                   Turnover_current_season__pc,
                                   Number_of_items_current_season__pc     
                                   From Account Where RecordTypeId =:System.label.APAC_Person_Account
                                   Order by CreatedDate ASC limit 2];
    
    
    	System.debug('################## my list to check for assert :' + myAccountList);
    	// assert onthe first account
    	System.assertEquals(myAccountList[0].Number_of_visits_of_the_current_season__pc, myAccountList[0].Number_of_visits_of_the_current_season__pc);
    	System.assertEquals(myAccountList[0].Turnover_current_season__pc, myAccountList[0].Turnover_current_season__pc);
    	System.assertEquals(myAccountList[0].Number_of_items_current_season__pc, myAccountList[0].Number_of_items_current_season__pc);
    
    
    	// assert onthe first account
    	System.assertEquals(0, myAccountList[1].Number_of_visits_of_the_current_season__pc);
    	System.assertEquals(0, myAccountList[1].Turnover_current_season__pc);
    }
    
    
     public static OrderItem createOrderItem(Order ord) {
        OrderItem newOrderItem = new OrderItem();
        Integer i = 0;
        
        Product2 newprod = new Product2(
            					Name = 'Sample product',
        						SKU__c = '123abc');
         
        insert newprod;
         
        PricebookEntry newPriceBook = new PricebookEntry(
        									IsActive = true,
        									Pricebook2Id = System.label.StandardPricebook2Id,
        									Product2Id = newprod.Id,
        									UnitPrice = 200); 
         
        insert newPriceBook;
         
        newOrderItem.OrderId = ord.Id;  
        newOrderItem.PricebookEntryId = newPriceBook.id;
         
        newOrderItem.Quantity = 2;
        newOrderItem.Purchase_date__c = System.today();
        newOrderItem.UnitPrice = 200;
        
         
         
        insert newOrderItem;

        return newOrderItem;
    }
    
    
    
    
     public static List<Shop__c> createShop(Integer nbShop) {
        List<Shop__c> shops = new List<Shop__c>();
        Integer i;
        
        for(i= 0; i<nbShop; i++) {
             Shop__c a = new Shop__c(
            	Shop_Number__c = '12' + i,
         		Name = 'Myshop ' + i);
            
            shops.add(a);
        }
        insert shops;
         
        return shops;
    }
    
    public static List<Account> createAccounts(Integer nbAcc) {
        List<Account> accs = new List<Account>();
        Integer i;
        
        for(i= 0; i<nbAcc; i++) {
             Account a = new Account(
            	FirstName = 'Fred' + i,
         		LastName = 'Smith',
         		RecordTypeId = System.label.APAC_Person_Account,                 
    	 		Effective_date_for_update__pc = System.today());
            
            accs.add(a);
        }

        
        insert accs;
         
        return accs;
    }
    
    public static List<Order> createOrders(Integer nbOrder,Account acct, Shop__c myshop) {
        List<Order> orders = new List<Order>();
        Integer i = 0;
		Date d = System.today();
        
        for(i= 0; i< nbOrder; i++) {
            Order a = new Order(
                AccountId = acct.Id,
                EffectiveDate = d.addMonths(-1),
                Name = 'My order' + i + acct.FirstName,
                Status = 'Completed',
                Ticket_ID__c = '2010-11-13-F44-4' + i +  acct.Id,
                Pricebook2Id = System.label.StandardPricebook2Id,
                Total_Quantity__c = 2,
                Total_amount__c = 200,
            	Shop__c = myshop.id);
           
            orders.add(a);
        }
        
        insert orders;
         
        return orders;
    }
}