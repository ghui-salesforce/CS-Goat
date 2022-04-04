public class TrainingTaskAssignmentHandler {
    public static void InsertProgramCompletedMinsAndTasks(List<Training_Task_Assignment__c> ttas){
        List<Program_Assignment__c> paSend = new List<Program_Assignment__c>();
        
        
        for(Training_Task_Assignment__c tta: ttas){     
            System.debug('tta.status = '+ tta.Status__c);
            if (tta.Program_Assignment__c != null){ //check if it's a stretch tta, (whether the task is related to a program assignment)
                System.debug('Working with: tta.name = ' + tta.Name + ' Program_Assignment__c = ' + tta.Program_Assignment__c);
                //case: status changes to complete, but loe minutes has not been rewarded to the program yet
                if (tta.Status__c == 'Complete'){//case: status changes to complete, but loe minutes has not been rewarded to the program yet
                    List<Program_Assignment__c> pas = [SELECT id,name,Completed_Mins__c,Number_of_Completed_Tasks__c
                                                       FROM Program_Assignment__c
                                                       WHERE id=:tta.Program_Assignment__c];
                    System.debug('List of PAs = '+pas);
                    for(Program_Assignment__c pa:pas){
                        System.debug('This TA\'s status is: ' + tta.Status__c);
                        if(pa.Completed_Mins__c != null){
                            pa.Completed_Mins__c += tta.Duration_Mins__c;
                            pa.Number_of_Completed_Tasks__c += 1;
                            paSend.add(pa);
                            System.debug('Added PA updates to DML');
                        }
                    }
                }
            }      
        }
        if (paSend.size() > 0){
            update paSend;
            System.debug('Sent DML');
        }
    }
    
    // update fields on program assignment related to the TTA
    public static void UpdateProgramCompletedMinsAndTasks(List<Training_Task_Assignment__c> ttas){
        List<Program_Assignment__c> paSend = new List<Program_Assignment__c>();
        for(Training_Task_Assignment__c tta: ttas){ 
            Training_Task_Assignment__c oldtta = (Training_Task_Assignment__c)Trigger.oldMap.get(tta.Id);            
            if (tta.Program_Assignment__c != null){ //check if it's a stretch tta, (whether the task is related to a program assignment)
                //case: status changes to complete, but loe minutes has not been rewarded to the program yet
                if (oldtta.Status__c != 'Complete' && tta.Status__c == 'Complete'){//case: status changes to complete, but loe minutes has not been rewarded to the program yet
                    List<Program_Assignment__c> pas = [SELECT id,name,Completed_Mins__c,Contact__c,Number_of_Completed_Tasks__c 
                                                FROM Program_Assignment__c 
                                                WHERE Contact__c = :tta.Contact__c];
                    for(Program_Assignment__c pa: pas){
                        if (pa.Completed_Mins__c == null) pa.Completed_Mins__c = 0; //if completed mins is null, then set to 0 so we can perform addition later
                        pa.Completed_Mins__c += tta.Duration_Mins__c; //update pa total completed mins
                        pa.Number_of_Completed_Tasks__c += 1; //increment pa total completed tasks
                        paSend.add(pa);
                    }
                }
                //case: status was originally complete and loe minutes were rewarded, but was changed to NOT complete
                else if(oldtta.Status__c == 'Complete' && tta.Status__c != 'Complete'){
                    List<Program_Assignment__c> pas = [SELECT id,name,Completed_Mins__c,Contact__c,Number_of_Completed_Tasks__c 
                                                FROM Program_Assignment__c 
                                                WHERE Contact__c = :tta.Contact__c];
                    for(Program_Assignment__c pa: pas){
                        if (pa.Completed_Mins__c == null) pa.Completed_Mins__c = 0; //if completed mins is null, then set to 0 so we can perform addition later
                        pa.Completed_Mins__c -= tta.Duration_Mins__c; 
                        pa.Number_of_Completed_Tasks__c -= 1; //decrement pa total completed tasks
                        paSend.add(pa);
                    }                    

                }
            }      
        }
        if (paSend.size() > 0){
            update paSend;
        }
    }
    
    public static void DeleteProgramCompletedMinsAndTasks(List<Training_Task_Assignment__c> ttas){
        List<Program_Assignment__c> paSend = new List<Program_Assignment__c>();
        for(Training_Task_Assignment__c tta: ttas){ 
            if (tta.Program_Assignment__c != null){ //check if it's a stretch tta, (whether the task is related to a program assignment)
                //case: if the old status was complete, deduct minutes from the pa LOE total
                if(tta.Status__c == 'Complete'){
                    List<Program_Assignment__c> pas = [SELECT id,name,Completed_Mins__c,Contact__c,Number_of_Completed_Tasks__c 
                                                FROM Program_Assignment__c 
                                                WHERE Contact__c = :tta.Contact__c];
                    for(Program_Assignment__c pa: pas){
                        if (pa.Completed_Mins__c == null) pa.Completed_Mins__c = 0; //if completed mins is null, then set to 0 so we can perform addition later
                        pa.Completed_Mins__c -= tta.Duration_Mins__c; 
                        pa.Number_of_Completed_Tasks__c -= 1;
                        paSend.add(pa);
                    }

                }
            }
        }
        if (paSend.size() > 0){
            update paSend;
        }
    }
    
    
}