import { LightningElement } from 'lwc';

export default class AccountContactContainer extends LightningElement {
    selectedAccountId;

    handleAccountSelected(event) {
        this.selectedAccountId = event.detail;
    }
}