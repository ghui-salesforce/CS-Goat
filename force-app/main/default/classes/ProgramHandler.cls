public class ProgramHandler {
    public static void UpdateProgramAssignmentDueDate(List<Program__c> ps){
        List<Program_Assignment__c> paSend = new List<Program_Assignment__c>();
        for(Program__c p: ps){
            Program__c oldp = (Program__c)Trigger.oldMap.get(p.Id);
            if(oldp.Program_Duration_Days__c == null && p.Program_Duration_Days__c >= 1){ //case: if program duration in days was null, but changed to a valid input
                List<Program_Assignment__c> pas = [SELECT id,Program__c,End_Date__c
                                                   FROM Program_Assignment__c
                                                   WHERE Program__c = :p.Id];
                for(Program_Assignment__c pa: pas){
                    pa.End_Date__c = pa.Start_Date__c.addDays((Integer)p.Program_Duration_Days__c);
                    paSend.add(pa);
                }
            }
        }
        if(paSend.size() > 0){
            update paSend;
        }
        
        
    }
}