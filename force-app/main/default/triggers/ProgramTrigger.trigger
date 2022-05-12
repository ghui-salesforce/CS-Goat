trigger ProgramTrigger on Program__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        ProgramHandler.UpdateProgramAssignmentDueDate(Trigger.New);
    }
}