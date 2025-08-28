/**
 * @description Schedulable class to run the BulkPhoneEnquiryLeadsConversion batch job.
 * @author Sanvarlal Jangid
 */
public class SchedulePhoneLeadsConversion implements Schedulable {

    /**
     * @description
     * Executes the scheduled job and starts the lead conversion batch.
     * @param context The scheduled job context provided by the system.
     */
    public void execute(SchedulableContext context) {
        BulkPhoneEnquiryLeadsConversion obj = new BulkPhoneEnquiryLeadsConversion();
        Database.executeBatch(obj);
    }
}