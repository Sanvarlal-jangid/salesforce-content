import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import getContactsByAccount from '@salesforce/apex/AccountController.getContactsByAccount';

export default class Accountview extends LightningElement {

    accountColumns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Industry', fieldName: 'Industry' }
    ];

    
    AccountsList = [];
    @wire(getAccounts)
    wireData({ data, error }) {
        if (data) {
            this.AccountsList = data;
        } else {
            this.AccountsList = undefined;
        }
    }
    contactColumns = [
        { label: 'Contact Name', fieldName: 'Name' },
        { label: 'Account Name', fieldName: 'AccountName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' }
    ];

  @wire(getAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accounts = data;
        }
    }
   contactList = [];
  @wire(getContactsByAccount)
    wiredAccounts({ data, error }) {
        if (data) {
            this.contactList = data;
        }
    }
}