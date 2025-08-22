trigger employee2 on Employee2__c (After update , After insert , before insert,before update) {
   
    if(trigger.isbefore && trigger.isinsert || trigger.isupdate){
        employee2handler.tocheckparent(trigger.new);
      	  employee2handler.onlyonechild(trigger.new);
    }
    if(trigger.isAfter && trigger.isinsert || trigger.isupdate){
       employee2handler.updatefields(trigger.new);
    }
  
   
    
}