import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getopportunityAll from '@salesforce/apex/kanbandraganddrop.getopportunityAll';
import updateoppStatus from '@salesforce/apex/kanbandraganddrop.updateoppStatus';

export default class Kanbandraganddrop extends NavigationMixin(LightningElement) {
    // Track lists for each stage
    @track prospectingList = [];
    @track qualificationList = [];
    @track proposalList = [];
    @track closedWonList = [];
    @track closedLostList = [];

    // Map the internal list names to their corresponding API StageName values
    stageMap = {
        'prospectingList': 'Prospecting',
        'qualificationList': 'Qualification',
        'proposalList': 'Proposal/Price Quote',
        'closedWonList': 'Closed Won',
        'closedLostList': 'Closed Lost'
    };

    // Track the current offset for each internal list name (e.g., 'prospectingList')
    @track offsets = {
        prospectingList: 0,
        qualificationList: 0,
        proposalList: 0,
        closedWonList: 0,
        closedLostList: 0
    };

    // Track if all records for a stage have been loaded for each internal list name
    @track allDone = {
        prospectingList: false,
        qualificationList: false,
        proposalList: false,
        closedWonList: false,
        closedLostList: false
    };

    // Keep track of loading state for each internal list name
    @track isLoading = {
        prospectingList: false,
        qualificationList: false,
        proposalList: false,
        closedWonList: false,
        closedLostList: false
    };

    // Initial batch size when component loads
    INITIAL_BATCH_SIZE = 5;
    // Subsequent batch size on scroll
    SCROLL_BATCH_SIZE = 3;

