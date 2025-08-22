import { LightningElement, wire, track } from 'lwc';
import getRecords from '@salesforce/apex/RecordHandler.getRecords';
import getUsers from '@salesforce/apex/RecordHandler.getUsers';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import assignRecords from '@salesforce/apex/RecordHandler.assignRecords';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

export default class Picklistobjecttodatatable extends NavigationMixin(LightningElement) {
    value = 'Case'; // Default selected object
    data = [];
    Userdata = [];
    selectedRecordIds = [];
    selectedUserIds = [];
    wiredResult;
  
    get options() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
            { label: 'Lead', value: 'Lead' },
            { label: 'Opportunity', value: 'Opportunity' },
            { label: 'Case', value: 'Case' }
        ];
    }


    get columns() {
        let baseColumns = [
            this.value === 'Case'
                ? { label: 'Case Number', fieldName: 'CaseNumber' }
                : { label: 'Name', fieldName: 'Name' },
            { label: 'Owner', fieldName: 'Ownername' },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [
                        { label: 'View', name: 'view' },
                        { label: 'Edit', name: 'edit' },
                        { label: 'Delete', name: 'delete' }
                    ]
                }
            }
        ];
        return baseColumns;
    }

    get columnss() {
        return [
            { label: 'Name', fieldName: 'Name' },
            { label: 'Username', fieldName: 'Username' },
            { label: 'Email', fieldName: 'Email' },
            {
                type: 'button',
                typeAttributes: {
                    label: 'Assign',
                    name: 'assign',
                    variant: 'brand'
                }
            }
        ];
    }

    
    handleChange(event) {
        this.value = event.detail.value;
    }

  
    @wire(getRecords, { objectApiName: '$value' })
    wiredRecords(result) {
        this.wiredResult = result;
        if (result.data) {
            this.data = result.data.map(row => ({
                ...row,
                Ownername: row.Owner?.Name,
            
            }));
        }else if(this.wiredResult.error){
            console.log('recordds not fetched');
        }
    }

  
    @wire(getUsers)
    wiredUsers({ data }) {
        if (data) {
            this.Userdata = data;
        }
    }



    handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'view' || actionName === 'edit') {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: this.value,
                actionName: actionName
            }
        });
        refreshApex(this.wiredResult);
    } else if (actionName === 'delete') {
        deleteRecord(row.Id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `${this.value} record deleted`,
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    } else if (actionName === 'assign') {
        assignRecords({
            objectApiName: this.value,
            recordIds: this.selectedRecordIds,
            newOwnerId: row.Id
        }).then(() => {
            this.selectedRecordIds = [];
            refreshApex(this.wiredResult);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error assigning records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}


    // Store selected records
    handleSelection(event) {
        this.selectedRecordIds = event.detail.selectedRows.map(row => row.Id);
    }

    // Store selected users and filter records
    handleUserSelection(event) {
        this.selectedUserIds = event.detail.selectedRows.map(row => row.Id);
        this.data = this.data.filter(record => this.selectedUserIds.includes(record.OwnerId));
    }
    
}