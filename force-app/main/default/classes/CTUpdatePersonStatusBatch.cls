public with sharing class CTUpdatePersonStatusBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> healthStatuses = new List<String>{'Yelow','Orange','Red'};
        Date today = Date.today();
        Date fourteenDaysAgo = today - 14;
        String query = 'SELECT Id, Health_Status__c FROM Person__c WHERE Health_Status__c IN : healthStatuses AND Status_Update_Date__c = : fourteenDaysAgo';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Person__c> scope){
        for(Person__c person : scope){
            person.Health_Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        // System.debug('the batch job finished');
    }
}