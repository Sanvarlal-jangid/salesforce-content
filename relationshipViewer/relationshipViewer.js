import { LightningElement, api, wire, track } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class AccordionRelatedLists extends LightningElement {
    @api recordId;

    @track activeSections = [];
    toggleLabel = 'Expand All';

    @track relatedLists = [
        {   
            label: 'Contacts',
            name: 'contacts',
            records: [],
            fields: ['Id', 'Name', 'Email'],
            wireFields: ['Contact.Id', 'Contact.Name', 'Contact.Email'],
            sortBy: ['Contact.Name']
        },
        {
            label: 'Opportunities',
            name: 'opportunities',
            records: [],
            fields: ['Id', 'Name', 'StageName'],
            wireFields: ['Opportunity.Id', 'Opportunity.Name', 'Opportunity.StageName'],
            sortBy: ['Opportunity.CloseDate']
        },
        {
            label: 'Cases',
            name: 'cases',
            records: [],
            fields: ['Id', 'Subject', 'Status'],
            wireFields: ['Case.Id', 'Case.Subject', 'Case.Status'],
            sortBy: ['Case.CreatedDate']
        },
        {
            label: 'Orderr',
            name: 'orderr',
            records: [],
            fields: ['Id', 'OrderNumber', 'Status'],
            wireFields: ['Order.Id', 'Order.OrderNumber', 'Order.Status'],
            sortBy: ['Order.CreatedDate']
        },
        {
            label: 'Notes',
            name: 'notes',
            records: [],
            fields: ['Id', 'Title', 'Body'],
            wireFields: ['Note.Id', 'Note.Title', 'Note.Body'],
            sortBy: ['Note.LastModifiedDate']
        }
    ];

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Contacts',
        fields: ['Contact.Id', 'Contact.Name', 'Contact.Email'],
        sortBy: ['Contact.Name']
    })
    wiredContacts({ error, data }) {
        console.log('contact k records print krna h',data);
        this.updateRecords('contacts', data);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Opportunities',
        fields: ['Opportunity.Id', 'Opportunity.Name', 'Opportunity.StageName'],
        sortBy: ['Opportunity.CloseDate']
    })
    wiredOpportunities({ error, data }) {
        this.updateRecords('opportunities', data);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Cases',
        fields: ['Case.Id', 'Case.Subject', 'Case.Status'],
        sortBy: ['Case.CreatedDate']
    })
    wiredCases({ error, data }) {
        this.updateRecords('cases', data);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Orderr',
        fields: ['Order.Id', 'Order.OrderNumber', 'Order.Status'],
        sortBy: ['Order.CreatedDate']
    })
    wiredOrderr({ error, data }) {
        this.updateRecords('orderr', data);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Notes',
        fields: ['Note.Id', 'Note.Title', 'Note.Body'],
        sortBy: ['Note.LastModifiedDate']
    })
    wiredNotes({ error, data }) {
        this.updateRecords('notes', data);
    }

    updateRecords(listName, data) {
        const index = this.relatedLists.findIndex(list => list.name === listName);
        if (index !== -1) {
            this.relatedLists[index].records = data ? data.records : [];
        }
    }
   


    toggleAllSections() {
        const shouldExpand = this.toggleLabel === 'Expand All';
        this.activeSections = shouldExpand ? this.relatedLists.map(list => list.name) : [];
        this.toggleLabel = shouldExpand ? 'Collapse All' : 'Expand All';
        console.log('cliced toggle');
        try{
             console.log('printting evrything',this.relatedLists);
        }catch(error){
            console.log('printing errror',error);
        }
       
    }
}