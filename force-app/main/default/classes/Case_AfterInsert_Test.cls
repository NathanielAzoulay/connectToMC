@isTest
private class Case_AfterInsert_Test {
/*
----------------------------------------------------------------------
-- - Name          : Case_AfterInsert_Test
-- - Author        : AAB
-- - Description   : Test class related to the trigger cited below
					- Case_AfterInsert
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 18-OCT-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
static testMethod void test_Case_AfterInsert() {
         // Test data setup
		 List<Account> newPersonAccount = new List<Account>();
		 List <Order> newOrder = new List<Order>();
    	 List <Shop__c> newShop = new List<Shop__c>();
         List<Case> caseList = new List<Case>();	
    
    	// create the list of Accounts 
         newPersonAccount = AP07_Case_AddEmailToCaseFeed_Test.createAccounts(2);
    
    	// Create a shop to associate with the order
    	newShop = AP07_Case_AddEmailToCaseFeed_Test.createShop(1);
    
    	// Create  the according orders
    	newOrder = AP07_Case_AddEmailToCaseFeed_Test.createOrders(1, newPersonAccount[0], newShop[0]);
    	newOrder.addAll(AP07_Case_AddEmailToCaseFeed_Test.createOrders(3, newPersonAccount[1], newShop[0]));
        
    	// Create the needed cases for the test
    	caseList = AP07_Case_AddEmailToCaseFeed_Test.createCases(newPersonAccount, false);
    	
        Test.startTest();
        System.debug('## >>> Perform test  <<< ');
		
    	Database.SaveResult [] srList = new List<Database.SaveResult>();
    	srList = Database.insert(caseList, false);

        System.debug('## >>> Perform test  <<< ');
    
        Test.stopTest();
    
    	List<FeedItem> FeedItemList  = [Select id, CreatedDate, Body, ParentId,Title      
                                   From FeedItem];

    	System.debug('################## my list to check for assert :' + FeedItemList);
    	// assert on the first account
    	System.assertEquals(2, FeedItemList.size());
    }
}