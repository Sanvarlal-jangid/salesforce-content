import { LightningElement, track } from 'lwc';
import getAllContacts from '@salesforce/apex/AccountContactController.getAllContacts';
import associateContactsToAccount from '@salesforce/apex/AccountContactController.associateContactsToAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountContactManager extends LightningElement {
    @track showAccountModal = false;
    @track showContactModal = false;
    @track accountId;
    flag = true;
    @track contacts = [];
    @track selectedContactIds = [];

    columns = [
          {
            label: 'Select',
            type: 'contactSelector',
            typeAttributes: {
                disabled: { fieldName: 'isDisabled' },
                selected: { fieldName: 'isSelected' },
                Id: { fieldName: 'Id'}
            }
        },
        { label: 'Name', fieldName: 'Name', cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Email', fieldName: 'Email', cellAttributes: { class: { fieldName: 'rowClass' } } },
        { label: 'Phone', fieldName: 'Phone', cellAttributes: { class: { fieldName: 'rowClass' } } }
      
    ];

    openAccountModal() {
        console.log('Opening Account Modal');
        this.showAccountModal = true;
    }

    handleAccountSuccess(event) {
        this.accountId = event.detail.id;
        console.log('Account created with Id:', this.accountId);
        this.showAccountModal = false;
        this.loadContacts();
    }

    loadContacts() {
        console.log('Fetching all contacts from Apex...');
        getAllContacts()
            .then(result => {
                console.log('Contacts received from Apex:', result);

                this.contacts = result.map(c => {
                    const isDisabled = c.AccountId ? true : false;
                    const rowClass = isDisabled
                        ? 'slds-theme_alert-texture slds-theme_error slds-has-background'
                        : 'slds-theme_success slds-has-background';

                    return {
                        ...c,
                        isDisabled: isDisabled,
                        isSelected: false,
                        rowClass: rowClass
                    };
                });

                console.log('Processed contacts with rowClass and isDisabled:', this.contacts);
                this.showContactModal = true;
            })
            .catch(error => {
                console.error('Error loading contacts:', error);
                this.showToast('Error loading contacts', error.body.message, 'error');
            });
    }

    handleSaveContacts() {
        // this.selectedContactIds = this.contacts.filter(c => !c.isDisabled && c.isSelected)
        //     .map(c => c.Id);

        console.log('Selected Contact IDs to associate:', this.selectedContactIds);
        console.log('accountid',this.accountId);

        if (this.selectedContactIds.length === 0) {
            this.showToast('No Selection', 'Please select at least one contact.', 'warning');
            return;
        }

        associateContactsToAccount({ accountId: this.accountId, contactIds: this.selectedContactIds })
            .then(() => {
                console.log('Contacts successfully linked to account.');
                this.showToast('Success', 'Contacts linked successfully!', 'success');
                this.showContactModal = false;
            })
            .catch(error => {
                console.error('Error linking contacts:', error);
                this.showToast('Error', error.body.message, 'error');
            });
    }

    closeAccountModal() {
        console.log('Closing Account Modal');
        this.showAccountModal = false;
    }

    closeContactModal() {
        console.log('Closing Contact Modal');
        this.showContactModal = false;
    }

    showToast(title, message, variant) {
        console.log(`Toast: ${title} - ${message} [${variant}]`);
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleselected(event){
        
        console.log('printing recordid',event.detail.recordId);
        this.selectedContactIds.push(event.detail.recordId);

    
    }
}