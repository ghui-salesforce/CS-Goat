public class ProgramTaskDurationMinsHandler {
    public static void UpsertDurationMins(List<Program_Task__c> pTasks){
        //List<Program_Task__c> pTaskSend = new List<Program_Task__c>(); //List to submit DML
        //List<Program_Task__c> pTasks = new List<Program_Task__c>(pTasksInput); //we need to instantiate the list object
        
        //query the training task associated with this program > set a value in the program field > add to DML List
        for(Program_Task__c pTask: pTasks){ 
        	Training_Task__c tTask = [SELECT id,Name,Duration_Mins__c FROM Training_Task__c WHERE id= :pTask.Training_Task__c];
            pTask.Duration_Mins__c = tTask.Duration_Mins__c;
            //pTaskSend.add(pTask);
        }
    }
}