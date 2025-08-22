trigger performancetrigger on Performance__c (After insert,After update) {
    
   
    
    if (Trigger.isAfter) {
        List<Performance__c> oldRecords = Trigger.isUpdate ? Trigger.old : new List<Performance__c>();
        List<Performance__c> newRecords = Trigger.new;

         performancehandler.updatedata(newRecords,oldRecords);
    }
}