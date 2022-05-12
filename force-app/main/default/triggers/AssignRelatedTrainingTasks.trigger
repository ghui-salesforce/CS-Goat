trigger AssignRelatedTrainingTasks on Program_Assignment__c (before update, before insert, after insert) {
    if (Trigger.isBefore && Trigger.isUpdate){
        ProgramAssignmentHandler.UpdateStatus(Trigger.New);
    }
    if (Trigger.isAfter && Trigger.isInsert){
        ProgramAssignmentHandler.CreateRelatedTrainingTasks(Trigger.New);
    }
    /**
    if (Trigger.isAfter && Trigger.isInsert){
        // add program assignment lookup on the TTA
        // calculate inserted TTA completed minutes + completion status onto the PA
        ProgramAssignmentHandler.CreateRelatedTrainingTasks(Trigger.New);
    }
**/
}