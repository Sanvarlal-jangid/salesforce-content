import { LightningElement, wire, track } from 'lwc';
import getAccountsforaccodion from '@salesforce/apex/getaccountaccordion.getAccountsforaccodion';
import { deleteRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class Practicepaper1 extends NavigationMixin(LightningElement) {


  accounts;
  @track accountrefresh;

  @wire(getAccountsforaccodion)
  gettingData(result) {
    this.accountrefresh = result;
    if (result.data) {
      console.log('data coming for account', result.data);
      this.accounts = result.data;

    } else if (result.error) {
      console.log('err111or', result.error);
    }

  }
  handledelete(event) {
    const contactId = event.target.dataset.object;
    console.log('Contact to delete:', contactId);

    deleteRecord(contactId)
      .then(() => {
        console.log('Record deleted successfully');
        this.showToast('Success!!', 'Record deleted successfully!!', 'success');
        refreshApex(this.accountrefresh);

      })
      .catch(error => {
        console.error('Error deleting record:', error);
        this.showToast('Error!!', error.body.message, 'error');

      });



  }

  handleedit(event){
     const accountid = event.target.dataset.object;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: accountid,
        objectApiName: 'Account',
        actionName: 'edit'
      }
    });
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: 'dismissable'
    });
    this.dispatchEvent(event);
  }
}