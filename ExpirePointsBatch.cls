global class ExpirePointsBatch implements Schedulable, Database.Batchable<SObject> {
     
     global void execute(SchedulableContext sc) {
        ExpirePointsBatch batch = new ExpirePointsBatch();
        Database.executeBatch(batch); 
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date monthago = System.today().addMonths(-1);
        return Database.getQueryLocator([
            SELECT Id, Status__c FROM Reward_Point__c
            WHERE Status__c = 'Earned' AND Earned_Date__c <= :monthago
        ]);
    }


    global void execute(Database.BatchableContext BC, List<Reward_Point__c> scope) {
        List<Reward_Point__c> updateList = new List<Reward_Point__c>();
        for (Reward_Point__c rp : scope) {
            rp.Status__c = 'Expired';
            updateList.add(rp);
        }
        update updateList;
    }

    global void finish(Database.BatchableContext BC) {
       
    }

   
}