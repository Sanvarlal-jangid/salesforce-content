trigger oppotunitylineitemtrigger on OpportunityLineItem (before insert,before update , after insert) {
   
    if(trigger.isInsert && trigger.isbefore){
      TriggerHelper.updateproductdescription(trigger.new);
    }
  
}