@isTest
public with sharing class AP02_chattermarqueeTest {
    
/*
----------------------------------------------------------------------
-- - Name          : AP02_chattermarqueeTest
-- - Author        : AAB
-- - Description   : Test class related to the classes cited below
					- AP02_chattermarquee
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 08-MAR-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
    

    public static testMethod void testMyController() {
        PageReference pageRef = Page.VF01_ChatterMarquee;
        Test.setCurrentPage(pageRef);
      
        List<CollaborationGroup> collGroup = new List<CollaborationGroup>();
        collGroup.add(new  CollaborationGroup(Name='Chatter marqueee',CollaborationType ='Public'));
        insert collGroup;
        
        AP02_chattermarquee controller = new AP02_chattermarquee();
    }
}