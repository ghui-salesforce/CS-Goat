import { LightningElement, api, wire, track } from 'lwc';
import getTTAs from '@salesforce/apex/TrainingTaskAssignmentController.getTTAs';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

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
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    };


    /**
     * 
     
    @wire(getContacts, { accId: '$recordId' })
    contact;
    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = await updateContacts({data: updatedFields});
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contact updated',
                    variant: 'success'
                })
            );
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);
    
            // Display fresh data in the datatable
            refreshApex(this.contact).then(() => {
                // Clear all draft values in the datatable
                this.draftValues = [];
            });
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
    */
}