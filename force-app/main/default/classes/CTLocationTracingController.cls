public with sharing class CTLocationTracingController {
    
    /**
     * get last 30 days visitors
     * @param locationId
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getVisitors(String locationId){
        List<Location_Tracing__c> locationTracingData = [SELECT Id,Visit_Date__c, Person__c, Location__c,Person__r.Token__c,Person__r.Health_Status__c
                                                           FROM Location_Tracing__c
                                                           WHERE Location__c = :locationId
                                                           WITH SECURITY_ENFORCED
                                                           ORDER BY Visit_Date__c DESC];
     return locationTracingData;                                                   
    }

    /**
     * get all locationids for visitors
     * @param personIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){

        List<Location_Tracing__c> locationTracingData = [SELECT Id, Person__c, Location__c
                                                           FROM Location_Tracing__c 
                                                           WHERE Person__c IN :personIds
                                                             AND  Visit_Date__c = LAST_N_DAYS:10
                                                           WITH SECURITY_ENFORCED];

     return locationTracingData;
    }
    
    /**
     * get all vistor ids for locations
     * @param locationIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){

        List<Location_Tracing__c> locationTracingData = [SELECT Id, Name, Visit_Date__c, Person__c, Location__c,Person__r.Health_Status__c
                                                           FROM Location_Tracing__c
                                                           WHERE Location__c IN :locationIds
                                                              AND  Person__r.Health_Status__c = 'Green'
                                                              AND  Visit_Date__c = LAST_N_DAYS:10
                                                           WITH SECURITY_ENFORCED];
     return locationTracingData;
    } 

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        // store unique location ids
        set<Id>locationIds = new set<Id>();
        // store unique person ids
        set<Id>personIds = new set<Id>();

        for(Location_Tracing__c trace : newLocationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);     
        } 


        // map of location id , set of person ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<id>>();
        List<Location_Tracing__c> existingRecords = [SELECT Id,Person__c, Location__c
                                                           FROM Location_Tracing__c
                                                           WHERE Location__c IN : locationIds
                                                                 OR Person__c IN : personIds
                                                           WITH SECURITY_ENFORCED]; 
       // list of duplicate records
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
                                                           
        if(existingRecords !=null && existingRecords.size()>0){
            for(Location_Tracing__c trace : existingRecords){
                  if(!mapOfExistingRecords.containsKey(trace.location__c)){
                    mapOfExistingRecords.put(trace.location__c, new Set<Id>());
                  }

                  //add person ids to map set
                  mapOfExistingRecords.get(trace.location__c).add(trace.Person__c);

                }
                  //loop over new location tracing records
                  for (Location_Tracing__c trace : newLocationTraces ) {
                    // first check for location id
                    // if item found in map,then check for person in set
                    if(mapOfExistingRecords.containsKey(trace.Location__c) && mapOfExistingRecords.get(trace.Location__c).contains(trace.person__c)){
                        duplicates.add(trace);
                    }
            
                  }
        }


        return duplicates;
                                                      
    }
}