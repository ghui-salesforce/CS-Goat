public class ProgramAssignmentHandler {
    // Create the due date for the 'program assignment' based off the 'program' duration.
    public static void CreateDueDate(List<Program_Assignment__c> pas){
        for(Program_Assignment__c pa: pas){
            if(pa.Start_Date__c != null){
                Program__c p = [SELECT id,Name,Program_Duration_Days__c
                                FROM Program__c
                                WHERE id= :pa.Program__c];
                pa.End_Date__c = pa.Start_Date__c.addDays((Integer)p.Program_Duration_Days__c);
            }
        }
    }
    
    // Create 'training task assignment' records that belong to the 'program' in 'program assignment'
    public static void CreateRelatedTrainingTasks(List<Program_Assignment__c> pas){
        List<Training_Task_Assignment__c> ttaSend = new List<Training_Task_Assignment__c>(); //dml list of 'tta' records to create
        Map<id,String> ttaMap = new Map<id,String>(); //create a map of all the employee's tta's TA
        
        //query for program task association, then assign tasks based off that
        for(Program_Assignment__c pa: pas){
            //find associated training tasks
            List<Program_Task__c> pts = [SELECT id,Program__c,Training_Task__c,Due_Day__c 
                                         FROM Program_Task__c 
                                         WHERE Program__c= :pa.Program__c];
            
            //populate the ttaMap of all the employee's tta's TA
            for(Training_Task_Assignment__c tta:[SELECT id,Training_Task__c,Contact__c,Status__c
                                                 FROM Training_Task_Assignment__c
                                                 WHERE Contact__c = :pa.Contact__c]){
                                                     ttaMap.put(tta.Training_Task__c, tta.Status__c);
                                                 }         
            //I want the duplicate training task assignments to have the same status as one that currently exists (this only sets it to 'Not Started' w/ incorrect PA)
            for(Program_Task__c pt: pts){ //create training task assignments
                //if the employee already has thae TA in the ttaMAP, then then copy that TA's status
                Training_Task_Assignment__c tta;
                if(ttaMap.containsKey(pt.Training_Task__c)){
                    tta = new Training_Task_Assignment__c(Contact__c=pa.Contact__c,
                                                          Start_Date__c=pa.Start_Date__c,
                                                          Due_Date__c=pa.Start_Date__c.addDays((Integer)pt.Due_Day__c-1), //accurate due date requires -1 offset, use validation rule for {due day >= 1}
                                                          Program_Assignment__c=pa.Id,
                                                          Status__c=ttaMap.get(pt.Training_Task__c),
                                                          Training_Task__c=pt.Training_Task__c); 
                }else{
                    tta = new Training_Task_Assignment__c(Contact__c=pa.Contact__c,
                                                          Start_Date__c=pa.Start_Date__c,
                                                          Due_Date__c=pa.Start_Date__c.addDays((Integer)pt.Due_Day__c-1), //accurate due date requires -1 offset, use validation rule for {due day >= 1}
                                                          Program_Assignment__c=pa.Id,
                                                          Status__c='Not Started',
                                                          Training_Task__c=pt.Training_Task__c);
                }
                
                ttaSend.add(tta);
                }
         }
        if (ttaSend.size() > 0){
            insert ttaSend;
        }
    }
    
    public static void UpdateStatus(List<Program_Assignment__c> pas){
        for(Program_Assignment__c pa: pas){
          	Program_Assignment__c oldpa = (Program_Assignment__c)Trigger.oldMap.get(pa.Id);
            if(pa.Number_of_Completed_Tasks__c == pa.Number_of_Assigned_Tasks__c && oldpa.Completion_Date__c == null){
                pa.Completion_Date__c=date.today();
            } else if(pa.Number_of_Completed_Tasks__c < pa.Number_of_Assigned_Tasks__c && oldpa.Completion_Date__c != null){
                pa.Completion_Date__c=null;
            }
        }
    }
}