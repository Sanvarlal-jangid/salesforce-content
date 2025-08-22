trigger casetrigger on Case (before insert) {
    if(trigger.isInsert && trigger.isBefore){
        TriggerHelper.checkownertotalcase(trigger.new);
    }
}