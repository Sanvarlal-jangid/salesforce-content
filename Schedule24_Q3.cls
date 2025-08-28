/**
 * @description Schedulable class that runs the AssigningCase_Q3 batch job to reassign open cases.
 * @author Sanvarlal Jangid
 */
public class Schedule24_Q3 implements Schedulable {

    /**
     * @description Executes the scheduled job to run AssigningCase_Q3 batch with a batch size of 200.
     * @param SC The schedulable context provided by the system.
     */
    public void execute(SchedulableContext SC) {
        AssigningCase_Q3 batchJob = new AssigningCase_Q3();
        Database.executeBatch(batchJob, 200);
    }
}