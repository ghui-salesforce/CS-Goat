import { LightningElement, api, wire, track } from 'lwc';
import getTTAs from '@salesforce/apex/TrainingTaskAssignmentController.getTTAs';
import updateTTAs from '@salesforce/apex/TrainingTaskAssignmentController.updateTTAs';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const tta_table_columns = [
    {label: 'Training Task Assignment', fieldName: 'Training_Task_Assignment_url', type:'url',
        typeAttributes: {
            label: {
                fieldName: 'Training_Task_Assignment_Name'
            }
        }
    },
    { label: 'Start Date', fieldName: 'Start_Date', type: 'text'},
    { label: 'Due Date', fieldName: 'Due_Date', type: 'text'},
    { label: 'Status', fieldName: 'Status', type: 'text', editable: 'true'},
    { label: 'Completion Date', fieldName: 'Date_Completed', type: 'text', editable: 'true'},
    { label: 'Actual Minutes', fieldName: 'Actual_Mins', type: 'text', editable: 'true'},
];


export default class TtaTracker extends LightningElement {
    @api recordId;
    @track data;
    ttaColumns = tta_table_columns;
    refreshData;

    @wire(getTTAs, { paID: '$recordId' })
    wiredTTAList(result) {
        if (result.data) {
            console.log('entered if statement');
            this.data = result.data.map((element) => ({
                ...element,
                ...{
                    'Training_Task_Assignment_url': '/lightning/r/Training_Task_Assignment__c/'+element.Id+'/view',
                    'Training_Task_Assignment_Name': element.Training_Task__r.Name,
                    'Start_Date': element.Start_Date__c,
                    'Due_Date': element.Due_Date__c,
                    'Status': element.Status__c,
                    'Date_Completed': element.Date_Completed__c,
                    'Actual_Mins': element.Actual_Mins__c
                }
            }));
            this.error = undefined;
            this.refreshData = result;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined; 
        }
    };

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('event details = ' + JSON.stringify(event.detail));
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
        try {
            console.log('Entered try statement');
            console.log('updatedFields = ' + JSON.stringify(updatedFields));
            // Pass edited fields to the updateContacts Apex controller
            const result = await updateTTAs({data: updatedFields});
            console.log(JSON.stringify("Apex update result: "+ result));
                    
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);
            console.log('executed getRecordNotifyChange');
    
            // Display fresh data in the datatable
            await refreshApex(this.refreshData);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Training Task Assignments updated',
                    variant: 'success'
                })
            );
       } catch(error) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error updating or refreshing records',
                       message: error.body.message,
                       variant: 'error'
                   })
             );
        };
    }
    
}