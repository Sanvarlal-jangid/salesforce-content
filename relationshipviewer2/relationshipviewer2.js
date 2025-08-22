import { LightningElement, api, wire, track } from 'lwc';
import getRelatedRecords from '@salesforce/apex/RelationshipViewerController.getRelatedRecords';
import { NavigationMixin } from 'lightning/navigation';

export default class RelationshipViewer extends NavigationMixin(LightningElement) {
    @api recordId;
    @track relatedData = [];
    @track activeSections = [];

    @wire(getRelatedRecords, { recordId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.relatedData = Object.keys(data).map(key => ({
                key,
                records: data[key]
            }));
        } else if (error) {
            console.error('Error fetching related records:', error);
        }
    }

    handleExpandAll() {
        this.activeSections = this.relatedData.map(section => section.key);
    }

    handleViewAll(event) {
        const objectApiName = event.target.dataset.object;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName,
                actionName: 'list'
            }
        });
    }

    handleNew(event) {
        const objectApiName = event.target.dataset.object;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName,
                actionName: 'new'
            }
        });
    }

    handleEdit(event) {
        const recordId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'edit'
            }
        });
    }

    handleCopyLink(event) {
        const recordId = event.target.dataset.id;
        const link = window.location.origin + '/' + recordId;
        navigator.clipboard.writeText(link).then(() => {
            console.log('Copied to clipboard:', link);
        });
    }
}