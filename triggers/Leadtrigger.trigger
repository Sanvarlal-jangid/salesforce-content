trigger Leadtrigger on Lead (After insert) {
    if(trigger.isInsert && trigger.isAfter){
     TriggerHelper.convertlead(trigger.new);
    }
}