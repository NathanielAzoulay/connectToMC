public with sharing class AP07_Case_AddEmailToCaseFeed {
/*
----------------------------------------------------------------------
-- - Name          : AP07_Case_AddEmailToCaseFeed
-- - Author        : AAB
-- - Description   : Process the Case related triggers        
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 18-OCT-2017  AAB    				1.0      	Initial version
---------------------------------------------------------------------------------------
*/

    
    public static void addEmailToCaseFeed (List<Case>  myListOfCase) {
        Database.SaveResult [] srList = new List<Database.SaveResult>();
        List<FeedItem> FeedItems = new List<FeedItem>();
        

        // Create the Case feed with the emailMessages information
        for (Case c : myListOfCase) {
           FeedItems.add(new FeedItem(ParentId = c.Id, Title = c.Subject, IsRichText = true,
                         Body = '<b>Object : </b> ' + c.Subject + '<p>&nbsp;</p>' +
                                '<b>Description : </b>  ' + '<p>&nbsp;</p>' + 
                                c.Description));
        }
        
        // Insert the new fed item
        if (FeedItems.size() > 0){
            srList = Database.insert(FeedItems, false);
            Check_theDatabaseInsert(srList);
        }
    }
    
    
    
    static void Check_theDatabaseInsert(List<Database.SaveResult> srList) {
        
        // Verify that the insertion should process by the trigger 
        // Iterate through each returned result
        System.debug('## >>> Check the Database update  <<< ');
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('The Trigger has been successfully proceed. FeedItem  ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('FeedItem fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}