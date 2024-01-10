@IsTest
public class AP10_LastActivtyDateCalculateTest {
    
    
    static testMethod void AP10_LastActivtyDateCalculateTest(){
        List<Account> newPersonAccount = new List<Account>();
        List <Order> newOrder = new List<Order>();
        List <Case> newCase = new List<Case>();
        newPersonAccount = createAccounts(2);
        newOrder = createOrders(3, newPersonAccount[0]);
        newCase = createCases(newPersonAccount[0],5);
        Contact cnt = new Contact () ;
        list <et4ae5__IndividualEmailResult__c> emails = new list <et4ae5__IndividualEmailResult__c>();

        Test.startTest();	
    
    	BatchAccount_CalculateLastDateActivity myBatch = new BatchAccount_CalculateLastDateActivity();
		Id batchinstanceid = database.executeBatch(myBatch);
       	System.AssertEquals (newPersonAccount[0].LastDateActivity__pc , newCase[0].CreatedDate);
    	
        Test.stopTest();
    
    }
    
     public static List<Account> createAccounts(Integer nbAcc) {
        List<Account> accs = new List<Account>();
        Integer i;
        
        for(i= 0; i<nbAcc; i++) {
             Account a = new Account(
            	FirstName = 'Fred' + i,
         		LastName = 'Smith',
         		RecordTypeId = System.label.APAC_Person_Account);                            
            accs.add(a);
       	 }
        insert accs;       
        return accs;
    }
         
        public static List<Order> createOrders(Integer nbOrder,Account acct) {
        List<Order> orders = new List<Order>();
        Integer i = 0;
        Shop__c shop = new Shop__c (name= 'shop1', Shop_Number__c= '234');
        insert shop;
        for(i= 0; i< nbOrder; i++) {
            Order a = new Order(
                AccountId = acct.Id,
                EffectiveDate = Date.newInstance(2016, 12, 9),
                Name = 'My order' + i + acct.FirstName,
                Status = 'Completed',
                Ticket_ID__c = '2010-11-13-F44-4' + i +  acct.Id,
                Pricebook2Id = System.label.StandardPricebook2Id,
                Total_Quantity__c = 2,
                Total_amount__c = 200,
                Shop__c = shop.id
            	);
           
            orders.add(a);
        }
        insert orders;       
        return orders;
    }
    
     public static List<Case> createCases(Account acct, Integer nbCase) {
        List<Case> cases = new List<Case>();
        Integer i = 0;
        
        for(i= 0; i< nbCase; i++) {
            Case c = new Case(
                AccountId = acct.Id
            	);       
            cases.add(c);
        }
        insert cases;       
        return cases;
    }
}