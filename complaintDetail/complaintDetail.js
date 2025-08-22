import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

const FIELDS = [STATUS_FIELD];

export default class ComplaintDetail extends LightningElement {
 recordId;
    @track statusStep = 'New';
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('recodrd id',currentPageReference?.state?.c__recordId)
        if (currentPageReference?.state?.c__recordId) {
            console.log('recodrd inside id',currentPageReference?.state?.c__recordId);
            this.recordId = currentPageReference.state.c__recordId;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ data }) {
        if (data) {
            this.statusStep = data.fields.Status.value;
        }
    }
}