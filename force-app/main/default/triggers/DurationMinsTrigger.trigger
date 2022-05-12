trigger DurationMinsTrigger on Program_Task__c (before insert, before update) {
	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ProgramTaskDurationMinsHandler.UpsertDurationMins(Trigger.New);
    }

}