public with sharing class AP01_CaseFirstRead {
/*
----------------------------------------------------------------------
-- - Name          : AP01_CaseFirstRead
-- - Author        : AAB
-- - Description   : Class to update the Case Status when it is Open       
-- Maintenance History:
--
-- Date         Name                Version     Remarks 
-- -----------  -----------         --------    ---------------------------------------
-- 03-MAR-2017  AAB                 1.0         Initial version 
---------------------------------------------------------------------------------------
*/

    
    private final Case myCase;
    
    public AP01_CaseFirstRead(ApexPages.StandardController stdController){
        
        // Standard constructor (add the needed fields to retrieve)
        if(!Test.isRunningTest()) {
        stdController.addFields(new List<String>{'WasRead__c','Status', 'RecordTypeId'});
        }
        else {
            System.debug('Running test !');
        }
        
        this.myCase = (Case)stdController.getRecord();
    }
    
    
    
    public void init()
    {
        // Check that the status is new and the Case is read for the first time
        if (this.myCase.Status == 'New' && !this.myCase.WasRead__c) {
            // Upgrade the Case (Status + recordtype)
            this.myCase.WasRead__c = true;
            this.myCase.Status = 'Open';
            this.myCase.RecordTypeId = System.Label.OpenRecordType_ID;
            this.myCase.CaseFirstReadDate__c = DateTime.now();  
            update this.myCase;
            
            //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
            //pageRef.getParameters().put('id',this.myCase.Id);
            
            //pageRef.setRedirect(true);
            //return pageRef;  // Leave the user on the current page*/
            
        }
        //return null;
    }
}