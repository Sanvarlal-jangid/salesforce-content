import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import ORDER_CHANNEL from '@salesforce/messageChannel/orderChannel__c';

export default class OrderTable extends LightningElement {
    @track orders = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, ORDER_CHANNEL, (e) => {
            this.orders = [...this.orders, e.order];
        });
    }  
}