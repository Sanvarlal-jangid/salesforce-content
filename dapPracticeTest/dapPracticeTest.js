import {
   LightningElement,
   track
 } from 'lwc';
 import getContacts from '@salesforce/apex/dapPracticeTest2.getContacts';
 import updateContacts from '@salesforce/apex/dapPracticeTest2.updateContacts';
 import {
   ShowToastEvent
 } from 'lightning/platformShowToastEvent';
 export default class ContactFilterAndDisplay extends LightningElement {
   @track contacts = [];
   @track columns = [];
   @track selectedFields = ['CreatedDate'];
   @track availableFields = [];
   @track filters = [{
     id: 1,
     value: '',
     condition: '',
     field: ''
   }];
   @track nextFilterId = 2;
   @track filterConjunction = 'AND';
   @track draftValues = [];
   isMultiSelect = false;
   showPills = true;
   filterConditions = [{
     label: 'Equals',
     value: '='
   }, {
     label: 'Contains',
     value: 'LIKE'
   }, {
     label: 'Starts With',
     value: 'STARTS_WITH'
   }, {
     label: 'Ends With',
     value: 'ENDS_WITH'
   }, {
     label: 'IN',
     value: 'IN'
   }];
   filterFields = [{
     label: 'First Name',
     value: 'FirstName'
   }, {
     label: 'Last Name',
     value: 'LastName'
   }, {
     label: 'Email',
     value: 'Email'
   }, {
     label: 'Phone',
     value: 'Phone'
   }, {
     label: 'Account Name',
     value: 'Account.Name'
   }, {
     label: 'Created Date',
     value: 'CreatedDate'
   }];
   conjunctionOptions = [{
     label: 'AND',
     value: 'AND'
   }, {
     label: 'OR',
     value: 'OR'
   }];
   connectedCallback() {
     this.setAvailableFields();
     this.setColumns();
     this.fetchContacts();
   }
   setAvailableFields() {
     this.availableFields = this.filterFields.map(field => ({
       label: field.label,
       value: field.value
     }));
   }
   setColumns() {
     this.columns = this.selectedFields.map(field => ({
       label: field,
       fieldName: field,
       editable: true,
       sortable: field === 'CreatedDate'
     }));
   }
   handleSelectionChange(event) {
     this.selectedFields = event.detail;
     this.setColumns();
     this.fetchContacts();
   }
   addFilterRow() {
     this.filters = [...this.filters, {
       id: this.nextFilterId++,
       value: '',
       condition: '',
       field: ''
     }];
   }
   handleInputChange(event) {
     const id = parseInt(event.target.dataset.id, 10);
     this.updateFilter(id, 'value', event.target.value);
   }
   handleConditionChange(event) {
     const id = parseInt(event.target.dataset.id, 10);
     this.updateFilter(id, 'condition', event.detail.value);
   }
   handleFieldChange(event) {
     const id = parseInt(event.target.dataset.id, 10);
     this.updateFilter(id, 'field', event.detail.value);
   }
   updateFilter(id, key, value) {
     this.filters = this.filters.map(filter => filter.id === id ? {
       ...filter,
       [key]: value
     } : filter);
   }
   handleConjunctionChange(event) {
     this.filterConjunction = event.detail.value;
     this.fetchContacts();
   }
   fetchContacts() {
     getContacts({
       selectedFields: this.selectedFields,
       filters: this.filters,
       conjunction: this.filterConjunction,
       sortBy: 'CreatedDate',
       sortDirection: 'ASC'
     }).then(data => {
       this.contacts = data;
     }).catch(error => {
       console.error('Error fetching contacts:', error);
     });
   }
   handleSave(event) {
     const updatedFields = event.detail.draftValues;
     updateContacts({
       contacts: updatedFields
     }).then(() => {
       this.dispatchEvent(new ShowToastEvent({
         title: 'Success',
         message: 'Contacts updated successfully',
         variant: 'success'
       }));
       this.draftValues = [];
       this.fetchContacts();
     }).catch(error => {
       this.dispatchEvent(new ShowToastEvent({
         title: 'Error',
         message: 'Update failed',
         variant: 'error'
       }));
     });
   }
 }