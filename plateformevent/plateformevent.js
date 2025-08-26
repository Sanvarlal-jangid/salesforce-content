import { LightningElement, track } from 'lwc';
import createOpportunityApex from '@salesforce/apex/OpportunityController.createOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, onError } from 'lightning/empApi';

export default class PlatformEventTable extends LightningElement {

    @track eventRecords = [];

    channelName = '/event/OpportunityEvent__e';
    subscription = {};

     @track latestNotification;

    // form fields
    oppName = '';
    oppStage = '';
    oppAmount = 0;



     // handle input changes
    handleNameChange(event) {
        this.oppName = event.target.value;
    }
    handleStageChange(event) {
        this.oppStage = event.target.value;
    }
    handleAmountChange(event) {
        this.oppAmount = event.target.value;
    }

    // call Apex to create Opportunity
    createOpportunity() {
        createOpportunityApex({ 
            name: this.oppName, 
            stage: this.oppStage, 
            amount: parseFloat(this.oppAmount) 
        })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity created successfully!',
                    variant: 'success'
                })
            );
            this.oppName = '';
            this.oppStage = '';
            this.oppAmount = 0;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating opportunity',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    connectedCallback() {

        this.subscribeToPlatformEvent();

    }

    subscribeToPlatformEvent() {

        const callback = (message) => {
            if (message && message.data && message.data.payload) {
                const record = {
                    OppName: message.data.payload.opportunityName__c,
                    StageName: message.data.payload.StageName__c,
                    Amount: message.data.payload.Amount__c,
                    CloseDate: new Date(message.data.payload.CloseDate__c),
                    Timestamp: new Date(message.data.payload.CreatedDate).toLocaleString()
                };
                this.eventRecords = [record, ...this.eventRecords];

            }

        };

        subscribe(this.channelName, -1, callback).then((response) => {
            console.log('Subscribed to:', response.channel);
            this.subscription = response;
        });

        onError((error) => {
            console.error('EMP API error:', error);
        });

    }

}

