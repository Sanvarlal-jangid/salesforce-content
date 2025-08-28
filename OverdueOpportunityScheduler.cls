global class OverdueOpportunityScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        OverdueOpportunityBatch batch = new OverdueOpportunityBatch();
        Database.executeBatch(batch);
    }
}