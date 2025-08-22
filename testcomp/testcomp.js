import { LightningElement, api, wire, track } from 'lwc';
import getPicklistValues from '@salesforce/apex/OpportunityControllerTest.getPicklistValues';
import getOpportunities from '@salesforce/apex/OpportunityControllerTest.getOpportunities';
import getFieldSetFields from '@salesforce/apex/OpportunityControllerTest.getFieldSetFields';
import updateOpportunities from '@salesforce/apex/OpportunityControllerTest.updateOpportunities';
import createOpportunity from '@salesforce/apex/OpportunityControllerTest.createOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import leadSource from "@salesforce/schema/Opportunity.LeadSource";

export default class OpportunityDisplayWithPicklistTabs extends NavigationMixin(LightningElement) {
    @api picklistFieldApiName; // Public property to pass the picklist field API name
    @api fieldSetName; // Public property to pass the field set name

    @track picklistValues = [];
    @track selectedTab = 'All Opportunities'; // Default selected tab
    @track opportunities = [];
    @track columns = [];
    @track error;
    @track showModal = false;
    @track newOpportunity = {};
    @track newOpportunityPicklistValue = '';

    // For inline editing
    draftValues = [];

    // For sorting
    sortedBy;
    sortedDirection = 'asc';

    // Wire method to get picklist values
    @wire(getPicklistValues, { objectApiName: 'Opportunity', fieldApiName: '$picklistFieldApiName' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.picklistValues = [];
            this.showToast('Error', this.error, 'error');
        }
    }

    // Wire method to get field set fields
    @wire(getFieldSetFields, { objectApiName: 'Opportunity', fieldSetName: '$fieldSetName' })
    wiredFieldSetFields({ error, data }) {
        if (data) {
            this.columns = data.map(fieldName => {
                let column = {
                    label: this.getLabelFromFieldName(fieldName), // Helper to get a nice label
                    fieldName: fieldName,
                    type: this.getTypeFromFieldName(fieldName), // Helper to determine type
                    editable: true, // Assuming all fields in field set are editable
                    sortable: true
                };
                if (fieldName === 'Name') { // Make Name a hyperlink
                    column.type = 'url';
                    column.typeAttributes = {
                        label: { fieldName: 'Name' },
                        target: '_blank',
                        tooltip: 'Click to view record'
                    };
                    column.fieldName = 'NameUrl'; // A custom field for the URL
                }
                return column;
            });
            // Add Id column if not present and ensure Name is present for navigation
            const idColumnExists = this.columns.some(col => col.fieldName === 'Id');
            if (!idColumnExists) {
                 this.columns.unshift({ label: 'Id', fieldName: 'Id', type: 'text', editable: false, sortable: false });
            }
            const nameColumnExists = this.columns.some(col => col.fieldName === 'Name' || col.fieldName === 'NameUrl');
            if (!nameColumnExists) {
                this.columns.unshift({
                    label: 'Opportunity Name',
                    fieldName: 'NameUrl',
                    type: 'url',
                    typeAttributes: {
                        label: { fieldName: 'Name' },
                        target: '_blank',
                        tooltip: 'Click to view record'
                    },
                    editable: true,
                    sortable: true
                });
            }


            this.error = undefined;
            this.loadOpportunities();
        } else if (error) {
            this.error = error.body.message;
            this.columns = [];
            this.showToast('Error', this.error, 'error');
        }
    }

    // Imperative call to get opportunities
    loadOpportunities() {
        this.opportunities = []; // Clear existing data
        this.error = undefined;
        getOpportunities({
            picklistFieldApiName: this.picklistFieldApiName,
            picklistValue: this.selectedTab,
            fieldSetFields: this.columns.map(col => col.fieldName === 'NameUrl' ? 'Name' : col.fieldName) // Pass original field names
        })
        .then(result => {
            this.opportunities = result.map(opp => ({
                ...opp,
                NameUrl: `/lightning/r/Opportunity/${opp.Id}/view` // Construct the URL for the Name field
            }));
            this.error = undefined;
        })
        .catch(error => {
            this.error = error.body.message;
            this.opportunities = [];
            this.showToast('Error', this.error, 'error');
        });
    }

