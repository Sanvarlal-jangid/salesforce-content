import { LightningElement, api, wire } from 'lwc';
import getContactsByAccount from '@salesforce/apex/AccountController.getContactsByAccount';

export default class ContactList extends LightningElement {
    @api accountId;
    contacts = [];

    columns = [
        { label: 'Contact Name', fieldName: 'Name' },
        { label: 'Account Name', fieldName: 'AccountName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' }
    ];

    @wire(getContactsByAccount, { accountId: '$accountId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data.map(c => ({
                ...c,
                AccountName: c.Account.Name
            }));
        } else {
            console.error(error);
        }
    }
}