/**
 * @description Queueable class that sends a confirmation email to the System Administrator after data import completion.
 * @author Sanvarlal Jangid
 */
public class SysAdminReviewQ_Q4 implements Queueable {

    /**
     * @description Executes the queueable job to notify the System Administrator via email after successful import.
     * @param context The queueable context provided by the system.
     */
    public void execute(QueueableContext context) {
        System.debug('account, contact and task imported successfully');

        User a = [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        String mailid = a.Email;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ mailid });
        email.setSubject('Data import through apex');
        email.setPlainTextBody('All the Account, Contact, and Task records have been imported successfully.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}