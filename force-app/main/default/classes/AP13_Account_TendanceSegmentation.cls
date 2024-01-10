public class AP13_Account_TendanceSegmentation {
    
    public static void getAccount_TendanceSegmentation (Set<Id> setPersonContactId){
         
        Map<String, integer> picklistValuesMap = new Map<String, integer>();
		
		List<String> picklistValues = new List <String>();
        picklistValues = getPickListValuesIntoList() ;
        Integer prio = 0;
        
        for (String val :picklistValues){
           picklistValuesMap.put(val,prio); 
           prio= prio+1;
        }
        
        String queryStringTendanceSegmentation = 'Select ID,PersonContactId,' +
                            ' Segmentation__c,Segmentation_S1__c' +                   
                            ' From Account Where ' +
                            ' PersonContactId In : setPersonContactId ' + 
                            ' Order By PersonContactId';
        
        List <Account> AccountToUpdate = new list<Account>();
        for (Account acc : Database.Query(queryStringTendanceSegmentation)){
            String segmentation = acc.Segmentation__c    ;
            String segmentationS1 = acc.Segmentation_S1__c ;
             if (segmentationS1!= null && segmentation!= null){
           		 Integer seg = picklistValuesMap.get(segmentation);
           		 Integer segS1 = picklistValuesMap.get(segmentationS1);
           
            	if (segS1>seg){
                	acc.Tendance_segmentation__pc = Label.LABS_PerconAcc_Downgrade;
           		 } else if (segS1<seg){
                    acc.Tendance_segmentation__pc = Label.LABS_PerconAcc_Upgrade;       
           		 }else{
               	 	acc.Tendance_segmentation__pc = Label.LABS_PerconAcc_Neutre;
           		 }
            }
            AccountToUpdate.add(acc);
            }
        
        
        Update AccountToUpdate;
    
    }
    
    
        public static List<String> getPickListValuesIntoList(){
       		List<String> pickListValuesList= new List<String>();
			Schema.DescribeFieldResult fieldResult = Account.Segmentation__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getValue());
			}     
			return pickListValuesList;
   		 }
}