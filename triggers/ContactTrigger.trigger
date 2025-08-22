trigger ContactTrigger on Contact (after insert, after update, after delete) {
    ContactTriggerHandler.handleContactChanges(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
}