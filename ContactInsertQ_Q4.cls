/**
 * @description Queueable class that inserts a Contact for each given Account and chains the next job in the sequence.
 * @author Sanvarlal Jangid
 */
public class ContactInsertQ_Q4 implements Queueable {

    private List<Account> accounts;

    /**
     * @description Constructor to initialize the queueable job with a list of accounts.
     * @param accList The list of Account records to use for creating Contacts.
     */
    public ContactInsertQ_Q4(List<Account> accList) {
        this.accounts = accList;
    }

    /**
     * @description Executes the queueable job to insert contacts and enqueue the next task in sequence.
     * @param context The queueable context provided by the system.
     */
    public void execute(QueueableContext context) {
        System.debug('contact vali class');

        List<Contact> contactList = new List<Contact>();
        for (Account acc : accounts) {
            contactList.add(new Contact(LastName = 'Test Contact', AccountId = acc.Id));
        }
        insert contactList;

        // Chain next job
        System.enqueueJob(new Task3_Q4());
    }
}