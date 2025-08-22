import { LightningElement, track } from 'lwc';
import getOpenOpportunities from '@salesforce/apex/OpportunityController.getOpenOpportunities';
import searchOpportunities from '@salesforce/apex/OpportunityController.searchOpportunities';
import updateOpportunityStatuses from '@salesforce/apex/OpportunityController.updateOpportunityStatuses';

export default class OpportunityTracker extends LightningElement {
    @track opportunities = [];
    selectedIds = [];
    nameFilter = '';
    statusFilter = '';
    newStatus = '';

    connectedCallback() {
        this.loadOpportunities();
    }

    loadOpportunities() {
        getOpenOpportunities()
            .then(result => {
                this.opportunities = result;
            })
            .catch(error => {
                console.error('Error loading opps:', error);
            });
    }

    handleNameChange(event) {
        this.nameFilter = event.target.value;
    }

    handleStatusChange(event) {
        this.statusFilter = event.target.value;
    }

    handleSearch() {
        searchOpportunities({
            name: this.nameFilter,
            status: this.statusFilter
        })
            .then(result => {
                this.opportunities = result;
            })
            .catch(error => {
                console.error('Search error:', error);
            });
    }

    handleRowSelection(event) {
        console.log('event .targaet',event.target)
        console.log('event .detail',event.detail)
        const selectedRows = event.detail.selectedRows;
        this.selectedIds = selectedRows.map(row => row.Id);
        console.log('Selected Opp IDs:', this.selectedIds);
    }

    handleNewStatusChange(event) {
        this.newStatus = event.target.value;
    }

    handleUpdateStatus() {
        if (!this.selectedIds.length) {
            return;
        }

        updateOpportunityStatuses({
            oppIds: this.selectedIds,
            newStatus: this.newStatus
        })
            .then(() => {
                this.loadOpportunities();    
                this.selectedIds = [];       
                this.newStatus = '';    
            })
            .catch(error => {
                console.error('Update failed:', error);
            });
    }

    get statusOptions() {
        return [
            { label: 'Prospecting', value: 'Prospecting' },
            { label: 'Qualification', value: 'Qualification' },
            { label: 'Negotiation', value: 'Negotiation' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    get columns() {
        return [
            { label: 'Opportunity Name', fieldName: 'Name' },
            { label: 'Stage', fieldName: 'StageName' },
            { label: 'Amount', fieldName: 'Amount', type: 'currency' },
            { label: 'Close Date', fieldName: 'CloseDate', type: 'date' }
        ];
    }
}