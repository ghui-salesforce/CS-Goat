public class scrapPaper {
    //this code does not work because it loops infinitely, due to the update trigger continuously being hit
    //this code can work if it's adjusted to be a scheduled batch apex, but unsure how if this is a scalable solution
    //similar TTA records belonging to the employee need to have updates propogated
    public static void UpdateSimilarTTA(List<Training_Task_Assignment__c> ttas){
        List<Training_Task_Assignment__c> ttaSend = new List<Training_Task_Assignment__c>();
        List<Training_Task_Assignment__c> relatedTTAs = new List<Training_Task_Assignment__c>();
        //Map<id,Integer> ttaMap = new Map<id,Integer>();//map of related tta's
        
        //loop through each training task assignment that gets updated
        //find any additional training tasks that were assigned to this employee
        //update all records with the most recently updated one
        //(but once this updates, what if I hit an update trigger and it gets called again? i need a condition for this to update..?)
        //(well...it wouldn't need to fire again, because the values will be the same at that point.)
        //I don't think i need to worry about infinite update trigger looping because it will stop once all TTA records are the same values
        for(Training_Task_Assignment__c tta: ttas){ //should expect just one TTA input
            relatedTTAs = [SELECT id,name,Training_Task__c,Contact__c,Status__c
                          FROM Training_Task_Assignment__c
                          WHERE Training_Task__c =:tta.Training_Task__c AND Contact__c=:tta.Contact__c
                          ORDER BY LastModifiedDate DESC]; //sort by last modified date, with earliest at the top e.g. arr[0]
            System.debug('relatedTTA\'s sorted by last modified date = '+relatedTTAs);
            if(relatedTTAs.size() > 1){ //only run this code if there is duplicate TTAs
                for(integer i=1;i<relatedTTAs.size();i++){
                    if(relatedTTAs[i].Status__c != relatedTTAs[0].Status__c){//if the most recently updated TTA status differs from others, change it
                    	relatedTTAs[i].Status__c = relatedTTAs[0].Status__c;
                        ttaSend.add(relatedTTAs[i]); 
                    }
                }
            }
        }
        if(ttaSend.size()>0){
            update ttaSend;
        }
    }
}