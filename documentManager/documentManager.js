import { LightningElement, track } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentController.getDocuments';

export default class DocumentManager extends LightningElement {
    @track yearGroups = [];
    @track showModal = false;
    @track selectedRecordId = null;
    @track sortBy = 'valid_from_date__c';
    @track sortDirection = 'asc';

    @track selectedType = '';
    @track selectedActive = '';

    typeOptions = [
        { label: 'All', value: '' },
        { label: 'Aadhar', value: 'aadhar card' },
        { label: 'Pan Card', value: 'pancard' },
        { label: 'Voter ID', value: 'voterid' }
    ];

    activeOptions = [
        { label: 'All', value: '' },
        { label: 'true', value: 'true' },
        { label: 'false', value: 'false' }
    ];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Type', fieldName: 'Document_type__c' },
        { label: 'Valid From', fieldName: 'valid_from_date__c', type: 'number', sortable: true },
        { label: 'Valid To', fieldName: 'Valid_to_date__c', type: 'number', sortable: true },
        { label: 'isActive__c', fieldName: 'isActive__c', type: 'boolean' },
        { type: 'button-icon', typeAttributes: { iconName: 'utility:preview', name: 'edit', title: 'Edit', variant: 'bare' } }
    ];

    connectedCallback() {
        this.fetchData();
    }

    fetchData() {
        getDocuments().then(data => {
            this.allDocuments = data;
            this.filterDocuments();
        });
    }

    handleTypeFilter(event) {
        this.selectedType = event.detail.value;
        this.filterDocuments();
    }

    handleActiveFilter(event) {
        this.selectedActive = event.detail.value;
        this.filterDocuments();
    }

    filterDocuments() {
        let filteredList = [];

        // Step 1: Filter based on selected type and isActive
        this.allDocuments.forEach(doc => {
            if (
                (this.selectedType === '' || ((doc.Document_type__c || '').toLowerCase() === this.selectedType.toLowerCase())) &&
                (this.selectedActive === '' || String(doc.isActive__c).toLowerCase() === this.selectedActive.toLowerCase())
            ) {
                filteredList.push(doc);
            }
        });

        let groupArray = [];

        filteredList.forEach(doc => {
            let year = doc.valid_from_date__c;

            // Try to find if a group already exists for this year
            let existingGroup = groupArray.find(g => g.year === year);

            if (existingGroup) {
                existingGroup.records.push(doc);
            } else {
                groupArray.push({
                    year: year,
                    records: [doc]
                });
            }
        });

        // Step 2: Group filtered records by year
        // let groupMap = {};

        // filteredList.forEach(doc => {
        //     let year = doc.valid_from_date__c;
        //     if (!groupMap[year]) {
        //         groupMap[year] = [];
        //     }
        //     groupMap[year].push(doc);
        // });

        // // Step 3: Convert to array and sort
        // let groupArray = [];

        // Object.keys(groupMap).forEach(year => {
        //     groupArray.push({
        //         year: parseInt(year),
        //         records: groupMap[year]
        //     });
        // });

        groupArray.sort((a, b) => a.year - b.year);
        this.yearGroups = groupArray;
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.yearGroups = this.yearGroups.map(group => {
            let sorted = [...group.records].sort((a, b) => {
                let x = a[this.sortBy] || 0;
                let y = b[this.sortBy] || 0;
                return this.sortDirection === 'asc' ? x - y : y - x;
            });
            return { ...group, records: sorted };
        });
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'edit') {
            this.selectedRecordId = event.detail.row.Id;
            this.showModal = true;
        }
    }

    handleNew() {
        this.selectedRecordId = null;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    submitEdit() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess() {
        this.showModal = false;
        this.fetchData();
    }
}