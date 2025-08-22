trigger branchtrigger on Branch__c (After update) {
    if(trigger.isUpdate && trigger.isAfter){
        TriggerHelper.updatebankaccount(Trigger.new,trigger.oldmap);
    }
}