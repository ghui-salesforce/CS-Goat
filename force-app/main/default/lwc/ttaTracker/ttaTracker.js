import { LightningElement, api, wire, track } from 'lwc';
import getTTAs from '@salesforce/apex/TrainingTaskAssignmentController.getTTAs';
import updateTTAs from '@salesforce/apex/TrainingTaskAssignmentController.updateTTAs';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const tta_table_columns = [
    {label: 'Training Task Assignment', fieldName: 'Training_Task_Assignment_url', type:'url', sortable: 'true',
        typeAttributes: {
            label: {
                fieldName: 'Training_Task_Assignment_Name'
            }
        }
    },
    { label: 'Start Date', fieldName: 'Start_Date', type: 'date-local',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'}},
    { label: 'Due Date', fieldName: 'Due_Date', type: 'date-local', sortable: 'true',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'}},

    {
        label: 'Status', fieldName: 'Status', type: 'picklist', editable: 'true', sortable: 'true', typeAttributes: {
            placeholder: 'Choose status', options: [
                { label: 'Not Started', value: 'Not Started' },
                { label: 'In-Progress', value: 'In-Progress' },
                { label: 'Complete', value: 'Complete' },
            ] // list of all picklist options
            , value: { fieldName: 'Status' } // default value for picklist
            , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },

    { label: 'Completion Date', fieldName: 'Date_Completed', type: 'date-local', editable: 'true',
        typeAttributes: {
            day: 'numeric',
            month: 'numeric',
            year: 'numeric'}},
    { label: 'Actual Minutes', fieldName: 'Actual_Mins', type: 'text', editable: 'true'},
];


export default class TtaTracker extends LightningElement {
    @api recordId;
    @track data;
    @track sortBy;
    @track sortDirection;
    @track draftValues = [];
    lastSavedData = [];


    ttaColumns = tta_table_columns;
    refreshData;

    @wire(getTTAs, { paID: '$recordId' })
    wiredTTAList(result) {
        //console.log('paRecordId = ' + this.paRecordId);
        if (result.data) {
            //console.log('entered if statement');
            //console.log('testing recordid = ' + this.paRecordId);
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

    handleSortData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('event details = ' + JSON.stringify(event.detail));
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = await updateTTAs({data: updatedFields});
                    
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);
    
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
    //listener handler to get the context and data
    //updates datatable
    picklistChanged(event) {
        event.stopPropagation();
        let dataReceived = event.detail.data;
        let updatedItem = { Id: dataReceived.context, Status: dataReceived.value };
        /*  this would only works for Status, which is why updateDataValues and updateDraftValues method exists
            for (let i=0;i<this.data.length;i++){
                if (this.data[i].Id == updatedItem.Id){
                    this.data[i].Status = updatedItem.Status;
             }
            }
        */
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    // methods below from https://live.playg.app/play/picklist-in-lightning-datatable
    updateDataValues(updateItem) {
        let copyData = [... this.data];
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        //write changes back to original data
        this.data = [...copyData];
    }
    
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
   // handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

}