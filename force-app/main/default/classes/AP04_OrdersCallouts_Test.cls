@isTest(SeeAllData = true)
private class AP04_OrdersCallouts_Test {

    @isTest (SeeAllData = true)
    static void AP04_OrdersCallouts_Test () {
        Account anAccount = new Account(Firstname = 'Test', Lastname = 'Test', PersonEmail = 'test@ap04orderscallouts.com');
        insert anAccount;    
        
        ApexPages.currentPage().getParameters().put('AccId', anAccount.Id);
        AP04_OrdersCallouts aCtrl = new AP04_OrdersCallouts();
        
        aCtrl.init();
        
        System.assertNotEquals(0, aCtrl.getOrdersToDisplay().size());
        
        aCtrl.getOrdersToDisplay();
        aCtrl.getPaginateNav();
        aCtrl.previous();
        aCtrl.next();
        
        ApexPages.currentPage().getParameters().put('urlparmOrder', '100022702');
        aCtrl.initBis();
        
    }   
}