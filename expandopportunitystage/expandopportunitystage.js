import { LightningElement, wire, track } from 'lwc';
import getAllOpportunities from '@salesforce/apex/expandopportunitystage.getAllOpportunities';
import updateOpportunity from '@salesforce/apex/expandopportunitystage.updateOpportunity';
import deleteOpportunity from '@salesforce/apex/expandopportunitystage.deleteOpportunity';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Expandopportunitystage extends LightningElement {

    @track opportunityMap = {};  
    @track allStageNames = [];   
    @track expandedStageMap = {};
    @track isModalOpen = false; 
    @track editRecordData = {};

    wiredResult;


    @wire(getAllOpportunities)
    wiredOpps(result) {
        this.wiredResult = result; 
        if (result.data) {
            console.log('Opportunities fetched successfully:', result.data);
            this.processOpportunities(result.data); 
        } else if (result.error) {
            console.error('Error fetching opportunities:', result.error);
            this.showToast('Error', 'Failed to load opportunities: ' + this.getErrorMessage(result.error), 'error');
        }
    }

    
    processOpportunities(opps) {
        let tempMap = {};

 
        opps.forEach(opportunity => {
            if (!tempMap[opportunity.StageName]) {
                tempMap[opportunity.StageName] = [];
            }
            tempMap[opportunity.StageName].push(opportunity);
        });
        
        console.log('Opportunities grouped by stage (before sort/slice):', tempMap);


        for (let stageName in tempMap) {
            tempMap[stageName].sort((a, b) => b.Amount - a.Amount);
            tempMap[stageName] = tempMap[stageName].slice(0, 5);
        }

        this.opportunityMap = tempMap; 
        
        this.allStageNames = Object.keys(tempMap);
        
        let newExpandedStageMap = {};
        this.allStageNames.forEach(stage => {
            newExpandedStageMap[stage] = false; // Set initial state to 'closed'
        });
        this.expandedStageMap = newExpandedStageMap; // Update reactive property
        
        console.log('Final opportunityMap:', JSON.parse(JSON.stringify(this.opportunityMap)));
        console.log('Initial expandedStageMap:', JSON.parse(JSON.stringify(this.expandedStageMap)));
    }
    
  
    get displayStages() {
     
        return this.allStageNames.map(stageName => {
            return {
                name: stageName, // The name of the stage (e.g., 'Prospecting')
                isExpanded: this.expandedStageMap[stageName], // True if this stage should be open, false otherwise
                opportunities: this.opportunityMap[stageName] // The list of opportunities for this stage
            };
        });
    }

   
    toggleStage(event) {
        // Get the stage name from the 'data-stage' attribute on the clicked element
        const clickedStage = event.currentTarget.dataset.stage;
        console.log('Stage clicked:', clickedStage);

        let tempExpandedMap = {}; 

      
        this.allStageNames.forEach(stageName => {
            if (stageName === clickedStage) {
           
                tempExpandedMap[stageName] = !this.expandedStageMap[stageName];
            } else {
                // For all other stages, make sure they are closed (false)
                tempExpandedMap[stageName] = false;
            }
        });

        // Update the reactive property. This causes LWC to re-render the HTML.
        this.expandedStageMap = tempExpandedMap; 
        console.log('Updated expandedStageMap (single expansion logic):', JSON.parse(JSON.stringify(this.expandedStageMap)));
    }

    
    editRecord(event) {
        const opportunityId = event.currentTarget.dataset.id; // Get the Id from the button's data-id
        let opportunityToEdit = null;

        // Find the opportunity in our map using its Id
        for (let stageName of this.allStageNames) {
            opportunityToEdit = this.opportunityMap[stageName].find(
                opp => opp.Id === opportunityId
            );
            if (opportunityToEdit) {
                break; // Found it, no need to search further
            }
        }
        
     
        this.editRecordData = { ...opportunityToEdit }; 
        this.isModalOpen = true; 
    }

    handleInputChange(event) {
        const fieldName = event.target.dataset.field; // 'Name' or 'Amount'
        const value = event.target.value;

       
        this.editRecordData = {
            ...this.editRecordData,
            [fieldName]: value      
        };
    }

    
    saveRecord() {
        updateOpportunity({ opp: this.editRecordData })
            .then(response => {
                console.log('Update response:', response);
                this.showToast('Success', 'Opportunity updated successfully!', 'success');
                this.isModalOpen = false; // Close the modal
                return refreshApex(this.wiredResult); 
            })
            .catch(error => {
                console.error('Error updating opportunity:', error);
                this.showToast('Error', 'Failed to update opportunity: ' + this.getErrorMessage(error), 'error');
            });
    }

    deleteRecord(event) {
        const opportunityId = event.currentTarget.dataset.id; // Get the Id of the opportunity to delete

    
        if (!confirm('Are you sure you want to delete this opportunity?')) {
            return; // User clicked Cancel
        }

        deleteOpportunity({ oppId: opportunityId })
            .then(response => {
                console.log('Delete response:', response);
                this.showToast('Deleted', 'Opportunity deleted successfully!', 'success');
                
                return refreshApex(this.wiredResult); 
            })
            .catch(error => {
                console.error('Error deleting opportunity:', error);
                this.showToast('Error', 'Failed to delete opportunity: ' + this.getErrorMessage(error), 'error');
            });
    }

    
    closeModal() {
        this.isModalOpen = false;
    }

    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

   
    getErrorMessage(error) {
        let message = 'An unknown error occurred.';
        if (error) {

            if (error.body && Array.isArray(error.body.output?.errors) && error.body.output.errors.length > 0) {
                message = error.body.output.errors[0].message;
            } 
            // Check for general Apex exceptions (AuraHandledException)
            else if (error.body && error.body.message) {
                message = error.body.message;
            } 
            // Check for raw string error responses
            else if (typeof error.body === 'string') {
                message = error.body;
            } 
            // Check for standard JavaScript errors
            else if (error.message) {
                message = error.message;
            }
        }
        return message;
    }
}