public class TransactionUtils {
    
    
    public Boolean transactionWithinOpHrs(Transaction__c tr) {
        if (tr.Creation_Time__c != null) {
            Time transactionTime = tr.Creation_Time__c.time();
            return (transactionTime >= Time.newInstance(9, 0, 0, 0) && transactionTime <= Time.newInstance(18, 0, 0, 0));
        }
        return false;
    }
    public Integer calculateTransactionAge(DateTime trdatetime){
        if(trdatetime!=null){
            return Date.today().daysBetween(trdatetime.date());
        }
        return 0;
        
    }
    public void logTransactionOrLoanDetails(SObject tr){
        system.debug(tr.get('Bank_Account__c'));
        system.debug(tr.get('Creation_Time__c'));
        system.debug(tr.get('Deposit_Amount__c'));
        
        
    }
    public set<Id> findDuplicateTransactions (List<Id>trId){
        Set<Id>st=new Set<Id>();
        st.addAll(trId);
        return st;
        
    }
    
}