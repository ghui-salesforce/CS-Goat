trigger CreateDueDateTrigger on Program_Assignment__c (before insert) {
	if (Trigger.isBefore && Trigger.isInsert) {
        ProgramAssignmentHandler.CreateDueDate(Trigger.New);
    }
}