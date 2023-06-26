public with sharing class CTPersonController {

   /**
   * Get token for the givemn mobile number
   * @param mobileNo
   * @return String
   */
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);

        //get the string value of hash blob
        return EncodingUtil.base64Encode(hash);
        
    }

      /**
    * Get 100 contacts with recent health status change
    * @return List<Person__c>
    */
    public static List<Person__c> getRecentHealthChanges(){
        List<Person__c> people = [SELECT Id,Name,Health_Status__c,Status_Update_Date__c,Mobile__c,Token__c
                                     FROM Person__c 
                                     WITH SECURITY_ENFORCED 
                                     ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100 ];
                     
        return people;
    }
   
    /**
    * Search a person by name, token or mobile
    @param searchTerm
    * @return List<Person__c>
    */
    public static List<Person__c> searchPeople(String searchTerm){
         searchTerm = searchTerm +'%';
        List<Person__c> personList = [SELECT Id, Name,Health_Status__c,Status_Update_Date__c,Mobile__c,Token__c
                                        FROM Person__c 
                                        WHERE Name LIKE :searchTerm
                                            OR Mobile__c LIKE :searchTerm 
                                            OR Token__c LIKE :searchTerm
                                        WITH SECURITY_ENFORCED  
                                        ORDER BY Status_Update_Date__c DESC NULLS LAST];
        return personList;
    }

   /**
   * search person by id
   * @param personId
   * @return Person__c
   */  
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id,Name,Health_Status__c,Status_Update_Date__c,Mobile__c,Token__c
                                     FROM Person__c WHERE Id =:personId
                                     WITH SECURITY_ENFORCED ];
         if(people != null && people.size()>0){
               return people[0];
           }
        return null;
    }

    
   /**
   * Get Count of People in each health status
   * @return Map<String,Integer
   */  
    public static Map<String,Integer> getHealthStatusCount(){
        Map<String,Integer> healthCountMap = new Map<String,Integer>();
        AggregateResult[] groupedResult = [SELECT Health_Status__c, COUNT(Id) total
                                           FROM Person__c 
                                           WITH SECURITY_ENFORCED 
                                           GROUP BY Health_Status__c];
        for(AggregateResult result : groupedResult){
            String healthStatus = String.valueOf(result.get('Health_Status__c'));
            Integer count = Integer.valueOf(result.get('total'));
            healthCountMap.put(healthStatus,count);
        }

        return healthCountMap;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds,Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Contact_Type__c, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN : personIds OR Person_2__c IN : personIds)
                                                    AND Contact_Type__c = 'Cohabitant'
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    WITH SECURITY_ENFORCED];
        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
              if(!alreadyProcessed.contains(pt.Person_1__c)){
                cohabitants.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
              }
              if(!alreadyProcessed.contains(pt.Person_2__c)){
                cohabitants.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
              }
            }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<People_Tracing__c> peopleTraces = [SELECT Id, Contact_Type__c, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN : personIds OR Person_2__c IN : personIds)
                                                    AND Contact_Type__c = 'Neighbour'
                                                    AND (Person_1__r.Health_Status__c ='Green' OR Person_2__r.Health_Status__c = 'Green')
                                                    WITH SECURITY_ENFORCED];
        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
              if(!alreadyProcessed.contains(pt.Person_1__c)){
                neighbours.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
              }
              if(!alreadyProcessed.contains(pt.Person_2__c)){
                neighbours.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
              }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds,Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Contact_Type__c, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN : personIds OR Person_2__c IN : personIds)
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS : 10
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    WITH SECURITY_ENFORCED];
        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
              if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
              }
              if(!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
              }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds,Set<Id> alreadyProcessed){
        List<String> healthStatuses = new List<String>{'Green','Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Contact_Type__c, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN : primaryContactIds OR Person_2__c IN : primaryContactIds)
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS : 10
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)
                                                    WITH SECURITY_ENFORCED];
        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
              if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
              }
              if(!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
              }
        }
        return secondaryContacts;
    }

    public static Map<String,Integer> getPersonHealthStatusCount(){
      Map<String,Integer> healthCountMap = new Map<String,Integer>();
      AggregateResult [] healthCountResults = [SELECT  Count(Id) personCount ,Health_Status__c 
                                    FROM Person__c
                                    WITH SECURITY_ENFORCED
                                    GROUP BY Health_Status__c];

      if(healthCountResults != null && healthCountResults.size() >0){
        for(AggregateResult result : healthCountResults){
          String status = (String) result.get('Health_Status__c');
          Integer count = (Integer) result.get('personCount');
          healthCountMap.put(status,count);
        }
        return healthCountMap;
      }
     return null;
    }
  }