import { LightningElement } from 'lwc';

export default class CaseDashboard extends LightningElement {
    selectedCase;

    handleCaseSelection(event) {
        this.selectedCase = event.detail;
    }
}