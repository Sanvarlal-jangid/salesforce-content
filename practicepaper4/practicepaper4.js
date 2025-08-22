/**
 * @description JavaScript for the OpportunityCreator LWC.
 * Handles component logic, data binding, user interactions,
 * and calls to the Apex controller.
 * All validation and opportunity name generation are handled here.
 */
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccounts from '@salesforce/apex/OpportunityCreatorController.getAccounts';
import getContactsByAccountId from '@salesforce/apex/OpportunityCreatorController.getContactsByAccountId';
import getPricebooks from '@salesforce/apex/OpportunityCreatorController.getPricebooks';
import getProductsByPricebookId from '@salesforce/apex/OpportunityCreatorController.getProductsByPricebookId';
import createOpportunityAndLineItems from '@salesforce/apex/OpportunityCreatorController.createOpportunityAndLineItems';

export default class OpportunityCreator extends LightningElement {
    // Reactive properties for dropdown selections
    @track selectedAccountId = '';
    @track selectedPricebookId = '';
    @track selectedContactId = '';
    @track closedDate = new Date().toISOString().slice(0, 10); // Default to today's date

    // Reactive properties for displaying contact details
    @track contactEmail = '';
    @track contactPhone = '';
    @track contactFax = '';

    // Data for dropdown options
    @track accountOptions = [];
    @track contactOptions = [];
    @track pricebookOptions = [];
    @track productOptions = []; // Products for the selected pricebook

    // Array to hold opportunity line items
    @track opportunityLineItems = [];

    // Store raw product data (Id, Name, UnitPrice, ListPrice) for calculations
    @track allProductsData = [];

    // Store the name of the selected account for opportunity naming
    @track selectedAccountName = '';

    // --- Wired Apex Calls for initial data ---

