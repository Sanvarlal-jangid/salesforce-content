/**
 * @description Batch class that evenly reassigns open Cases to active Users in a round-robin manner.
 * @author Sanvarlal Jangid
 */
public class AssigningCase_Q3 implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * @description Returns a QueryLocator for all open (unclosed) Case records.
     * @param BC The batch context.
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, OwnerId    FROM Case WHERE IsClosed = FALSE ]);
    }

    /**
     * @description Reassigns each Case to an active User in a round-robin fashion.
     * @param BC The batch context.
     * @param caseList The list of Case records to process.
     */
    public void execute(Database.BatchableContext BC, List<Case> caseList) {
        List<User> users = [SELECT Id FROM User WHERE IsActive = TRUE];
        Integer totalUsers = users.size();
        if (totalUsers == 0) return;

        Integer index = 0;
        for (Case c : caseList) {
            c.OwnerId = users[index].Id;
            index = (index >= totalUsers - 1) ? 0 : index + 1;
        }

        Database.update(caseList, false);
    }

    /**
     * @description Logs a message when batch case assignment is complete.
     * @param BC The batch context.
     */
    public void finish(Database.BatchableContext BC) {
        System.debug('Case reassignment completed');
    }
}