trigger opportunitylineitemtrigger on OpportunityLineItem (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        avgpricecalculate.updateaccountavg(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        avgpricecalculate.updateaccountavg(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        avgpricecalculate.updateaccountavg(Trigger.old);
    }

    if (Trigger.isAfter && Trigger.isUndelete) {
        avgpricecalculate.updateaccountavg(Trigger.new);
    }
}