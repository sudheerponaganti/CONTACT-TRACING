public with sharing class CTPeopleTracingTriggerHandler {
   

    public static void beforeInsert(List<People_Tracing__c> newRecords){
        List<People_Tracing__c> duplicates = CTPeopleTracingController.checkDuplicates(newRecords);

     if(duplicates != null && duplicates.size() >0){
        for(People_Tracing__c trace : duplicates){
                trace.addError('Duplicate Record Found. Person 1: '+trace.Person_1__c + ' Person 2: '+ trace.Person_2__c);
        }
      }

    }
}