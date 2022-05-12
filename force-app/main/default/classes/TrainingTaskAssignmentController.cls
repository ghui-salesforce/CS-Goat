public with sharing class TrainingTaskAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<Training_Task_Assignment__c> getTTAs(String paID){
        try {
            System.debug(paID);
            return [SELECT id, Training_Task__r.Name , Status__c, Start_Date__c, Due_Date__c, Date_Completed__c, Actual_Mins__c
                    FROM Training_Task_Assignment__c
                    WHERE Program_Assignment__c =:paID
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}
