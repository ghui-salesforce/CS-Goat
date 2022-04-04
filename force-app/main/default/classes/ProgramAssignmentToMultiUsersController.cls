public with sharing class ProgramAssignmentToMultiUsersController {
    //get all Contacts with Employee record type
	@AuraEnabled(cacheable=true)
    public static List<Contact> getAllEmployee(){
        List<sObject> employeeRecordType = [SELECT Id,Name FROM RecordType WHERE sObjectType='Contact' AND Name='Employee'];
        return [SELECT id,name,RecordTypeId FROM Contact WHERE RecordTypeId=:employeeRecordType[0].Id ORDER BY Name];
    }
    //get all Employees that have not been assigned to that program
	@AuraEnabled(cacheable=true)
    public static List<Contact> getAvailableEmployee(Program__c pSelection){
        List<Program_Assignment__c> pas = [SELECT id,name,Program__c,Contact__c FROM Program_Assignment__c
                                           WHERE Program__c =:pSelection.Id];
        Map<id,id> contactProgramMap = new Map<id,id>();
        List<Contact> availableEmployees = new List<Contact>();
        
        for(Program_Assignment__c pa:pas){ //get a map of all Contacts that are assigned to this program
            contactProgramMap.put(pa.Contact__c, pa.Program__c);
        }

        List<Contact> employees = getAllEmployee(); //get all employees
        for(Contact employee:employees){ //compare to see if the employee already has that program assigned to them (by checking key)
            if(!contactProgramMap.containsKey(employee.Id)){ //if the employee isn't part of that program, then add it to available employee list
                availableEmployees.add(employee);
            }
        }
        return availableEmployees;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getAllPrograms(){
        return [SELECT id,name FROM Program__c];
    }

}