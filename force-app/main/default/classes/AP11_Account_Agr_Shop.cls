public with sharing class AP11_Account_Agr_Shop {

    public static void getAccount_Agr_Shop (Set<Id> setPersonContactId) {
        
       	 Map<Account, List<Order>> orderToProces = new Map<Account, List<Order>>();
       	 Map<Account, boolean> accountOmnichanel = new Map<Account, boolean>();
         Map<Account, String> accountLastShop = new Map<Account, String>();
        Map<account,string> accountfavoriteCategory = new Map<account,string>();
        Map<Account,Integer> listOfAccount = new Map<Account,Integer>();
        
 
        
        
         String queryStringOmnichannel = 'Select ID, Account.PersonContactId,' +
                            ' Shop__c,Shop__r.name,Account.Omnichanel_customer__pc,' +
                            ' Account.RecordTypeId, '+ 
             				'(Select Id, Product2Id, Product2.Category_1__c From OrderItems)'+
                            ' From Order Where ' +
                            ' Account.PersonContactId In : setPersonContactId ' + 
                            ' Order By Account.PersonContactId, EffectiveDate DESC';
        
        List<Order> listOrder;
        for (order ord : Database.Query(queryStringOmnichannel)){
                listOrder = orderToProces.get(ord.account);
            	if(listOrder==null){
                 	listOrder = new List<Order>();  
                }
				listOrder.add(ord);
            	orderToProces.put(ord.account,listOrder);         	
        }
        
        
        if(orderToProces.size() > 0){
            for(Account acc : orderToProces.keySet()){
                Map<string,Integer> categorie1Items = new Map<string,Integer>();   
                list <String> shopsName = new list <String>();
                 
                for (Order myOrder : OrderToProces.get(acc)) {

                	String shopName =  myOrder.shop__r.name;
                    shopsName.add(shopName);
                     for (OrderItem od : myOrder.OrderItems) {
                         
                        if (!Categorie1Items.containsKey(od.Product2.Category_1__c ) && od.Product2Id != null && 
                           	od.Product2.Category_1__c != null) {
                            Categorie1Items.put(od.Product2.Category_1__c, 1);
                        }
                        
                       	else if (od.Product2Id != null && od.Product2.Category_1__c != null){
                            Integer i = Categorie1Items.get(od.Product2.Category_1__c);                           
                            Categorie1Items.put(od.Product2.Category_1__c, i+1);
                            
                        }

                    	}
                    System.debug('categories '+ Categorie1Items ); 

                 }              

                Integer numberOfOccurence = 0;
              	acc.Favorite_categorie_1__pc = null;
                
                for(String key : Categorie1Items.keySet())
                    {                
                        if(Categorie1Items.get(key) > numberOfOccurence) 
                        {
                            acc.Favorite_categorie_1__pc = key;
                            accountfavoriteCategory.put(acc,key);
                            System.debug('accountfavoriteCategory '+ accountfavoriteCategory );
                            numberOfOccurence = Categorie1Items.get(key);
                        }
                        
                    }

            //LastShope    
               String LastShop = shopsName.get(0);
               accountLastShop.put(acc,LastShop);
             //Omnichannel   
                boolean isOmniChannel = false;
                for (integer i=0; i<shopsName.size() -1 ; i++){            	 
                    
                    if ((InternetChannel(shopsName.get(i))&&!(InternetChannel(shopsName.get(i+1))))||
                         (!(InternetChannel(shopsName.get(i)))&&(InternetChannel(shopsName.get(i+1))))
                        ){
                   		 isOmniChannel = true;
                	}
              	}

                    accountOmnichanel.put(acc,isOmniChannel);
                	listOfAccount.put(acc, 1);
			}
		}
        
         List<Account> listAccountToUpdate = new List<Account>();
            for(Account aAccount : listOfAccount.keySet()){                
                if(!listAccountToUpdate.contains(aAccount)){
                    listAccountToUpdate.add(aAccount);
                }
            }
        
    	  
        for(Account Acc : listAccountToUpdate){
             if(accountOmnichanel.get(Acc) != null ){
                Acc.Omnichanel_customer__pc= accountOmnichanel.get(Acc);
               }
             if(accountLastShop.get(Acc) != null ){
                Acc.Boutique_de_dernier_achat__pc = accountLastShop.get(Acc);
               }
           	if(!listAccountToUpdate.contains(Acc) &&  accountfavoriteCategory.get(Acc) != null ){
                Acc.Favorite_categorie_1__pc  = accountfavoriteCategory.get(Acc);
               }
 	      	 } 
       Update listAccountToUpdate;
        
	}
    
    public static boolean InternetChannel (String ShopName){
        String internetchannel = Label.LABS_PerconAcc_Internet;
        if(ShopName.containsIgnoreCase(internetchannel)){
            return true;
        }else {
            return false;
        }       
    }
    
}