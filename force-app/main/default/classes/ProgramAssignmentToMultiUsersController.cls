public with sharing class ProgramAssignmentToMultiUsersController {
    //get all Employees that have not been assigned to that program
	@AuraEnabled(cacheable=true)
    public static List<Contact> getAvailableEmployee(String pSelection, String eName, String eRole){
        List<Program_Assignment__c> pas = [SELECT id,name,Program__c,Contact__c FROM Program_Assignment__c
                                           WHERE Program__c =:pSelection];
        Map<id,id> contactProgramMap = new Map<id,id>();
        List<Contact> availableEmployees = new List<Contact>();
        
        for(Program_Assignment__c pa:pas){ //get a map of all Contacts that are assigned to this program
            contactProgramMap.put(pa.Contact__c, pa.Program__c);
        }

        List<Contact> employees = getFilteredEmployees(eName, eRole); //get all employees
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

    //create a program assignment record with the parameter data
    @AuraEnabled
    public static void createProgramAssignments(id programID, String employeeID, Date startDate){
        System.debug('input programID: '+programID+', employeeID: '+employeeID+', startDate: '+startDate);
        Program_Assignment__c pa = new Program_Assignment__c();
        pa.Program__c = programID;
        pa.Contact__c = employeeID;
        pa.Start_Date__c = startDate;
        
        if (pa != null){
            insert pa;
        }
    }
    
    // helper method, get all Contacts with Employee record type
    // retrieves list of employee based off their name, id, or role.
    // id is an exact match filter
    public static List<Contact> getFilteredEmployees(String eName, String eRole){
        List<sObject> employeeRecordType = [SELECT Id,Name 
                                            FROM RecordType 
                                            WHERE sObjectType='Contact' AND Name='Employee'];
        List<Contact> returnEmployees;
        String eNameKey = '%' + eName + '%';
        String eRoleKey = '%' + eRole + '%';
        System.debug('eNameKey = '+eNameKey);
        System.debug('eRoleKey = '+eRoleKey);
        
        // filters through anyone with a name or role
        returnEmployees = [SELECT id,name,Role__c,RecordTypeId
                           FROM Contact
                           WHERE RecordTypeId=:employeeRecordType[0].Id
                           AND name LIKE :eNameKey
                           AND Role__c LIKE :eRoleKey];
        System.debug('Enter first if');
        
        System.debug('returning filtered employees: ' + returnEmployees);
        return returnEmployees;
    }
}