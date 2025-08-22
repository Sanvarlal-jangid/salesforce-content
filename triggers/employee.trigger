trigger employee on Employee__c (after update) {
    updatecompany.updateavgonc(trigger.new);
}