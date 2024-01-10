@isTest
public class AP07_Case_AddEmailToCaseFeed_Test {
/*
----------------------------------------------------------------------
-- - Name          : AP07_Case_AddEmailToCaseFeed_Test
-- - Author        : AAB
-- - Description   : Test class related to the classes cited below
					- AP07_Case_AddEmailToCaseFeed
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 18-OCT-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
    
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
    
     public static List<Case> createCases(List<Account> myAccList, Boolean isTonsert) {
		List<Case> myCases = new List<Case>();
         
        for(Account acc : myAccList) {
             Case c = new Case(
                AccountId = acc.Id, 
            	Subject = 'Test subject' + acc.Name,
         		Description = 'Hello !',
         		Origin = 'E-mail');
            
            myCases.add(c);
        }

         if (isTonsert) {
             insert myCases;
         }

        return myCases;
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