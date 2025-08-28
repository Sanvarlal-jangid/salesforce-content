/**
 * @descriptionBatch class to update stale Opportunities (not modified recently) and set their StageName to 'Closed Lost'.
 * @author Sanvarlal Jangid
 */
public class OpportunityBatchClass_Q2 implements Database.Batchable<SObject> {

    /**
     * @description Returns a QueryLocator for Opportunities that are open and haven't been modified in the last ~23.5 hours.
     * @param bc The batch context provided by the system.
     * @return QueryLocator of qualifying Opportunity records.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime d = System.now().addHours(-23).addMinutes(-30).addSeconds(-25);
        return Database.getQueryLocator([SELECT Id, StageName FROM Opportunity WHERE LastModifiedDate <= :d  AND StageName != 'Closed Won' 
            AND StageName != 'Closed Lost'   ]);
    }

    /**
     * @description Executes the batch logic: updates the StageName of each Opportunity in scope to 'Closed Lost'.
     * @param bc The batch context.
     * @param scope The current chunk of Opportunity records to process.
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            opp.StageName = 'Closed Lost';
        }
        Database.update(scope, false);
    }

    /**
     * @description Runs once after all batch executions complete. Logs a debug statement.
     * @param bc The final batch context after job completion.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job completed: Opportunities updated.');
    }
}