/**
 * @description Queueable class that creates a Task for the System Administrator and chains the next queueable job.
 * @author Sanvarlal Jangid
 */
public class Task3_Q4 implements Queueable {

    /**
     * @description Executes the queueable job to create a review task for the system admin and enqueue the next job.
     * @param context The queueable context provided by the system.
     */
    public void execute(QueueableContext context) {
        System.debug('task vali class');

        User a = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Task adminTask = new Task(
            Subject = 'Review Imported Data',
            Status = 'Not Started',
            Priority = 'High',
            OwnerId = a.Id
        );
        insert adminTask;

        System.enqueueJob(new SysAdminReviewQ_Q4());
    }
}