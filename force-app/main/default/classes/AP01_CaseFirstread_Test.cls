@isTest
public class AP01_CaseFirstread_Test {
    /*
----------------------------------------------------------------------
-- - Name          : AP01_CaseFirstread_Test
-- - Author        : AAB
-- - Description   : Test class related to the Apex classes cited below
					- AP01_CaseFirstread
					- 
-- Maintenance History:
--
-- Date         Name  				Version  	Remarks 
-- -----------  ----------- 		--------  	---------------------------------------
-- 03-MAR-2017  AAB    				1.0      	Initial version 
---------------------------------------------------------------------------------------
*/
static testMethod void TestAP01_CaseFirstread() {
         
    	Test.startTest();
    
    	List<Case> myCase =  new List<Case>();	
    	PageReference pageRef1 = Page.VF02_CaseFirstRead;
        Test.setCurrentPage(pageRef1);
    
    	myCase = createCases(1, 'New', 'E-mail');
   		myCase[0].WasRead__c = false;
    	insert myCase[0];
    
    	AP01_CaseFirstRead myPage = new AP01_CaseFirstRead(new ApexPages.StandardController(myCase[0]));
    	myPage.init();

    }
    
    
    public static List<Case> createCases(Integer numCases, String status, String origine) {
        List<Case> caseList = new List<Case>();
        
        for(Integer i=0;i<numCases;i++) {
            Case c = new Case(
                			Status = status,
        					Origin = origine,
                			WasRead__c = false
            );
            caseList.add(c);
        }

        return caseList;
    }
}