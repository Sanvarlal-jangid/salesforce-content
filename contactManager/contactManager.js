import { LightningElement, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/AccountController.getContacts';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ContactManager extends NavigationMixin(LightningElement) {
    @track contacts = [];
    @track selectedRecordId;
    @track showViewModal = false;
    @track showEditModal = false;

    wiredResult;
   
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Account',fieldName: 'AccountName',   type: 'button',  typeAttributes: {
                                                                        label: { fieldName: 'AccountName' },
                                                                                 name: 'viewAccount',
                                                                                  variant: 'base'
                                                                                  }},
        { label: 'Lead Source', fieldName: 'LeadSource' },
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

    @wire(getContacts)
    wiredContacts(result) {
        this.wiredResult = result;
        if (result.data) {
            this.contacts = result.data.map(row => ({
                ...row,
                AccountName: row.Account?.Name || ''
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        this.selectedRecordId = row.Id;

        if (action === 'view') {
            this.showViewModal = true;
        } else if (action === 'edit') {
            this.showEditModal = true;
        } else if (action === 'delete') {
            this.deleteContact(row.Id);
        } else if (action === 'viewAccount' && row.AccountId) {
            this.navigateToAccount(row.AccountId);
        }
    }

    deleteContact(recordId) {
        deleteRecord(recordId)
            .then(() => {
                this.showToast('Success', 'Contact deleted', 'success');
                 refreshApex(this.wiredResult);
            })
            .catch(error => {
                this.showToast('Error', 'Delete failed', 'error');
                console.error(error);
            });
    }

    handleNewContact() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            }
        });
    }

    handleRecentlyViewed() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'list'
            },
            state: {
                filterName: 'RecentlyViewedContacts'
            }
        });
    }

    navigateToAccount(accountId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    handleSuccess() {
        this.closeModal();
        this.showToast('Success', 'Contact updated successfully', 'success');
        return refreshApex(this.wiredResult);
    }

    closeModal() {
        this.showViewModal = false;
        this.showEditModal = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}