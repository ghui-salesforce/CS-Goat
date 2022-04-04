import { LightningElement, wire, api, track } from 'lwc';
import getAvailableEmployee from '@salesforce/apex/ProgramAssignmentToMultiUsersController.getAvailableEmployee';
import createProgramAssignments from '@salesforce/apex/ProgramAssignmentToMultiUsersController.createProgramAssignments';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';


import PROGRAM_FIELD from '@salesforce/schema/Program__c.Id';
import NAME_FIELD from '@salesforce/schema/Program__c.Name';
import PROGRAM_DURATION_IN_DAYS_FIELD from '@salesforce/schema/Program__c.Program_Duration_Days__c';

const table_columns_employee = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Role', fieldName: 'Role__c', type: 'text' },
];

const fields = [PROGRAM_FIELD, NAME_FIELD, PROGRAM_DURATION_IN_DAYS_FIELD];

const employeeIDs = [];


export default class ProgramAssigmentToMultiUsers extends LightningElement {

    @api recordId; //store the current record's ID
    @track searchKeyName = '';
   // @track searchKeyEmployeeID = '';
    @track searchKeyRole = '';
    @track startDate;
    @track employees;
    @track wiredEmployeeList = [];
    employeeColumns = table_columns_employee;    //Display the the list of available employees to be assigned

    // toast event messaging
    variant = 'success';
    title = {
        error: 'Error',
        success: 'Success',
        noSelection: 'Error',
        noDate: 'Error'
    };
    message = {
        error: 'Unable to assign program',
        success: 'Successful mass assignment of this program to employees',
        noSelection: 'No employees were selected',
        noDate: 'Assignment date not selected'
    };

    // get program details
    @wire(getRecord, { recordId: '$recordId', fields }) program;
    // get PID() {
    //     return getFieldValue(this.program.data, PROGRAM_FIELD);
    // }
    get PName() {
        return getFieldValue(this.program.data, NAME_FIELD);
    }
    get PDuration() {
        return getFieldValue(this.program.data, PROGRAM_DURATION_IN_DAYS_FIELD);
    }

    // get initial employee table
    @wire(getAvailableEmployee, { pSelection: '$recordId', eName: '$searchKeyName', eRole: '$searchKeyRole' })
    wiredEmployeeList({ error, data }) {
        if (data) {
            this.employees = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.employees = undefined;
        }
    }

    // search/filter functionality for employee table
    handleChangedName(event) {
        this.searchKeyName = event.target.value;
        console.log('this.search key name = ' + this.searchKeyName);
        console.log('event.target.search key name = ' + event.target.value);

    }
    // handleChangedEmployeeID(event) {
    //     this.searchKeyEmployeeID = event.target.value;
    //     console.log('updated search key employeeID = ' + this.value);
    // }
    handleChangedRole(event) {
        this.searchKeyRole = event.target.value;
        console.log('updated search key role = ' + this.value);
    }

    //Get row selection of the employee (store each of their recordID into a variable, maybe a list?)
    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        employeeIDs.length = 0; // empty the selected employees from the list 
        for (let i = 0; i < selectedRows.length; i++) {
            console.log("You selected: " + selectedRows[i].Name + " Record ID: " + selectedRows[i].Id);
            employeeIDs.push(selectedRows[i].Id); // store employee record ids (because I dont know how to make selectedRows into a class constant)
        }
        console.log("Total number of selections: " + employeeIDs.length);
        
    }

    //date stuff
    handleDateChange(event) { // take user input for date value
        this.startDate = event.target.value;
    }

    //mass assign button click
    handleClick() {
        console.log("employeeIDs can be used: " + employeeIDs);
        console.log("program id can be used: " + this.recordId);
        console.log("start date: " + this.startDate);
        if (this.startDate == null){
            this.variant = "noDate";
        } else if (employeeIDs.length > 0) { // error checking for no assignments
            for (let i = 0; i < employeeIDs.length; i++) {
                //console.log("Hit click for " + employeeIDs[i]);
                //console.log("Trying to work with pa: " + this.recordId);
                try {
                    createProgramAssignments({ programID: this.recordId, employeeID: employeeIDs[i], startDate: this.startDate });
                    console.log("Created program assignments");
                    this.variant = "success";
                    this.dispatchEvent(new CloseActionScreenEvent()); //auto close the lwc upon success
                }
                catch (error) {
                    console.error("Error: " + error);
                    this.variant = "error";
                }

            }
        } else { // no employees were selected, but the assignment button was clicked
            this.variant = "noSelection";
        }
        this.dispatchEvent(new ShowToastEvent({
            title: this.title[this.variant],
            message: this.message[this.variant],
            variant: this.variant
        }));
        // refreshApex(this.employees);
        // console.log("Refreshed list of employees");
    }
}