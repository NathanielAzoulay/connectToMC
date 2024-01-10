public with sharing class AP05_Account {
/*
----------------------------------------------------------------------
-- - Name          : AP05_Account
-- - Author        : AAB
-- - Description   : Class to manage Account Trigger class       
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 27-MAR-2017  AAB    				1.0      	Initial version 
-- 17-OCT-2017  AAB    				1.2      	Update the Favorite shop field
---------------------------------------------------------------------------------------
*/
    public static void updateAccountSegmentations(List<Account> accList, Map<Id,String> segpriorvalueMap) {
        
        // Loop through the account list to update
        for (Account acc : accList) {
            acc.Segmentation_S3__c = acc.Segmentation_S2__c;
            acc.Segmentation_S2__c = acc.Segmentation_S1__c;
            acc.Segmentation_S1__c = segpriorvalueMap.get(acc.id);
            System.debug('*** AP05_Account - updateAccountSegmentations Segmentation_S1__c '+ acc.Segmentation_S1__c);
            System.debug('*** AP05_Account - updateAccountSegmentations Segmentation_S2__c '+ acc.Segmentation_S2__c);
            System.debug('*** AP05_Account - updateAccountSegmentations Segmentation_S3__c '+ acc.Segmentation_S3__c);
        }
	} 
    
    
    public static void updateFavoriteShop(List<Account> accList, Map<Id,Account> oldMapAccount) {
        
        System.debug('############# my Account : ' + accList);
        System.debug('############# my oldMap Account : ' + oldMapAccount);
        // Loop through the account list to update
        for (Account acc : accList) {
            System.debug('############# the Account : ' + acc);
            
            if (acc.Favorite_shop__pc == null || (oldMapAccount.get(acc.id)).Favorite_calculated_shop__pc == acc.Favorite_shop__pc) {
                acc.Favorite_shop__pc = acc.Favorite_calculated_shop__pc;
               // acc.Favorite_calculated_shop__c = null;
            }
        }
	} 
}