@isTest
private class OrderAfterInsert_Test {
/*
----------------------------------------------------------------------
-- - Name          : OrderAfterInsert_Test
-- - Author        : AAB
-- - Description   : Test class related to the trigger cited below
					- OrderAfterInsert
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 17-OCT-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
static testMethod void Test_OrderAfterInsert() {
         // Test data setup
		 List<Account> newPersonAccount = new List<Account>();
		 List <Order> newOrder = new List<Order>();
    	 List <Shop__c> newShop = new List<Shop__c>();
        
    
    	// create the list of Accounts 
         newPersonAccount = AP06_Order_UpdateEffective_Test.createAccounts(2);
    
    	// Create a shop to associate with the order
    	newShop = AP06_Order_UpdateEffective_Test.createShop(1);
    
    	// Create  the according orders
    	newOrder = AP06_Order_UpdateEffective_Test.createOrders(1, newPersonAccount[0], newShop[0]);
    	newOrder.addAll(AP06_Order_UpdateEffective_Test.createOrders(3, newPersonAccount[1], newShop[0]));
            
        
    	
    	
    	/* First scenarios
		*/
        Test.startTest();
        System.debug('## >>> Perform test  <<< ');
		
    	Database.SaveResult [] srList = new List<Database.SaveResult>();
    	srList = Database.update(newOrder, false);

        System.debug('## >>> Perform test  <<< ');
    
        Test.stopTest();
    
    	List<Account> myAccountList  = [Select id, CreatedDate, Effective_date_for_update__pc     
                                   From Account limit 2];
    
    
    	System.debug('################## my list to check for assert :' + myAccountList);
    	// assert on the first account
    	System.assertEquals(Date.today(), myAccountList[0].Effective_date_for_update__pc);
    }
}