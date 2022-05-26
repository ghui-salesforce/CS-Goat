import { LightningElement, api, wire, track } from 'lwc';
import getPAs from '@salesforce/apex/TrainingTaskAssignmentController.getPAs';

const pa_columns = [
    {label: 'Program Assignment', fieldName: 'Program_Assignment_url', type:'url',
        typeAttributes: {
            label: {
                fieldName: 'Program_Assignment_Name'}}},
    { label: 'Start Date', fieldName: 'Start_Date', type: 'date-local', 
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'}},
    { label: 'End Date', fieldName: 'End_Date', type: 'date-local',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'}},
    { label: 'Status', fieldName: 'Status', type: 'text'},
    { label: 'Ahead/Behind', fieldName: 'Ahead_Behind', type: 'text'},
];

export default class TtaTrackerParent extends LightningElement {
    @api recordId;
    @api selectedRows;
    @track data;
    columns = pa_columns;
    childCompVar = this.template.querySelector('c-tta-tracker');
    refreshData;

    @wire(getPAs, { contactId: '$recordId' })
    wiredPAList(result) {
        if (result.data) {
            this.data = result.data.map((element) => ({
                ...element,
                ...{
                    'Program_Assignment_url': '/lightning/r/Program_Assignment__c/'+element.Id+'/view',
                    'Program_Assignment_Name': element.Program__r.Name,
                    'Start_Date': element.Start_Date__c,
                    'End_Date': element.End_Date__c,
                    'Status': element.Status__c,
                    'Ahead_Behind': element.Ahead_Behind__c,
                }
            }));
            this.error = undefined;
            this.refreshData = result;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined; 
        }
    };
    // returns a <string> recordId of the selectedRow
    handleRowSelection(event){
        this.selectedRows = event.detail.selectedRows;
        try{
            if (this.selectedRows.length == 1) {
                this.selectedRows = event.detail.selectedRows[0].Id;
            }
            else if (this.selectedRows.length > 1) {
                var el = this.template.querySelector('lightning-datatable');
                el.selectedRows = el.selectedRows.slice(1);
                this.selectedRows = el.selectedRows[0];
                event.preventDefault();
            }
            return;
        }
        catch (error){
            console.log('caught: error = ' + JSON.stringify(error.message));
        }

    }

    handleRefresh(event){
        refreshApex(this.refreshData);
    }
}