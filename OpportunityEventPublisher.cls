@RestResource(urlMapping='/triggerOpportunityCloseEvent/*')
global with sharing class OpportunityEventPublisher {
    @HttpPost
    global static String publishEvent() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        system.debug('request body'+body);
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);



        Date closeDate;
        try {
            closeDate = Date.valueOf((String)payload.get('closeDate'));
        } catch (Exception e) {
               system.debug('error in getting date from the map'+e);
        }

        OpportunityCloseEvent__e event = new OpportunityCloseEvent__e( CloseDate__c = closeDate);

        Database.SaveResult result = EventBus.publish(event);

        if (result.isSuccess()) {
            return 'successfull event ';
        } else {
            return 'failed  publish event: ' + result.getErrors()[0].getMessage();
        }
    }
}

 /*

import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/empApi';

export default class OrderSubscriber extends LightningElement {
    channelName = '/event/Order_Notification__e';
    subscription = {};

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToEvent();
    }

    subscribeToEvent() {
        const callback = (response) => {
            const payload = response.data.payload;
            console.log('Order Update:', payload.Status__c);
        };

        subscribe(this.messageContext, this.channelName, -1, callback)
            .then((response) => {
                console.log('Subscribed:', response.channel);
                this.subscription = response;
            });
    }
}
*/