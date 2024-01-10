@IsTest
public class AP11_Account_Agr_Shop_Test {

     static testMethod void AP11_Account_Agr_ShopTest (){
         List<Account> newPersonAccount = new List<Account>();
        List <Order> newOrder = new List<Order>();
          newPersonAccount = createAccounts(1);
          newOrder = createOrders(3, newPersonAccount[0]);
         
          Test.startTest();	
		Id batchJobId = Database.executeBatch(new BatchAccount_CalculateLastDateActivity());
       	System.AssertEquals (newPersonAccount[0].Omnichanel_customer__pc , false );  	
        Test.stopTest();
         
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
}