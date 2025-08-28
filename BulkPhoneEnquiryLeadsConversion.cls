/**
 * @description
 * Batch class to convert unconverted Leads where LeadSource = 'Phone Inquiry'.
 * It processes all such Leads and converts them using the standard Lead conversion API.
 * It also tracks total and failed conversions and sends a summary email to the system admin upon completion.
 
 * @author Sanvarlal Jangid
 */
public class BulkPhoneEnquiryLeadsConversion implements Database.Batchable<SObject>, Database.Stateful {

    Integer totalLeads = 0;
    Integer failedLeads = 0;
    Id batchJobId;

    /**
     * @description
     * Start method returns a QueryLocator for all unconverted leads from 'Phone Inquiry'.
     *
     * @param context The batch context passed by the system.
     * @return QueryLocator of eligible Leads.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, LastName, Company, LeadSource 
            FROM Lead  
            WHERE IsConverted = FALSE AND LeadSource = 'Phone Inquiry'
        ]);
    }

    /**
     * @description
     * Executes the batch logic for converting each lead using LeadConvert.
     * Tracks success and failure counts.
     *
     * @param context The batch context.
     * @param scope List of Lead records for this batch chunk.
     */
    public void execute(Database.BatchableContext context, List<Lead> scope) {
        totalLeads += scope.size();

        for (Lead l : scope) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Qualified');

            Database.LeadConvertResult result = Database.convertLead(lc);
            if (!result.isSuccess()) {
                failedLeads++;
            }
        }
    }

    /**
     * @description
     * Sends a summary email with total and failed conversion counts to the System Administrator after the batch completes.
     *
     * @param context The batch context for the finished job.
     */
    public void finish(Database.BatchableContext context) {
        batchJobId = context.getJobId();
        User a = [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String mailid = a.Email;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ mailid });
        email.setSubject('Lead Conversion Batch Job Report');
        email.setPlainTextBody(
            'Batch Job ID: ' + batchJobId + '\n' +
            'Total Leads Processed: ' + totalLeads + '\n' +
            'Total Leads Failed to Convert: ' + failedLeads
        );

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}