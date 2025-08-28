/**
 * @description Schedulable class that dynamically reschedules itself 6.5 hours ahead .
 * @author Sanvarlal Jangid
 */
public class ScheduleOpp_Q2 implements Schedulable {

    /**
     * @description Executes the scheduled logic: reschedules itself 6.5 hours later using a dynamic cron expression and initiates the Opportunity batch job.
     * @param sc The context for the scheduled job provided by the system.
     */
    public void execute(SchedulableContext sc) {
        Datetime dt = Datetime.now().addMinutes(390); // 6.5 hours later
        String jobName = 'BatchJob_' + dt;

        String cron = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule(jobName, cron, new ScheduleOpp_Q2());

        OpportunityBatchClass_Q2 batch = new OpportunityBatchClass_Q2();
        Database.executeBatch(batch);
    }
}