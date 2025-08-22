import { LightningElement, wire } from 'lwc';
import getAllCases from '@salesforce/apex/CaseController.getAllCases';

export default class CaseList extends LightningElement {
    cases = [];

    columns = [
        { label: 'Case ID', fieldName: 'CaseNumber' },
        { label: 'Subject', fieldName: 'Subject' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Priority', fieldName: 'Priority' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View Details', name: 'view_details' }
                ]
            }
        }
    ];

    @wire(getAllCases)
    wiredCases({ error, data }) {
        if (data) {
            this.cases = data;
        } else {
            console.error(error);
        }
    }

    get newCount() {
        return this.cases.filter(c => c.Status === 'New').length;
    }

    get workingCount() {
        return this.cases.filter(c => c.Status === 'Working').length;
    }

    get escalatedCount() {
        return this.cases.filter(c => c.Status === 'Escalated').length;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view_details') {
            this.dispatchEvent(new CustomEvent('caseselected', {
                detail: row
            }));
        }
    }
}