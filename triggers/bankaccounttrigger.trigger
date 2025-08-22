trigger bankaccounttrigger on Bank_Account__c (After insert,before delete) {
    
    
    if(trigger.isInsert && trigger.isAfter){
        TriggerHelper.updatebank(trigger.new);
    }
    if(trigger.isDelete && trigger.isBefore){
        TriggerHelper.stopdeleteaccount(trigger.old);
    }

}