public with sharing class CTLocationController {

    /**
     * get 100 location with recent status change
     * @return List<Location__c>
     */
   public static List<Location__c> getRecentStatusChanges(){
      List<Location__c> locationData = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                        FROM Location__c 
                                        WITH SECURITY_ENFORCED
                                        ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];

      return locationData;
   }

    /**
     * search location by name, address, pincode
     * @param searchTerm
     * @return List<Location__c>
     */
   public static List<Location__c> searchLocations(String searchTerm){
     searchTerm += '%';
     List<Location__c> locationData = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                        FROM Location__c
                                        WHERE Name LIKE :searchTerm
                                            OR Pincode__c LIKE :searchTerm
                                            OR Address__c LIKE :searchTerm
                                        WITH SECURITY_ENFORCED
                                        ORDER BY Status_Update_Date__c DESC NULLS LAST];
     return locationData;
   }

   /**
     * search location by id
     * @param locationId
     * @return Location__c
     */
   public static Location__c getLocationById(String locationId){
      List<Location__c> locationData = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                        FROM Location__c
                                        WHERE Id = :locationId
                                        WITH SECURITY_ENFORCED];

      if(locationData != null && locationData.size()>0){
        return locationData[0];
        }
      return null;
   }

    /**
     * Get count of locations for each status
     * @return Map<String,Integer>
     */
    public static Map<String,Integer> getStatusCount(){
      Map<String,Integer> healthCountMap = new Map<String,Integer>();
      AggregateResult[] groupedResult = [SELECT Status__c, COUNT(Id) total
                                         FROM Location__c
                                         WITH SECURITY_ENFORCED
                                         GROUP BY Status__c];

     for(AggregateResult result :groupedResult){
      String status = String.valueOf(result.get('Status__c'));
      Integer count = Integer.valueOf(result.get('total'));
      healthCountMap.put(status,count);
     }
      return healthCountMap;
   }

   public static void updateRedScore(Set<Id> locationIds){
    List<Location__c> locationsToUpdate = new List<Location__c>();
    AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c 
                                                                                  WHERE Person__r.Health_Status__c = 'Red'
                                                                                  AND Visit_Date__c = LAST_N_DAYS:10
                                                                                  AND Location__c IN : locationIds
                                                                                  WITH SECURITY_ENFORCED
                                                                                  GROUP BY Location__c];
      for(AggregateResult ar : redPeoplePerLocation){
        String locationId = (String) ar.get('Location__c');
        Integer redScore  = (Integer) ar.get('total');
        String status = getStatus(redScore);
        locationsToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore , Status__c = status, Status_Update_Date__c = Date.today()));
      }
      if(locationsToUpdate.size()>0 && Schema.sObjectType.Location__c.isUpdateable()){
        update locationsToUpdate;
      }
      
   }


   public Static String getStatus(Integer redScore){
    if(redScore == 0){
      return 'Green';
    }else if(redScore <= 5){
      return 'Yellow';
    }else if(redScore <= 10){
      return 'Orange';
    }else{
      return 'Red';
    }
   }

   public static Map<String,Integer> getHealthStatusCount(){
    Map<String,Integer> healthCountMap = new Map<String,Integer>();
    AggregateResult [] healthCountResults = [SELECT COUNT(Id) locationCount, Status__c
                                             FROM Location__c
                                             WITH SECURITY_ENFORCED 
                                             GROUP BY Status__c];

    if(healthCountResults != null && healthCountResults.size() >0){
      for(AggregateResult result : healthCountResults){
        String status = (String) result.get('Status__c');
        Integer count = (Integer) result.get('locationCount');
        healthCountMap.put(status,count);
      }
      return healthCountMap;
    }
   return null;
  }


}