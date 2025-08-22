import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRealState from '@salesforce/apex/practicepaper3.getRealState';
import getcontact from '@salesforce/apex/practicepaper3.getcontact';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class RealEstateApp extends NavigationMixin(LightningElement) {
    data = [];
    columns = [
        {
            label: 'Image',
            type: "customImage",
            typeAttributes: {
                url: { fieldName: "url" }
            }
        },
        { label: 'Address', fieldName: 'Address__c' },
        { label: 'City', fieldName: 'City__c' },
        { label: 'State', fieldName: 'State__c' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View Contact', name: 'view' },
                    { label: 'Add Contact', name: 'create' }
                ]
            }
        }
    ];

    showViewModal = false;
    showAddContactModal = false;
    selectedRecordId;
    realstate;
    con;

    @wire(getRealState)
    getdata({ data, error }) {
        if (data) {
            this.data = data.map(ele => {
                return {
                    ...ele,
                    url: this.extractImageUrl(ele.Image__c)
                };
            });
        } else if (error) {
            console.error('Error fetching real estate data', error);
        }
    }

    extractImageUrl(htmlString) {
        if (!htmlString) return null;
        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlString, 'text/html');
        const imgElement = doc.querySelector('img');
        return imgElement ? imgElement.src : null;
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        this.realstate = row.Id;

        if (action === 'view') {
            getcontact({ contid: this.realstate })
                .then(result => {
                    this.con = result;
                    this.selectedRecordId = result.Id;
                    this.showViewModal = true;
                })
                .catch(error => {
                    console.error('Error fetching contact', error);
                });

        } else if (action === 'create') {
            this.navigateToNewContactWithDefaults();
          // this is done extra with the help of record edit form
            //this.showAddContactModal = true;
        }
    }

    navigateToNewContactWithDefaults() {
        const defaultValues = {
            RealState__c: this.realstate
        };
        const encodedDefaultValues = encodeDefaultFieldValues(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: encodedDefaultValues
            }
        });
    }

    closeModal() {
        this.showViewModal = false;
    }

    closeAddContactModal() {
        this.showAddContactModal = false;
    }

    handleContactSuccess() {
        this.showAddContactModal = false;
    }

    createProperty() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Real_Estate__c',
                actionName: 'new'
            }
        });
    }
}