    connectedCallback() {
        // Initial load for each stage
        this.loadMoreData('prospectingList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('qualificationList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('proposalList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('closedWonList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('closedLostList', this.INITIAL_BATCH_SIZE);
    }

    // This method fetches data for a specific list (e.g., 'prospectingList') with pagination
    loadMoreData(listName, batchSize) {
        

        // Prevent loading if all data is already loaded or if a load is in progress for this list
        if (this.allDone[listName] || this.isLoading[listName]) {
            return;
        }

        this.isLoading[listName] = true;

        const currentOffset = this.offsets[listName];
        const limitSize = batchSize;
        // Get the actual API StageName from our map
        const stageName = this.stageMap[listName];

        getopportunityAll({ stageName: stageName, offset: currentOffset, limitSize: limitSize })
            .then(result => {
                if (result && result.length > 0) {
                    // Append new data to the existing list
                    this[listName] = [...this[listName], ...result];
                    this.offsets[listName] += result.length; // Update the offset
                    if (result.length < limitSize) {
                        this.allDone[listName] = true; // Mark as done if less than batch size is returned
                    }
                } else {
                    this.allDone[listName] = true; // No more data to load
                }
            })
            .catch(error => {
                console.error('Error loading data for ' + stageName + ':', error);
                this.showToast('Error', 'Error loading opportunities for ' + stageName, 'error');
            })
            .finally(() => {
                this.isLoading[listName] = false; // Reset loading state for this specific list
            });
    }

    handleScroll(event) {
        
        const listName = event.currentTarget.dataset.id; // e.g., "Prospecting" -> "prospectingList"
        const el = event.target;

        // Check if the user has scrolled near the bottom (e.g., within 10 pixels)
        if (el.scrollTop + el.clientHeight >= el.scrollHeight - 10) {
            // Load subsequent data with the scroll batch size
            this.loadMoreData(listName, this.SCROLL_BATCH_SIZE);
        }
    }

    taskDragStart(event) {
        const taskId = event.target.dataset.id;
        event.dataTransfer.setData('text/plain', taskId);
    }

    handleDrop(event) {
        this.cancel(event);

        const taskId = event.dataTransfer.getData('text/plain');
        const columnDataId = event.currentTarget.dataset.id; // e.g., "Prospecting", "Proposal"

        let taskNewStatus;
        // Map the HTML data-id to the actual API StageName value
        if (columnDataId === 'prospectingList') {
            taskNewStatus = 'Prospecting';
        } else if (columnDataId === 'qualificationList') {
            taskNewStatus = 'Qualification';
        } else if (columnDataId === 'proposalList') {
            taskNewStatus = 'Proposal/Price Quote'; // Correct API name
        } else if (columnDataId === 'closedWonList') {
            taskNewStatus = 'Closed Won'; // Correct API name
        } else if (columnDataId === 'CloclosedLostListsedLost') {
            taskNewStatus = 'Closed Lost'; // Correct API name
        }

        updateoppStatus({ taskId, taskNewStatus })
            .then(() => {
                this.showToast('Success', 'Record updated successfully!', 'success');
                // Reset and reload all data to reflect the change.
                this.resetAllDataAndLoad();
                console.log('reset all data is called');
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error updating record: ' + this.getErrorMessage(error), 'error');
            });

        // Remove the 'over' class from all drop targets
        const dropTargets = this.template.querySelectorAll('[data-role="drop-target"]');
        dropTargets.forEach(target => target.classList.remove('over'));
    }

    handleDragEnter(event) {
        this.cancel(event);
    }

    handleDragOver(event) {
        this.cancel(event);
        event.currentTarget.classList.add('over');
    }

    handleDragLeave(event) {
        this.cancel(event);
        event.currentTarget.classList.remove('over');
    }

    cancel(event) {
        if (event.stopPropagation) event.stopPropagation();
        if (event.preventDefault) event.preventDefault();
        return false;
    }

    handleEditClick(event) {
        let recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Opportunity',
                actionName: 'edit'
            }
        });
    }

    handledeleteClick(event) {
        let selectedid = event.currentTarget.dataset.id;

        deleteRecord(selectedid)
            .then(() => {
                this.showToast('Success', 'Record deleted successfully!', 'success');
                // Refresh all data after deletion
                this.resetAllDataAndLoad();
            })
            .catch(error => {
                this.showToast('Error', 'Error deleting record: ' + this.getErrorMessage(error), 'error');
            });
    }

    // Helper to show toasts
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    // Helper to extract error message
    getErrorMessage(error) {
        let message = 'Unknown error';
        if (error && error.body && error.body.message) {
            message = error.body.message;
        } else if (typeof error === 'string') {
            message = error;
        }
        return message;
    }

    // Resets all data and reloads from scratch
    resetAllDataAndLoad() {
        // Clear all lists
        this.prospectingList = [];
        this.qualificationList = [];
        this.proposalList = [];
        this.closedWonList = [];
        this.closedLostList = [];

        for (const key in this.offsets) {
            this.offsets[key] = 0;
            this.allDone[key] = false;
            this.isLoading[key] = false;
        }

        // Re-initiate initial data loading for all stages
        this.loadMoreData('prospectingList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('qualificationList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('proposalList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('closedWonList', this.INITIAL_BATCH_SIZE);
        this.loadMoreData('closedLostList', this.INITIAL_BATCH_SIZE);
    }

    // === Getters for simpler HTML access ===
    get isLoadingProspecting() {
        return this.isLoading.prospectingList;
    }
    get allDoneProspecting() {
        return this.allDone.prospectingList;
    }

    get isLoadingQualification() {
        return this.isLoading.qualificationList;
    }
    get allDoneQualification() {
        return this.allDone.qualificationList;
    }

    get isLoadingProposal() {
        return this.isLoading.proposalList;
    }
    get allDoneProposal() {
        return this.allDone.proposalList;
    }

    get isLoadingClosedWon() {
        return this.isLoading.closedWonList;
    }
    get allDoneClosedWon() {
        return this.allDone.closedWonList;
    }

    get isLoadingClosedLost() {
        return this.isLoading.closedLostList;
    }
    get allDoneClosedLost() {
        return this.allDone.closedLostList;
    }
}