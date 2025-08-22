trigger trnsactiontrigger on Transaction__c (after insert,after update,after undelete,after delete) {
 
    if(trigger.isafter && trigger.isdelete){
       
         TriggerHelper.avgOfTransaction(trigger.old);
    }
    
    
    if(trigger.isAfter && trigger.isinsert || trigger.isupdate ){

          TriggerHelper.avgOfTransaction(trigger.new);

    }
    }