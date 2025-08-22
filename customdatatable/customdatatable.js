import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import allaccounts from '@salesforce/apex/OpportunityCreatorController.Allaccounts';
import allpricebooks from '@salesforce/apex/OpportunityCreatorController.Allpricebooks';
import getContactsByAccountId from '@salesforce/apex/OpportunityCreatorController.getContactsByAccountId';
import getProductsByPricebookId from '@salesforce/apex/OpportunityCreatorController.getProductsByPricebookId';
import createOpportunityAndLineItems from '@salesforce/apex/OpportunityCreatorController.createOpportunityAndLineItems';



export default class OpportunityCreator extends LightningElement {
    @track accountId;
    @track options; // Account options for combobox

    @track contactoptions; // Contact options for combobox
    @track contactId;

    @track pricebookoptions; // Pricebook options for combobox
    @track pricebookId;

    @track closedDate = new Date().toISOString().slice(0, 10); // Default to today's date

    @track opportunityLineItems = []; // Manages dynamic table rows
    @track availableProducts = []; // Stores products for the selected pricebook

    @wire(allaccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.options = data.map(account => {
                return {
                    label: account.Name,
                    value: account.Id
                };
            });
        } else if (error) {
            console.error('Error in loading accounts:', error);
            this.showToast('Error', 'Failed to load accounts: ' + error.body.message, 'error');
        }
    }

    // Handles account selection change
    handleComboboxChange(event) {
        this.accountId = event.detail.value;
        console.log('Selected Account ID:', this.accountId);
        this.getContacts(); // Fetch contacts for the selected account
    }

    // Fetches contacts related to the selected account
    getContacts() {
        if (!this.accountId) {
            this.contactoptions = []; // Clear contacts if no account selected
            return;
        }
        console.log('Fetching contacts for Account ID:', this.accountId);
        getContactsByAccountId({ accountId: this.accountId })
            .then(result => {
                this.contactoptions = result.map(contact => {
                    return {
                        label: contact.Name,
                        value: contact.Id
                    };
                });
                console.log('Contacts loaded:', JSON.stringify(this.contactoptions));
            })
            .catch(error => {
                console.error('Error fetching contacts:', error);
                this.showToast('Error', 'Failed to load contacts: ' + error.body.message, 'error');
                this.contactoptions = [];
            });
    }

    // Handles contact selection change
    handleContactChange(event) {
        this.contactId = event.detail.value;
        console.log('Selected Contact ID:', this.contactId);
    }

    // Wire method to fetch all pricebooks for the combobox
    @wire(allpricebooks)
    wiredpricebooks({error,data}){
        if(data){
           this.pricebookoptions = data.map(pricebook =>{
            return{
                label:pricebook.Name,
                value:pricebook.Id
            }
           })
           console.log('Pricebooks loaded:', JSON.stringify(this.pricebookoptions));
        }else if(error){
            console.error('Error getting pricebook data:', error);
            this.showToast('Error', 'Failed to load pricebooks: ' + error.body.message, 'error');
        }
    }

    
    connectedCallback() {
        if (this.opportunityLineItems.length === 0) {
            this.addRow();
        }
    }


    handlePricebookChange(event) {
        this.pricebookId = event.detail.value;
        console.log('Selected Pricebook ID:', this.pricebookId);
        this.loadProducts(); // Load products for the selected pricebook
    }

    // Handles closed date change
    handleClosedDateChange(event) {
        this.closedDate = event.detail.value;
        console.log('Closed Date:', this.closedDate);
    }

    // Fetches products based on the selected pricebook
    async loadProducts() {
        if (!this.pricebookId) {
            this.availableProducts = []; // Clear products if no pricebook is selected
            return;
        }
        try {
            const products = await getProductsByPricebookId({ pricebookId: this.pricebookId });
            this.availableProducts = products.map(product => ({
                label: product.Product2.Name,
                value: product.Id,           
                UnitPrice: product.UnitPrice, // Use PricebookEntry UnitPrice
                ListPrice: product.UnitPrice  // For simplicity, ListPrice also from PricebookEntry UnitPrice
            }));
            console.log('Available Products loaded:', JSON.stringify(this.availableProducts));

            // Update existing line items with new prices if product matches
            let updatedLineItems = this.opportunityLineItems.map(item => {
                const selectedProduct = this.availableProducts.find(prod => prod.value === item.ProductId);
                if (selectedProduct) {
                    item.UnitPrice = selectedProduct.UnitPrice;
                    item.ListPrice = selectedProduct.ListPrice;
                    item.Total = item.Quantity * item.UnitPrice;
                }
                return { ...item }; // Return new object for reactivity
            });
            this.opportunityLineItems = updatedLineItems; // Trigger re-render
        } catch (error) {
            console.error('Error fetching products:', error);
            this.showToast('Error', 'Error fetching products: ' + error.body.message, 'error');
            this.availableProducts = [];
        }
    }

    // Handles product selection change for a specific row
    handleProductChange(event) {
        console.log('dataset.index',event.target.dataset.index);
        const index = parseInt(event.target.dataset.index, 10); // Base 10 for safety
        const productId = event.detail.value;
        
        const selectedProduct = this.availableProducts.find(product => product.value === productId);

        let updatedLineItems = [...this.opportunityLineItems]; // Create a new array instance

        if (selectedProduct) {
            updatedLineItems[index].ProductId = productId;
            updatedLineItems[index].UnitPrice = selectedProduct.UnitPrice || 0;
            updatedLineItems[index].ListPrice = selectedProduct.ListPrice || 0;
            updatedLineItems[index].Total = updatedLineItems[index].Quantity * updatedLineItems[index].UnitPrice;
        } else {
            // Reset fields if product is unselected or not found
            updatedLineItems[index].ProductId = null;
            updatedLineItems[index].UnitPrice = 0;
            updatedLineItems[index].ListPrice = 0;
            updatedLineItems[index].Total = 0;
        }
        this.opportunityLineItems = updatedLineItems; // Assign new array to trigger re-render
        console.log('Product changed. Current line items:', JSON.stringify(this.opportunityLineItems[index]));
    }

    // Handles quantity change for a specific row
    handleQuantityChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const quantity = parseFloat(event.detail.value) || 0; // Ensure number, default to 0

        let updatedLineItems = [...this.opportunityLineItems];
        updatedLineItems[index].Quantity = quantity;
        updatedLineItems[index].Total = quantity * updatedLineItems[index].UnitPrice;
        this.opportunityLineItems = updatedLineItems;
        console.log('Quantity changed. Current line items:', JSON.stringify(this.opportunityLineItems[index]));
    }

    // Handles manual unit price change for a specific row
    handleUnitPriceChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const unitPrice = parseFloat(event.detail.value) || 0; // Ensure number, default to 0

        let updatedLineItems = [...this.opportunityLineItems];
        updatedLineItems[index].UnitPrice = unitPrice;
        updatedLineItems[index].Total = updatedLineItems[index].Quantity * unitPrice;
        this.opportunityLineItems = updatedLineItems;
        console.log('Unit Price changed. Current line items:', JSON.stringify(this.opportunityLineItems[index]));
    }

    // Adds a new empty row to the table
    addRow() {
        const newKey = Date.now(); // Unique key for LWC's for:each
        const newItem = {
            key: newKey,
            index: this.opportunityLineItems.length + 1, // Visual row number
            ProductId: null,
            Quantity: 1,
            UnitPrice: 0,
            ListPrice: 0,
            Total: 0
        };
        this.opportunityLineItems = [...this.opportunityLineItems, newItem];
        console.log('Row added. Current line items:', JSON.stringify(this.opportunityLineItems));
    }

    // Deletes a specific row and ensures at least one row remains
    handleDeleteRow(event) {
        console.log('delete row index',event.target.dataset.index)
        const indexToDelete = parseInt(event.target.dataset.index, 10);

        let updatedLineItems = this.opportunityLineItems.filter((item, idx) => idx !== indexToDelete);

        if (updatedLineItems.length === 0) {
            updatedLineItems.push({
                key: Date.now(),
                index: 1, // First row is always index 1
                ProductId: null,
                Quantity: 1,
                UnitPrice: 0,
                ListPrice: 0,
                Total: 0
            });
        } else {
            // Re-index the remaining items for consistent visual numbering (1, 2, 3...)
            updatedLineItems = updatedLineItems.map((item, index) => ({
                ...item,
                index: index + 1
            }));
        }
        
        this.opportunityLineItems = updatedLineItems; // Assign new array for reactivity
        console.log('Row deleted. Current line items:', JSON.stringify(this.opportunityLineItems));
    }

    // Deletes all rows and adds one new empty row
    handleDeleteAllRows() {
        this.opportunityLineItems = []; // Clear all existing rows
        this.addRow(); // Add one fresh empty row
        console.log('All rows deleted. One new row added.');
    }

    // Handles the creation of the Opportunity and its Line Items
    async handleCreateOpportunity() {
        // Basic validation for required fields
        if (!this.accountId || !this.pricebookId || !this.closedDate) {
            this.showToast('Validation Error', 'Please fill in Account, Pricebook, and Closed Date.', 'error');
            return;
        }

        // Filter for valid line items to send to Apex (must have ProductId and Quantity > 0)
        const validLineItems = this.opportunityLineItems.filter(item => item.ProductId && item.Quantity > 0);

        // Validate if there's at least one valid product line item
        if (validLineItems.length === 0) {
            this.showToast('Validation Error', 'Please select at least one product with a quantity greater than 0.', 'error');
            return;
        }

        try {
            // Call Apex method to create Opportunity and Line Items
            await createOpportunityAndLineItems({
                accountId: this.accountId,
                pricebookId: this.pricebookId,
                contactId: this.contactId, // contactId can be null if not selected
                closedDate: this.closedDate,
                lineItemsJson: JSON.stringify(validLineItems) // Send line items as JSON string
            });

            this.showToast('Success', 'Opportunity and Line Items created successfully!', 'success');
            // Reset all input fields and table state after successful creation
            this.accountId = null;
            this.pricebookId = null;
            this.contactId = null;
            this.closedDate = new Date().toISOString().slice(0, 10); // Reset to today
            this.contactoptions = []; // Clear contact options
            this.opportunityLineItems = []; // Clear all product rows
            this.availableProducts = []; // Clear available products
            this.addRow(); // Add one empty row for next input (as per requirement)
        } catch (error) {
            console.error('Error creating Opportunity:', error);
            this.showToast('Error', 'Error creating Opportunity: ' + error.body.message, 'error');
        }
    }

    // Helper method to dispatch toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}