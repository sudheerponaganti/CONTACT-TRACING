public with sharing class CTPersonTriggerHandler {
    

    public static void beforeInsert(List<Person__c> newRecords){
        for(Person__c person : newRecords){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        for(Person__c person : newRecords){
          if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c){
            person.Status_Update_Date__c = Date.today();
          }
        }
    }

    public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
      Set<id> statusChange = new Set<Id>();
      Set<id> redStatus = new Set<Id>();
      for(Person__c person : newRecords){
        if(person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c){
          statusChange.add(person.Id);
        }
        if(person.Health_Status__c == 'Red' && oldRecordsMap.get(person.Id).Health_Status__c != 'Red'){
          redStatus.add(person.Id);
        }
      }

      Set<Id> alreadyProcessed = new Set<Id>();
      alreadyProcessed.addAll(redStatus);
      Set<id> orangeStatus = new Set<Id>();
      Set<id> yellowStatus = new Set<Id>();
      List<Person__c> personsToUpdate = new List<Person__c>();
     // add Cohibitants 
       orangeStatus.addAll(CTPersonController.getCohabitants(redStatus,alreadyProcessed));
       // add PrimaryContacts
       Set<Id> primarycontacts = CTPersonController.getPrimaryContacts(redStatus,alreadyProcessed);
       orangeStatus.addAll(primarycontacts);
       // add Neighbours 
       yellowStatus.addAll(CTPersonController.getNeighbours(redStatus,alreadyProcessed));

       //add SecondaryContacts
       yellowStatus.addAll(CTPersonController.getSecondaryContacts(primarycontacts,alreadyProcessed));


     for(Id pid : orangeStatus){
      personsToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Orange'));
     }
     for(Id pid : yellowStatus){
      personsToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
     }

     if(personsToUpdate.size()>0){
      update personsToUpdate;
     }

     List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);

     if(locationTraces.size()>0){
      Set<Id> locationIds = new Set<Id>();
      for(Location_Tracing__c trace :  locationTraces){
        locationIds.add(trace.Location__c);
      }
     CTLocationController.updateRedScore(locationIds);
     }

    
  }
}