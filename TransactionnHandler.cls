public class TransactionnHandler {
    public static void validatePayments(List<Transactionn__c> newTrans) {
        Set<Id> oppIds = new Set<Id>();
        for (Transactionn__c tx : newTrans) {
            if (tx.Opportunity__c != null) {
                oppIds.add(tx.Opportunity__c);
            }
        }

 Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Amount, (SELECT Amount__c FROM Transactionn__r)
                                                         FROM Opportunity WHERE Id IN :oppIds] );

        for (Transactionn__c tx : newTrans) {
            Opportunity opp = oppMap.get(tx.Opportunity__c);
            Decimal totalPaid = 0;
            for (Transactionn__c existTx : opp.Transactionn__r) {
                totalPaid += existTx.Amount__c;
            }

            if ((totalPaid + tx.Amount__c) > opp.Amount) {
                tx.addError('payment exceeded the total amount');
            }
        }
    }	

public static void callStripeAndUpdate(List<Transactionn__c> newTrans) {
    List<Id> transIds = new List<Id>();
    for (Transactionn__c tx : newTrans) {
        transIds.add(tx.Id);
    }
    callstripetoupdateinfuture.updateopp(transIds);
}

}