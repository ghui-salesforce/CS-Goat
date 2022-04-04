global class scheduledProgramAssignmentLOE implements Schedulable {
    global void execute(SchedulableContext sc) {
        calculateProgramAssignmentLOE();
    }
    public static void calculateProgramAssignmentLOE(){
        List<Program_Assignment__c> pasSend = new List<Program_Assignment__c>();
        List<Program_Assignment__c> pas = [SELECT id,Program__c,Contact__c
                                           FROM Program_Assignment__c];
  
        for(Program_Assignment__c pa: pas){
            List<Training_Task_Assignment__c> ttas = [SELECT id,Program_Assignment__c,Duration_Mins__c,Due_Date__c
                                                   FROM Training_Task_Assignment__c
                                                   WHERE Program_Assignment__c = :pa.id];
            //System.debug('For PA = '+ pa.Id + ' it has these TTAs = '+ttas);
            pa.Expected_Mins_Due__c = 0; //reset the value for each time the scheduled apex runs
            for(Training_Task_Assignment__c tta: ttas){ //perform sum
                if (tta.Program_Assignment__c != null && tta.Due_Date__c < date.today()){
                    pa.Expected_Mins_Due__c += tta.Duration_Mins__c;
                    //System.debug('Incremented expected mins for pa = '+pa.Id);
                }
            }
            pasSend.add(pa);
        }
        
        if(pasSend.size() > 0){
            //System.debug('Sending these PA for pasSend = '+pasSend);
            update pasSend;
        }
    }
}