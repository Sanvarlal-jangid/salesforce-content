import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import ORDER_CHANNEL from '@salesforce/messageChannel/orderChannel__c';

export default class OrderDetail extends LightningElement {
    @track order;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, ORDER_CHANNEL, (message) => {
            this.order = message.order;
        });
    }
}