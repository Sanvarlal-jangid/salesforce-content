import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class AccountList extends LightningElement {
    accounts = [];
    columns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Industry', fieldName: 'Industry' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Select',
                name: 'select',
                variant: 'brand'
            }
        }
    ];

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
        } else {
            console.error(error);
        }
    }

    handleRowAction(event) {
        const selectedId = event.detail.row.Id;
        const selectedEvent = new CustomEvent('accountselected', {
            detail: selectedId
        });
        this.dispatchEvent(selectedEvent);
    }
}