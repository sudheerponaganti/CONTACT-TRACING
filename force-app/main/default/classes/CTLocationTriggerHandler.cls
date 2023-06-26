public with sharing class CTLocationTriggerHandler {
    
    
    public static void beforeInsert(List<Location__c> newRecords){
        for(Location__c location : newRecords){
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        for(Location__c location : newRecords){
            if(location.Status__c != oldRecordsMap.get(location.Id).Status__c){
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> newRecords, Map<Id, Location__c> oldRecordsMap){
        Set<Id> redStatusLocationIds = new Set<Id>();
        for(Location__c location : newRecords){
            if(location.Status__c == 'Red' && oldRecordsMap.get(location.Id).Status__c != 'Red'){
                redStatusLocationIds.add(location.Id);
            }
        }
      Set<Id> personIds = new Set<Id>();
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(redStatusLocationIds);
        for(Location_Tracing__c trace : locationTraces){
            personIds.add(trace.Person__c);
        }

        List<Person__c> personsToUpdate = new List<Person__c>();
        for(Id pid : personIds){
            personsToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
        }
        if(personsToUpdate.size() > 0){
            update personsToUpdate;
        }
        
    }
}