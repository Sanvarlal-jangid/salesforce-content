import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex methods (replace with your actual Apex class and method names)
import getAccountOptions from '@salesforce/apex/Opportunitycustomdatatable.getAccountOptions';
import getOpportunities from '@salesforce/apex/Opportunitycustomdatatable.getOpportunities';
import updateOpportunity from '@salesforce/apex/Opportunitycustomdatatable.updateOpportunity';
import { loadStyle } from 'lightning/platformResourceLoader';
import DATATABLE_STYLES from '@salesforce/resourceUrl/datatablecss';

export default class YourComponentName extends NavigationMixin(LightningElement) {
    @track accountOptions = [];
    @track opportunities = [];
    //  @track stageOptions = [];
    @track totalOpportunityCount = 0;
    @track totalAmount = 0;
    @track selectedAccountId = '';

    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Needs Analysis', value: 'Needs Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Perception Analysis', value: 'Perception Analysis' },
        { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
        { label: 'Negotiation/Review', value: 'Negotiation/Review' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ]
    connectedCallback() {
        this.fetchAccountOptions();
        //  this.fetchStageOptions();
    }
    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([
                loadStyle(this, DATATABLE_STYLES)
            ]).then(() => {
                this.stylesLoaded = true;
            }).catch(error => {
                console.error('Error loading styles:', error);
            });
        }
    }

    fetchAccountOptions() {
        getAccountOptions().then(result => {
            this.accountOptions = result.map(account => ({ label: account.Name, value: account.Id }));
        });
    }

    fetchStageOptions() {
        getStageOptions().then(result => {
            this.stageOptions = result.map(stage => ({ label: stage, value: stage }));
        });
    }

    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        this.fetchOpportunities();
    }

    fetchOpportunities() {
        getOpportunities({ accountId: this.selectedAccountId }).then(result => {
            this.opportunities = this.processOpportunities(result);
            this.calculateTotals();
        });
    }

    // Helper method to process data for the table
    processOpportunities(data) {
        return data.map(opp => {
            let stageClass = '';
            if (opp.StageName === 'Closed Lost') {
                stageClass = 'red';
            } else if (opp.StageName === 'Closed Won') {
                stageClass = 'green';
            }
            return {
                ...opp,
                stageClass: stageClass,
                isEditingAmount: false,
                isEditingStage: false,
                originalValue: {
                    Amount: opp.Amount,
                    StageName: opp.StageName
                }
            };
        });
    }

    // Totals calculation
    calculateTotals() {
        this.totalOpportunityCount = this.opportunities.length; //[cite: 5]
        this.totalAmount = this.opportunities.reduce((sum, opp) => {
            if (opp.StageName !== 'Closed Lost') {
                return sum + opp.Amount;
            }
            return sum;
        }, 0);// [cite: 7]
    }

    // Inline editing logic
    handleDoubleClick(event) {
        const { id, field } = event.currentTarget.dataset;
        this.opportunities = this.opportunities.map(opp => {
            if (opp.Id === id) {
                return { ...opp, isEditingAmount: field === 'Amount', isEditingStage: field === 'StageName' };
            }
            return opp;
        });
    }

    handleInputChange(event) {
        const { id, field } = event.currentTarget.dataset;
        const value = event.target.value;
        console.log('show all opportunites',this.opportunities);
        this.opportunities = this.opportunities.map(opp => {
            if (opp.Id === id) {
                return { ...opp, [field]: value };
            }
            return opp;
        });
        console.log('after the eddting edited values in opp',this.opportunities);

    }

    handleBlur(event) {
        const { id, field } = event.currentTarget.dataset;
        const oppToUpdate = this.opportunities.find(opp => opp.Id === id);

        if (oppToUpdate[field] !== oppToUpdate.originalValue[field]) {
            updateOpportunity({ opportunityId: id, fieldName: field, value: oppToUpdate[field] })
                .then(() => {
                    this.showToast('Success', 'Opportunity updated successfully.', 'success');// [cite: 10]
                    this.fetchOpportunities();
                })
                .catch(error => {
                    this.showToast('Error', 'An error occurred.', 'error');
                    console.error('Update error:', error);
                });
        } else {
            // No change, so do nothing [cite: 11]
            this.opportunities = this.opportunities.map(opp => {
                if (opp.Id === id) {
                    return { ...opp, isEditingAmount: false, isEditingStage: false };
                }
                return opp;
            });
        }
    }

    // Navigation and Toast message
    navigateToRecord(event) {
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId, actionName: 'view' }
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }

    showPenIcon(event) {
        const penIcon = event.currentTarget.querySelector('.pen-icon');
        if (penIcon) penIcon.classList.remove('slds-hidden');
    }

    hidePenIcon(event) {
        const penIcon = event.currentTarget.querySelector('.pen-icon');
        if (penIcon) penIcon.classList.add('slds-hidden');
    }
}