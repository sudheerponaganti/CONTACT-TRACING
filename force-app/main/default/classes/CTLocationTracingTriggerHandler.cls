public with sharing class CTLocationTracingTriggerHandler {
    

    public static void beforeInsert(List<Location_Tracing__c> newLocationTraces){
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newLocationTraces);

        if(duplicates != null && duplicates.size()>0){
            for(Location_Tracing__c trace : newLocationTraces){
                trace.addError('Duplicate Record Found. Location : '+ trace.Location__c+' Perosn Id: '+ trace.Person__c);
            }
        }

    }
}