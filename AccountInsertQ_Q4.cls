/**
 * @description Queueable class that inserts 2000 Accounts and enqueues a Contact creation job afterward.
 * @author Sanvarlal Jangid
 */
public class AccountInsertQ_Q4 implements Queueable {

    /**
     * @description Executes the queueable job to insert accounts and chain a contact insertion queueable job.
     * @param context The queueable context provided by the system.
     */
    public void execute(QueueableContext context) {
        System.debug('account vali class');

        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < 2000; i++) {
            accList.add(new Account(Name = 'Test Account2 ' + i));
        }
        insert accList;

        System.enqueueJob(new ContactInsertQ_Q4(accList));
    }
}