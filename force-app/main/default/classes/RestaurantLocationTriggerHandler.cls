public with sharing class RestaurantLocationTriggerHandler extends TriggerHandler {

    public RestaurantLocationTriggerHandler() {
      
    }
    
    public override void beforeInsert() {
      for(Restaurant_Location__c location: (List<Restaurant_Location__c>)trigger.new)
        {
            if(location.Last_Visit_Date__c == null){
                location.Last_Visit_Date__c = Date.today();
            }
        }
    }
  // To handle the logic on insert of restaurant loactions
    public override void afterInsert() {
      Map<Id,Date> accountMap = new Map<Id,Date>();
      List<Account> updateAccountList = new List<Account>();
      for(Restaurant_Location__c location: (List<Restaurant_Location__c>)trigger.new){
            if(location.Account__c!=null && location.Status__c=='Active' && location.Last_Visit_Date__c!=null){
              // To handle the logic of multiple location records against the same parent account
              if(accountMap.containsKey(location.Account__c)){
                Date currentDateValue = accountMap.get(location.Account__c);
                if(currentDateValue<location.Last_Visit_Date__c){
                  accountMap.put(location.Account__c,location.Last_Visit_Date__c);
                }
              }else{
                accountMap.put(location.Account__c,location.Last_Visit_Date__c);
              }
            }
        }
        // Query on all the accounts and update the last Location Visit date 
      for(Account acc : [SELECT Id,Last_Location_Visit_Date__c FROM Account WHERE Id in:accountMap.keyset() WITH USER_MODE]){
        if(acc.Last_Location_Visit_Date__c!=null ){
           // Check whether new last location visit date needs to be updated
           if(accountMap.get(acc.Id)!=null && accountMap.get(acc.Id)>acc.Last_Location_Visit_Date__c){
            Account objAccount = new Account(Id=acc.Id);
            objAccount.Last_Location_Visit_Date__c = accountMap.get(acc.Id);
            updateAccountList.add(objAccount);
           }
        }else{
          Account objAccount = new Account(Id=acc.Id);
          objAccount.Last_Location_Visit_Date__c = accountMap.get(acc.Id);
          updateAccountList.add(objAccount);
        }
      }
      if(updateAccountList.size()>0){
         update updateAccountList;
      }
    }

    public override void afterUpdate() {
      Map<Id,Date> accountMap = new Map<Id,Date>();
      Set<ID> accIds = new Set<Id>();
      List<Account> updateAccountList = new List<Account>();
      for(Restaurant_Location__c location: (List<Restaurant_Location__c>)trigger.new){
        // Get the older version of object
        Restaurant_Location__c oldLocationObj = (Restaurant_Location__c)trigger.oldMap.get(location.Id);
         // check if status or last visit date is getting changed  
         if(location.Account__c!=null && 
                (location.Status__c!= oldLocationObj.Status__c && location.Status__c == 'Active' ||
                (location.Status__c!= oldLocationObj.Status__c && location.Status__c != 'Active' && oldLocationObj.Status__c=='Active') || 
                 location.Last_Visit_Date__c!=oldLocationObj.Last_Visit_Date__c)
              ){
              accIds.add(location.Account__c);
            }
            //check whether parent account is getting changed
            if(location.Account__c!=oldLocationObj.Account__c){
               if(location.Account__c!=null){
                accIds.add(location.Account__c);
               }
               if(oldLocationObj.Account__c!=null){
                accIds.add(oldLocationObj.Account__c);
               }
            }
        }
        //Aggregrate query to get the latest last visit date on all the child locations grouped by parent account.
        if(accIds.size()>0){
          for(AggregateResult result : [SELECT Account__c ,MAX(Last_Visit_Date__c) lastVistedDate FROM Restaurant_Location__c WHERE Account__c in:accIds and Status__c = 'Active' WITH USER_MODE group by Account__c ]){
            Id accId = (Id) result.get('Account__c');
            Account acc = new Account(Id=accId);
            acc.Last_Location_Visit_Date__c = (Date) result.get('lastVistedDate');
            updateAccountList.add(acc);
            if(accIds.contains(accid)){
              accIds.remove(accId);
            }
          }
        }
        if(accIds.size()>0){
          Date nullDate;
          for(Id accId : accIds){
            Account acc = new Account(Id=accId);
            acc.Last_Location_Visit_Date__c = nullDate;
            updateAccountList.add(acc);
          }
        }
        if(updateAccountList.size()>0){
          update updateAccountList;
        }
    }

    public override void afterDelete(){
      Set<ID> accIds = new Set<Id>();
      List<Account> updateAccountList = new List<Account>();
      for(Restaurant_Location__c location: (List<Restaurant_Location__c>)trigger.old){
        if(location.status__c == 'Active'){
          accIds.add(location.Account__c);
        }
      }
      if(accIds.size()>0){
        for(AggregateResult result : [SELECT Account__c ,MAX(Last_Visit_Date__c) lastVistedDate FROM Restaurant_Location__c WHERE Account__c in:accIds and Status__c = 'Active' WITH USER_MODE group by Account__c ]){
          Id accId = (Id) result.get('Account__c');
          Account acc = new Account(Id=accId);
          acc.Last_Location_Visit_Date__c = (Date) result.get('lastVistedDate');
          updateAccountList.add(acc);
          if(accIds.contains(acc.id)){
            accIds.remove(accId);
          }
        }
      }
      if(accIds.size()>0){
        Date nullDate;
          for(Id accId : accIds){
            Account acc = new Account(Id=accId);
            acc.Last_Location_Visit_Date__c = nullDate;
            updateAccountList.add(acc);
          }
      }
      if(updateAccountList.size()>0){
        update updateAccountList;
      }
    }

    

   
  
  }