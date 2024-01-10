@isTest
private class Account_BeforeUpdate_Test {
    /*
----------------------------------------------------------------------
-- - Name          : Account_BeforeUpdate_Test
-- - Author        : AAB
-- - Description   : Test class related to the trigger cited below
					- Account_BeforeUpdate
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 27-MAR-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
    static void Check_theDatabaseInsert(List<Database.SaveResult> srList) {
        
        // Verify that the insertion should process by the trigger 
        // Iterate through each returned result
        System.debug('## >>> Check the Database insert  <<< ');
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('The Trigger has been successfully proceed. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    
    
    public static List<Account> createAccounts(Integer nbAcc) {
        List<Account> accs = new List<Account>();
        Integer i;
        
        for(i= 0; i<nbAcc; i++) {
             Account a = new Account(
            	FirstName = 'Fred' + i,
         		LastName = 'Smith',
         		RecordTypeId = System.label.APAC_Person_Account,                 
    	 		Effective_date_for_update__pc = System.today(),
             	Segmentation__c = 'OCC');
            
            accs.add(a);
        }

        
        insert accs;
         
        return accs;
    }
    
    
    
    
    static testMethod void TestAccount_BeforeUpdate() {
         // Test data setup
         List<Account> newPersonAccount = new List<Account>();
         List <Shop__c> newShop = new List<Shop__c>();
        
        // create the list of Accounts 
         newPersonAccount = createAccounts(1);
        
        // Create a shop to associate with the order
    	newShop = createShop(1);
        
        
        Test.startTest();
        System.debug('## >>> Perform test  <<< ');
        newPersonAccount[0].Segmentation__c = '	NEW';
        update newPersonAccount;
        newPersonAccount[0].Segmentation__c = '	FID';
        //newPersonAccount[0].Favorite_calculated_shop__pc = newShop[0].Id;
        update newPersonAccount;
        newPersonAccount[0].Segmentation__c = '	DIS';
        
        Database.SaveResult[] srList = Database.update(newPersonAccount, false);
        Test.stopTest();
                
        Check_theDatabaseInsert(srList);
        
        
        
        List<Account> accounts  = [Select id, Segmentation__c, Segmentation_S1__c,
                                   Segmentation_S2__c, Segmentation_S3__c, RecordTypeId 
                                   From Account Where RecordTypeId =:System.label.APAC_Person_Account limit 1];
        
        // Check that all the trigger update work
        // by comparing the expected values with the real values
        System.assertEquals('OCC', accounts[0].Segmentation_S3__c, 'The Segmentation 3 value is right !' );
        System.assertEquals('NEW', accounts[0].Segmentation_S2__c, 'The Segmentation 2 value is right !' );
        System.assertEquals('FID', accounts[0].Segmentation_S1__c, 'The Segmentation 1 value is right !' );
        System.assertEquals('DIS', accounts[0].Segmentation__c, 'The Segmentation value is right !' );

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
    
    
}