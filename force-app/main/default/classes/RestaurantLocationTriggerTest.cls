@isTest
private class RestaurantLocationTriggerTest {
    
    @testSetup static void setup(){
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<10;i++){
            Account acc = new Account(name = 'Test'+i);
            accList.add(acc);
        }
        insert accList;
        List<Restaurant_Location__c> locationList = new List<Restaurant_Location__c>();
        for(Integer i=0; i<100;i++){
           if(i<10){
            locationList.add(returnLocationObject(accList[0].Id,i,System.today()));
           }else if(i>=10 && i<50){
            locationList.add(returnLocationObject(accList[1].id,i,System.today().addDays(30)));
           }else{
            locationList.add(returnLocationObject(accList[2].id,i,System.today().addDays(60)));
           }
        }
        insert locationList;
    }
   
    @isTest
    static void testLiveDateSet() {
        Restaurant_Location__c testLocation = new Restaurant_Location__c();
        testLocation.Name = 'Test Location 1';
        testLocation.Region__c = 'Other';
        testLocation.Status__c = 'Active';
        insert testLocation;
        test.startTest();
        //System.assertEquals(testLocation.Last_Visit_Date__c, Date.Today(), 'Last_Visit_Date__c should be set to Today');
        test.stopTest();
    }

    @isTest
    static void testAfterInsertScenario(){
        Account acc = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
        
        Restaurant_Location__c testLocation = new Restaurant_Location__c();
        testLocation.Name = 'Test Location Test Method';
        testLocation.Region__c = 'Other';
        testLocation.Status__c = 'Active';
        testLocation.Account__c = acc.Id;
        testLocation.Last_Visit_Date__c = acc.Last_Location_Visit_Date__c.addDays(45);
         insert testLocation;
         Account accountObj = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
         System.assertEquals(accountObj.Last_Location_Visit_Date__c,acc.Last_Location_Visit_Date__c.addDays(45),'Last_Visit_Date__c should be added  to 45 days from previous day');

    }

    @isTest
    static void testAfterUpdateScenario(){
        Account acc = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
        
        Restaurant_Location__c testLocation = [SELECT Id,Last_Visit_Date__c FROM Restaurant_Location__c WHERE Account__c =:acc.Id limit 1];
        Restaurant_Location__c testLocationUpdate = new Restaurant_Location__c();
        testLocationUpdate.Id = testLocation.Id;
        testLocation.Last_Visit_Date__c = acc.Last_Location_Visit_Date__c.addDays(45);
         update testLocation;
         Account accountObj = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
         System.assertEquals(accountObj.Last_Location_Visit_Date__c,acc.Last_Location_Visit_Date__c.addDays(45),'Last_Visit_Date__c should be added  to 45 days from previous day');
    }

    @isTest
    static void testAfterDeleteScenario(){
        Account acc = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
        Date nullDate;
        Delete [Select Id from Restaurant_Location__c where account__c =:acc.Id];
        Account accountObj = [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE name ='Test1'];
        System.assertEquals(accountObj.Last_Location_Visit_Date__c,nullDate,'Last_Visit_Date__c should be blanked out as all active locations are deleted');
    }


   


   public  static Restaurant_Location__c returnLocationObject(Id accId, Integer value,Date lastLiveDate){   
    Restaurant_Location__c testLocation = new Restaurant_Location__c();
        testLocation.Name = 'Test Location'+value;
        testLocation.Region__c = 'Other';
        testLocation.Status__c = 'Active';
        testLocation.Account__c = accId;
        testLocation.Last_Visit_Date__c = lastLiveDate;
        return testLocation;
    }
}