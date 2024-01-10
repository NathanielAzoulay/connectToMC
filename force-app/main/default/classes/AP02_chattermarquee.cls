public with sharing class AP02_chattermarquee{
    
/*
----------------------------------------------------------------------
-- - Name          : AP02_chattermarquee
-- - Author        : AAB
-- - Description   : Class to manage chattermarquee on Sercice cloud       
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 08-MAR-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
    
    
    public CollaborationGroup myalertgroup {get;set;}
    public List<CollaborationGroup> myalertgrouplist;
    
    public AP02_chattermarquee(){
        myalertgrouplist = new List<CollaborationGroup>();
        
        myalertgrouplist=[SELECT Id,Name FROM CollaborationGroup where Name='Chatter marquee' limit 1];
        
        if (myalertgrouplist.size() > 0)
          myalertgroup = myalertgrouplist[0];
        
        else {
            myalertgroup = null;
        }
    }
}