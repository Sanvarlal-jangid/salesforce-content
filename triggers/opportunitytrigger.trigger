trigger opportunitytrigger on Opportunity (before insert,after insert,before update,after update) {
   
    if(trigger.isInsert && trigger.isBefore){
        TriggerHelper.duplicateopportunity(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        //TriggerHelper.RestrictStageChange(trigger.new,trigger.oldMap);
    }
    
      if(trigger.isUpdate && trigger.isafter){
             Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        if (opp.AccountId != null) {
            accountIds.add(opp.AccountId);
        }
    }

    if (accountIds.isEmpty()) {
        return;
    }

    Map<Id, Integer> overdueCounts = new Map<Id, Integer>();
    List<AggregateResult> overdueResults = [
        SELECT AccountId accId, COUNT(Id) cnt
        FROM Opportunity
        WHERE OverDue__c = true AND AccountId IN :accountIds
        GROUP BY AccountId
    ];
    for (AggregateResult ar : overdueResults) {
        overdueCounts.put((Id)ar.get('accId'), (Integer)ar.get('cnt'));
    }

    Map<Id, Integer> closedCounts = new Map<Id, Integer>();
    List<AggregateResult> closedResults = [
        SELECT AccountId accId, COUNT(Id) cnt
        FROM Opportunity
        WHERE StageName = 'Closed' AND AccountId IN :accountIds
        GROUP BY AccountId
    ];
    for (AggregateResult ar : closedResults) {
        closedCounts.put((Id)ar.get('accId'), (Integer)ar.get('cnt'));
    }

 
    List<Account> accUpdates = new List<Account>();
    for (Id accId : accountIds) {
        Integer overdue = overdueCounts.containsKey(accId) ? overdueCounts.get(accId) : 0;
        Integer closed = closedCounts.containsKey(accId) ? closedCounts.get(accId) : 0;

        Account acc = new Account(Id = accId);
        acc.Total_Overdue_Opportunities__c = overdue;
        acc.Total_Closed_Opportunities__c = closed;
        accUpdates.add(acc);
    }

  
    if (!accUpdates.isEmpty()) {
        update accUpdates;
    }
      }
         
    /** if(trigger.isUpdate && trigger.isafter){
         opppaymenttriggerhandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);  
      }
*/
    if( trigger.isafter && (trigger.isinsert || trigger.isupdate)  ){
        totalrevenueonopp.updateaccounttotalrevenue(trigger.new);
    }
    if(trigger.isafter && trigger.isupdate){
         totalrevenueonopp.updateaccounttotalrevenue(trigger.old);
    }
}