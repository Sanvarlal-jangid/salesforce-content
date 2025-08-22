trigger Accountstrigger on Account (After insert,After update,before delete,After delete,before insert,before update,after undelete) {
    
  
    
      if (Trigger.isAfter && Trigger.isInsert) {
            System.debug('account trigger'+trigger.operationType);  
        AccountContactCreatorHandler.createContactsForAccounts(Trigger.new);
    }
  
  /**  if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) )    { 
     TriggerHelper.AccounttriggerAfterupdateinsert(trigger.new);
     
    }

    if(trigger.isAfter && trigger.isUpdate )    { 
      //totalrevenueonopp.checkamount(trigger.new);
     
    }
    if(trigger.isDelete && trigger.IsBefore){
       TriggerHelper.preventaccountdeletion(trigger.old);
    }
    
    if(trigger.isDelete && trigger.IsAfter){
        TriggerHelper.backupmergedaccount(trigger.old);
    }
*/
    

}