    // Wire to get all Accounts
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data;
        } else if (error) {
            this.showToast('Error', 'Error loading accounts: ' + error.body.message, 'error');
            console.error('Error loading accounts', error);
        }
    }

    // Wire to get all Pricebooks
    @wire(getPricebooks)
    wiredPricebooks({ error, data }) {
        if (data) {
            this.pricebookOptions = data;
        } else if (error) {
            this.showToast('Error', 'Error loading pricebooks: ' + error.body.message, 'error');
            console.error('Error loading pricebooks', error);
        }
    }

    // --- Getters for UI state ---

    get isContactDisabled() {
        return !this.selectedAccountId;
    }

    get isProductDisabled() {
        return !this.selectedPricebookId;
    }

    // Helper for numbering rows
    get idx_plus_one() {
        return this.opportunityLineItems.map((item, index) => ({ ...item, idx_plus_one: index + 1 }));
    }

    // --- Event Handlers for User Input ---

    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        // Get the selected account's name for opportunity naming
        const selectedAccount = this.accountOptions.find(acc => acc.value === this.selectedAccountId);
        this.selectedAccountName = selectedAccount ? selectedAccount.label : '';

        // Reset contact and line items when account changes
        this.selectedContactId = '';
        this.contactEmail = '';
        this.contactPhone = '';
        this.contactFax = '';
        this.contactOptions = [{ label: 'Select an Option', value: '' }]; // Reset contact options
        this.opportunityLineItems = []; // Clear line items

        if (this.selectedAccountId) {
            this.loadContacts();
        }
    }

    handlePricebookChange(event) {
        this.selectedPricebookId = event.detail.value;
        this.opportunityLineItems = []; // Clear line items when pricebook changes
        this.productOptions = [{ label: 'Select Product', value: '' }]; // Reset product options
        this.allProductsData = []; // Clear raw product data

        if (this.selectedPricebookId) {
            this.loadProducts();
        }
    }

    handleContactChange(event) {
        this.selectedContactId = event.detail.value;
        // Find the selected contact to display its details
        const selectedContact = this.contactOptions.find(contact => contact.value === this.selectedContactId);
        if (selectedContact) {
            this.contactEmail = selectedContact.email || '';
            this.contactPhone = selectedContact.phone || '';
            this.contactFax = selectedContact.fax || '';
        } else {
            this.contactEmail = '';
            this.contactPhone = '';
            this.contactFax = '';
        }
    }

    handleClosedDateChange(event) {
        this.closedDate = event.detail.value;
    }

    // --- Imperative Apex Calls (called on demand) ---

    async loadContacts() {
        try {
            const data = await getContactsByAccountId({ accountId: this.selectedAccountId });
            this.contactOptions = data;
        } catch (error) {
            this.showToast('Error', 'Error loading contacts: ' + error.body.message, 'error');
            console.error('Error loading contacts', error);
        }
    }

    async loadProducts() {
        try {
            const data = await getProductsByPricebookId({ pricebookId: this.selectedPricebookId });
            this.allProductsData = data; // Store raw data for calculations
            this.productOptions = [{ label: 'Select Product', value: '' }]; // Add default option
            data.forEach(product => {
                this.productOptions.push({ label: product.name, value: product.id });
            });
        } catch (error) {
            this.showToast('Error', 'Error loading products: ' + error.body.message, 'error');
            console.error('Error loading products', error);
        }
    }

    // --- Opportunity Line Item Management ---

    handleAddRow() {
        this.opportunityLineItems = [
            ...this.opportunityLineItems,
            {
                id: Date.now(), // Unique ID for the row (for reactivity)
                productId: '',
                quantity: 0,
                unitPrice: 0,
                listPrice: 0, // List Price is for display, not sent to Apex for OLI creation
                total: 0,
            },
        ];
    }

    handleDeleteRow(event, rowId) {
        this.opportunityLineItems = this.opportunityLineItems.filter(item => item.id !== rowId);
    }

    handleDeleteAllRows() {
        this.opportunityLineItems = [];
    }

    handleLineItemChange(event, rowId) {
        const { name, value } = event.detail;
        const updatedLineItems = this.opportunityLineItems.map(item => {
            if (item.id === rowId) {
                let updatedItem = { ...item, [name]: value };

                if (name === 'productId') {
                    const selectedProduct = this.allProductsData.find(p => p.id === value);
                    if (selectedProduct) {
                        updatedItem.unitPrice = selectedProduct.unitPrice;
                        updatedItem.listPrice = selectedProduct.listPrice;
                        updatedItem.quantity = 1; // Default quantity to 1 when product is selected
                    } else {
                        updatedItem.unitPrice = 0;
                        updatedItem.listPrice = 0;
                        updatedItem.quantity = 0;
                    }
                }

                // Recalculate total if quantity or product changes
                if (name === 'quantity' || name === 'productId') {
                    // Ensure quantity is a number
                    const qty = parseFloat(updatedItem.quantity) || 0;
                    updatedItem.total = qty * updatedItem.unitPrice;
                }
                return updatedItem;
            }
            return item;
        });
        this.opportunityLineItems = updatedLineItems;
    }

    // --- Create Opportunity ---

    async handleCreateOpportunity() {
        // Client-side validation
        const allValid = [...this.template.querySelectorAll('lightning-combobox, lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            this.showToast('Validation Error', 'Please fill in all required fields.', 'error');
            return;
        }

        if (this.opportunityLineItems.length === 0) {
            this.showToast('Validation Error', 'Please add at least one Opportunity Line Item.', 'error');
            return;
        }

        // Validate each line item for product selection and quantity
        const invalidLineItems = this.opportunityLineItems.some(item =>
            !item.productId || parseFloat(item.quantity) <= 0
        );

        if (invalidLineItems) {
            this.showToast('Validation Error', 'Please ensure all line items have a selected Product and a quantity greater than 0.', 'error');
            return;
        }

        // Generate Opportunity Name in JS
        const oppName = `Opportunity for ${this.selectedAccountName} - ${this.closedDate}`;

        // Prepare line items for Apex (only send necessary fields)
        const lineItemsToSend = this.opportunityLineItems.map(item => ({
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice, // This is the sales price
        }));

        try {
            const opportunityId = await createOpportunityAndLineItems({
                opportunityName: oppName, // Pass the generated name
                accountId: this.selectedAccountId,
                contactId: this.selectedContactId,
                pricebookId: this.selectedPricebookId,
                closedDate: this.closedDate,
                lineItems: lineItemsToSend,
            });

            this.showToast('Success', `Opportunity created with Id: ${opportunityId}`, 'success');
            this.resetForm(); // Reset form after successful creation

        } catch (error) {
            this.showToast('Error', 'Error creating Opportunity: ' + error.body.message, 'error');
            console.error('Error creating Opportunity', error);
        }
    }

    // --- Utility Methods ---

    resetForm() {
        this.selectedAccountId = '';
        this.selectedPricebookId = '';
        this.selectedContactId = '';
        this.closedDate = new Date().toISOString().slice(0, 10);
        this.contactEmail = '';
        this.contactPhone = '';
        this.contactFax = '';
        this.selectedAccountName = ''; // Reset account name

        // Reset options for comboboxes that are dynamically loaded
        this.contactOptions = [{ label: 'Select an Option', value: '' }];
        this.productOptions = [{ label: 'Select Product', value: '' }];
        this.allProductsData = [];
        this.opportunityLineItems = [];
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissible' // Allows user to dismiss the toast
        });
        this.dispatchEvent(event);
    }
}
