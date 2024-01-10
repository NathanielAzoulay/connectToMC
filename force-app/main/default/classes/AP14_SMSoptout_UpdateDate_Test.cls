@istest
public class AP14_SMSoptout_UpdateDate_Test {

    
    @istest 
    public static void getUpdateUnsubDate (){
        
         Account acc = new Account(
         FirstName = 'Fred',
         LastName = 'Smith',
         SMS_optout__pc = false ) ;                       
         insert acc ;
         
        acc.SMS_optout__pc = true ;
        
        Test.startTest();
        update acc ;
        Test.stopTest();
    }
}