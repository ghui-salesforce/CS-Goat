@isTest
private class ProgramAssignmentToMultiUsersTests {
    @TestSetup
    static void makeTestObjects(){

        RecordType rt = [SELECT id FROM RecordType WHERE Name =: 'Employee'];

        Contact testContact = new Contact();
        testContact.LastName = 'Smith';
        testContact.Role__c = 'Director';
        testContact.RecordTypeId = rt.id;
        insert testContact;

        Contact testContact2 = new Contact();
        testContact2.LastName = 'Jones';
        testContact2.Role__c = 'Technical Consultant';
        testContact2.ReportsToId = testContact.id;
        //Contact record type for Employee
        testContact2.RecordTypeId = rt.id;
        insert testContact2;

        Program__c testProgram = new Program__c();
        testProgram.Name = 'Intro to Development';
        testProgram.Program_Duration_Days__c= 12;
        insert testProgram;

        List<Program_Assignment__c> listOfProgramAssignments = new List<Program_Assignment__c>();
        Program_Assignment__c testProgramAssignment = new Program_Assignment__c();
        testProgramAssignment.Start_Date__c = date.Today();
        testProgramAssignment.Program__c = testProgram.id;
        testProgramAssignment.Contact__c = testContact.id;
        listOfProgramAssignments.add(testProgramAssignment);

        if (!listOfProgramAssignments.isEmpty()){
            insert testProgramAssignment;
        }
    }

    @isTest 
    static void getAvailableEmployeeTest() {
        Program__c myProgram= [SELECT id, Name FROM Program__c WHERE Name = 'Intro to Development'];
        List<Contact> actualResult = ProgramAssignmentToMultiUsersController.getAvailableEmployee(myProgram.id, '', '', '');

        Contact contact = [SELECT id, Name FROM Contact WHERE Role__c =: 'Director' AND LastName =: 'Smith'];
        Contact contact2 = [SELECT id, Name FROM Contact WHERE Role__c =: 'Technical Consultant' AND LastName =: 'Jones'];
        RecordType rc = [SELECT id FROM RecordType WHERE Name =: 'Employee'];

        List<Contact> expectedResult = new List<Contact>();
        Contact expectedContact = new Contact();
        expectedContact.Role__c = 'Director';
        expectedContact.LastName = 'Smith';
        expectedContact.Id = contact.Id;

        Contact expectedContact2 = new Contact();
        expectedContact2.id = contact2.id;
        expectedContact2.LastName = 'Jones';
        expectedContact2.Role__c = 'Technical Consultant';
        expectedContact2.RecordTypeId = rc.id;

        expectedResult.add(expectedContact2);

        System.assertEquals(expectedResult.size(), actualResult.size());
        System.assertEquals(expectedResult[0].id, actualResult[0].id);
        System.assertEquals(expectedResult[0].Role__c, actualResult[0].Role__c);
        System.assertEquals(expectedResult[0].LastName, actualResult[0].Name);
    }  

    @isTest 
    static void getFilteredEmployeesByManagerTest() {
        List<Contact> actualResult = ProgramAssignmentToMultiUsersController.getFilteredEmployees('', '', 'Smith');
        System.assertEquals('Smith', actualResult[0].ReportsToName__c);
        System.assertEquals('Technical Consultant', actualResult[0].Role__c);
        System.assertEquals(1, actualResult.size());
    }  
}