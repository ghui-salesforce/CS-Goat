public with sharing class TrainingTaskAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<Training_Task_Assignment__c> getTTAs(String paID){
        try {
            return [SELECT id, Training_Task__r.Name , Status__c, Start_Date__c, Due_Date__c, Date_Completed__c, Actual_Mins__c
                    FROM Training_Task_Assignment__c
                    WHERE Program_Assignment__c =:paID
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Program_Assignment__c> getPAs(String contactId){
        System.debug('contactId = ' + contactId );
        try {
            return [SELECT id, Program__r.Name, Contact__c, Status__c, Start_Date__c, End_Date__c, Ahead_Behind__c
                    FROM Program_Assignment__c
                    WHERE Contact__c =:contactId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class TTADraftValues {
        // these variables need to be named the same as the JS variables passed into JSON deserializer, otherwise they would store null values
        public Id Id;
        public String Status;
        public Date Date_Completed;
        public Decimal Actual_Mins;
    }

    // bug: clicking an edit and leaving it null
    @AuraEnabled
    public static string updateTTAs(Object data) {
        System.debug('data = ' + data);
        // create a list of ttas that will be updated through DML
        List<Training_Task_Assignment__c> ttaUpdate = new List<Training_Task_Assignment__c>();
        // create a list of TTADraftValues that contains the TimeTakenInMinutes and Id
        List<TTADraftValues> ttaData = (List<TTADraftValues>) JSON.deserialize(
            JSON.serialize(data),
            List<TTADraftValues>.class
        );
        System.debug('ttaData = ' + ttaData);
        // create a map to quickly access tta record ID and it's new values
        Map<Id,TTADraftValues> ttaNewMap = new Map<Id,TTADraftValues>();
        // create a set to ensure key uniqueness and pass into SOQL
        Set<Id> ttaSet = new Set<Id>();
        for (TTADraftValues ttaDraftValue: ttaData){
            ttaNewMap.put(ttaDraftValue.Id, ttaDraftValue);
            ttaSet.add(ttaDraftValue.Id);
        }
        // query necessary fields and objects
        Map<ID,Training_Task_Assignment__c> ttaOldMap = new Map<ID,Training_Task_Assignment__c>(
            [SELECT Id, Status__c, Date_Completed__c, Actual_Mins__c
                FROM Training_Task_Assignment__c
                WHERE Id IN :ttaSet]
        );
        // replace old values with new values
        for (Id ttaID: ttaSet){
            Training_Task_Assignment__c tta = ttaOldMap.get(ttaID);
            // replace the value 
            // 1. if the new value != null
            // 2. if both new and old value are null (to handle the case where you click edit, but leave it as null)
            if (ttaNewMap.get(ttaID)?.Status != null ||
                (ttaNewMap.get(ttaID)?.Status == null && tta.Status__c == null)) { 
                tta.Status__c = ttaNewMap.get(ttaID)?.Status;
            }
            if (ttaNewMap.get(ttaID)?.Date_Completed != null  || 
                (ttaNewMap.get(ttaID)?.Date_Completed == null && tta.Date_Completed__c == null)) {
                tta.Date_Completed__c = ttaNewMap.get(ttaID)?.Date_Completed;
            }
            if (ttaNewMap.get(ttaID)?.Actual_Mins != null || 
                (ttaNewMap.get(ttaID)?.Actual_Mins == null && tta.Actual_Mins__c == null)) {
                tta.Actual_Mins__c = ttaNewMap.get(ttaID)?.Actual_Mins;

            }            
            ttaUpdate.add(tta);
        }
        try {
            if (ttaUpdate.size() > 0) update ttaUpdate;
            return 'Success: training task assignments updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
}
