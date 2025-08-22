import { LightningElement, wire } from 'lwc';
import callapex from '@salesforce/apex/lookuphelper.getContacts';
import deletecontact from '@salesforce/apex/lookuphelper.deletecontact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShowAccountLookup extends LightningElement {


    // filter = {
    //     criteria: [
    //         {
    //             fieldPath: 'CreatedDate',
    //             operator: 'eq',
    //             value: { literal: 'TODAY' }
    //         }
    //     ],
    // };

    displayInfo = {
        additionalFields: ['Industry'],
    };


    matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'Industry' }],
    };



    accountId;
    contactList = [];
    contactList = []; // For displaying contacts
    selectedContactIds = []; // For storing selected contact IDs
    showSpinner = false;

    handlechange(event) {
        this.accountId = event.detail.recordId;
        console.log('tarage.recordid' + event.detail.recordId)
        console.log('record id of current account' + this.accountId);
    }


    handlerowselection(event) {
        this.selectedContactIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleDelete() {
        if (this.selectedContactIds.length > 0) {
            this.showSpinner = true;
            deletecontact({ conlist: this.selectedContactIds })
                .then(result => {
                    console.log('Deleted successfully');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Contacts Deleted',
                            variant: 'success',
                        }),
                    );
                    this.contactList = this.contactList.filter(contact =>!this.selectedContactIds.includes(contact.Id));
                    
                    this.selectedContactIds = [];
                })
                .catch(error => {
                    console.error('Error deleting contacts:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting contacts',
                            message: 'error while deleting contact',  //error.body.message
                            variant: 'error',
                        }),
                    );
                }).finally(() => {
                    this.showSpinner = false;
                });
        }
    }

    @wire(callapex, { accid: '$accountId' })
    wireData({ error, data }) {
        if (data) {
            this.contactList = data;
        } else if (error) {
            this.contactList = undefined;
        }
    }
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone' }
    ]

}