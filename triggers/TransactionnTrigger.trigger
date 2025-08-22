trigger TransactionnTrigger on Transactionn__c (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        TransactionnHandler.validatePayments(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        TransactionnHandler.callStripeAndUpdate(Trigger.new);
    }

}