    handleTabClick(event) {
        this.selectedTab = event.target.dataset.value;
        this.loadOpportunities();
    }

    get allOpportunitiesSelected() {
        return this.selectedTab === 'All Opportunities';
    }

    handleRefresh() {
        this.loadOpportunities();
        this.showToast('Success', 'Opportunities refreshed!', 'success');
    }

    handleAddOpportunity() {
        this.newOpportunity = {}; // Reset for new entry
       // this.newOpportunityPicklistValue = this.selectedTab === 'All Opportunities' ? '' : this.selectedTab; // Prefill if not 'All'
        this.showModal = true;
    }

    handleCancelModal() {
        this.showModal = false;
        this.newOpportunity = {};
        this.newOpportunityPicklistValue = '';
    }

    handleNewOpportunityChange(event) {
        this.newOpportunity = { ...this.newOpportunity, [event.target.fieldName]: event.target.value };
    }

    handleNewOpportunityPicklistChange(event) {
        this.newOpportunityPicklistValue = event.target.value;
        this.newOpportunity = { ...this.newOpportunity, [this.picklistFieldApiName]: event.target.value };
    }

    handleSaveNewOpportunity() {
        if (!this.newOpportunity.Name || !this.newOpportunityPicklistValue) {
            this.showToast('Error', 'Opportunity Name and the picklist field are required.', 'error');
            return;
        }

        // Ensure the picklist field is set on the newOpportunity object
        this.newOpportunity[this.picklistFieldApiName] = this.newOpportunityPicklistValue;

        createOpportunity({ newOpportunity: this.newOpportunity })
            .then(() => {
                this.showToast('Success', 'Opportunity created successfully!', 'success');
                this.showModal = false;
                this.loadOpportunities(); // Refresh the list
            })
            .catch(error => {
                this.error = error.body.message;
                this.showToast('Error', 'Error creating opportunity: ' + this.error, 'error');
            });
    }

    handleSave(event) {
        this.draftValues = event.detail.draftValues;
        const recordInputs = this.draftValues.map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Ensure Id is present for update
        const opportunitiesToUpdate = recordInputs.map(recordInput => ({
            Id: recordInput.fields.Id,
            ...recordInput.fields
        }));

        updateOpportunities({ opportunitiesToUpdate })
            .then(() => {
                this.showToast('Success', 'Opportunities updated successfully!', 'success');
                this.draftValues = [];
                this.loadOpportunities(); // Refresh the list
            })
            .catch(error => {
                this.error = error.body.message;
                this.showToast('Error', 'Error updating opportunities: ' + this.error, 'error');
            });
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        this.sortData(sortedBy, sortDirection);
    }

    sortData(fieldName, sortDirection) {
        let parseData = JSON.parse(JSON.stringify(this.opportunities));
        let keyValue = (a) => {
            if (fieldName === 'NameUrl') {
                return a['Name']; // Sort by the actual Name field for the URL column
            }
            return a[fieldName];
        };

        let isReverse = sortDirection === 'asc' ? 1 : -1;

        // Sort the data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // Handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // Convert to lowercase for case-insensitive sorting if strings
            if (typeof x === 'string' && typeof y === 'string') {
                x = x.toLowerCase();
                y = y.toLowerCase();
            }

            return isReverse * ((x > y) - (y > x));
        });
        this.opportunities = parseData;
    }

    // Helper to get a nicer label for the column header
    getLabelFromFieldName(fieldName) {
        // You'd ideally fetch field labels from schema, but for a quick example:
        return fieldName.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
    }

    // Helper to determine column type based on field name (can be more robust using schema)
    getTypeFromFieldName(fieldName) {
        if (fieldName.includes('Date')) {
            return 'date';
        } else if (fieldName.includes('Quantity') || fieldName.includes('Amount')) {
            return 'number';
        }
        return 'text';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}