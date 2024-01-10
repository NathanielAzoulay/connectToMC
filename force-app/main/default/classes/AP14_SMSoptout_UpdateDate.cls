public class AP14_SMSoptout_UpdateDate {

   
    public static void UpdateUnsubDate  (List <Account> accounts) {
        Datetime current = System.now();
        Integer offset = UserInfo.getTimezone().getOffset(current);
        for (Account aAccount: accounts) {
           		aAccount.UnsubDate__pc = current.addSeconds(offset/1000);
        }
    }
}