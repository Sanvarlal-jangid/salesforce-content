import { LightningElement, wire, track } from 'lwc';
import getCases from '@salesforce/apex/ComplaintController.getCases';
import { NavigationMixin } from 'lightning/navigation';

export default class ComplaintList extends NavigationMixin(LightningElement) {
    @track cases = [];
    @track filteredCases = [];
    searchKey = '';
    searchCaseNumber = '';
    searchProductName = '';
    searchContactName = '';

    columns = [
        {
            label: 'Case Number',
            fieldName: 'CaseNumber',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'CaseNumber' },
                name: 'view_detail'
            }
        },
        { label: 'Product Name', fieldName: 'Product__c' },
        { label: 'Contact Name', fieldName: 'ContactName' },
        { label: 'Subject', fieldName: 'Subject' },
        {
            label: 'Status',
            fieldName: 'Status',
            cellAttributes: {
                class: { fieldName: 'statusClass' }
            }
        }
    ];

    @wire(getCases)
    wiredCases({ data, error }) {
        if (data) {
            this.cases = data.map(item => {
                let statusColor;

                if (item.Status === 'New') {
                    statusColor = 'slds-text-color_success';
                } else if (item.Status === 'Working') { 
                    statusColor = 'slds-text-color_success';
                } else if (item.Status === 'Escalated') {
                    statusColor = 'slds-text-color_warning';
                } else if (item.Status === 'Closed') {
                    statusColor = 'slds-text-color_error';
                } else {
                    statusColor = '';
                }



                return {
                    ...item,

                    ContactName: item.Contact?.Name,
                    statusClass: statusColor
                };
            });
            this.filteredCases = [...this.cases];
        } else if (error) {
            console.error(error);
        }
    }

    handleCaseNumberChange(event) {
        this.searchCaseNumber = event.target.value;
        this.filterCases();
    }

    handleProductNameChange(event) {
        this.searchProductName = event.target.value;
        this.filterCases();
    }

    handleContactNameChange(event) {
        this.searchContactName = event.target.value;
        this.filterCases();
    }

    filterCases() {
        this.filteredCases = this.cases.filter(c =>
            (!this.searchCaseNumber || c.CaseNumber.includes(this.searchCaseNumber)) &&
            (!this.searchProductName || (c.ProductName__c || '').toLowerCase().includes(this.searchProductName.toLowerCase())) &&
            (!this.searchContactName || (c.ContactName || '').toLowerCase().includes(this.searchContactName.toLowerCase()))
        );
    }

      handleSearchChange(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.filteredCases = this.cases.filter(caseItem =>
            caseItem.CaseNumber.toLowerCase().includes(this.searchKey) ||
            (caseItem.Product__c && caseItem.Product__c.toLowerCase().includes(this.searchKey)) ||
            (caseItem.ContactName && caseItem.ContactName.toLowerCase().includes(this.searchKey))
        );
    }
    handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'view_detail') {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__complaintDetail'
            },
            state: {
                c__recordId: row.Id
            }
        });
    }
}

}