import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import ORDER_CHANNEL from '@salesforce/messageChannel/orderChannel__c';

export default class OrderForm extends LightningElement {
    @track customerName = '';
    @track item = '';
    @track quantity = 1;

    itemOptions = [
        { label: 'Laptop', value: 'Laptop' },
        { label: 'Phone', value: 'Phone' },
        { label: 'Tablet', value: 'Tablet' }
    ];

    @wire(MessageContext)
    messageContext;

    handleNameChange(event) {
        this.customerName = event.target.value;
    }

    handleItemChange(event) {
        this.item = event.target.value;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handlePlaceOrder() {   
        if (!this.customerName || !this.item || !this.quantity) {
            alert('Please fill all fields');
            return;
        }

        const newOrder = {
            orderId: 'ORD-' + Date.now(),
            customerName: this.customerName,
            item: this.item,
            quantity: this.quantity
        };

        publish(this.messageContext, ORDER_CHANNEL, { order: newOrder });

        this.customerName = '';
        this.item = '';
        this.quantity = 1;
    }
}