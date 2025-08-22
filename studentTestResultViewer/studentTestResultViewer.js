import { LightningElement, wire, track } from 'lwc';
import getdata from '@salesforce/apex/mocktestresult.getdata';

export default class StudentTestResultViewer extends LightningElement {
    @track datalist = [];
    @track sortBy;
    @track sortDirection;
    @track showViewModal = false;
    @track selectedRecordId;
    @track selectedRowIds = [];

    columns = [
        {
            label: 'Test Name',
            fieldName: 'Test_name__c',
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
            label: 'Score',
            fieldName: 'Score__c',
            sortable: true,
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
            label: 'Result',
            fieldName: 'Result_Status__c',
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
            label: 'Date of Attempt',
            fieldName: 'Date_of_attempt__c',
            sortable: true,
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
            label: 'Student',
            fieldName: 'StudentName',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'StudentName' },
                name: 'viewStudent',
                variant: 'base'
            },
            cellAttributes: { class: { fieldName: 'rowClass' } }
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [{ label: 'View', name: 'view' }]
            }
        }
    ];

    @wire(getdata)
    wiredata({ data, error }) {
        if (data) {
            this.datalist = data.map(row => {
                let rowClass = '';
                if (row.Result_Status__c === 'Pass') {
                    return {
                    ...row,
                    StudentName: row.Student__r ? row.Student__r.Name : '—',
                    rowClass : 'slds-theme_success'
                };
                
                } return {
                    ...row,
                    StudentName: row.Student__r ? row.Student__r.Name : '—',
                    rowClass : 'slds-theme_error'
                };
            });
        } else if (error) {
            console.error('Error fetching data:', error);
        }
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        this.selectedRecordId = row.Id;

        if (action === 'view') {
            this.showViewModal = true;
        }
    }

    closeModal() {
        this.showViewModal = false;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.datalist));
        let keyValue = (a) => a[fieldname] || '';
        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x);
            y = keyValue(y);
            return isReverse * ((x > y) - (y > x));
        });

        this.datalist = parseData;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.Id);
        console.log('Selected Row IDs:', this.selectedRowIds);
    }
}