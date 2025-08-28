public class callstripetoupdateinfuture {
    @future(callout=true)
    public static void updateopp(List<Id> transIds) {
        List<Transactionn__c> newTrans = [
            SELECT Id, Opportunity__c, Amount__c 
                   FROM Transactionn__c 
                   WHERE Id IN :transIds
        ];

        for (Transactionn__c tx : newTrans) {
            if (tx.Opportunity__c == null || tx.Amount__c == null) continue;

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.stripe.com/v1/charges');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Authorization', 'Bearer sk_test_51RaMyIQtnBnE6xdFlxMB6eKdWX5IlBlBVZIvrKqET5gsay2dFQoFCmKD8XQ9GJQDm0arBLC3g275G0oaM4FFwFoK00G8JeVT7v');

            Integer amount = Integer.valueOf(tx.Amount__c * 100);

            String body = 'amount=' + amount +
                          '&currency=usd' +
                          '&source=tok_visa' +
                          '&description=Opportunity Payment';

            req.setBody(body);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> resmap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String txnId = (String) resmap.get('id');

                tx.Payment_Transaction_Id__c = txnId;
                tx.Transaction_Error__c = null;
            } else {
                tx.Payment_Transaction_Id__c = null;
                tx.Transaction_Error__c = 'Stripe Error: ' + res.getBody();
            }
        }

        update newTrans;

        Set<Id> oppIds = new Set<Id>();
        for (Transactionn__c tx : newTrans) {
            if (tx.Opportunity__c != null) {
                oppIds.add(tx.Opportunity__c);
            }
        }

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Amount, Total_Paid__c, 
                    (SELECT Amount__c FROM Transactionn__r) 
             FROM Opportunity 
             WHERE Id IN :oppIds]
        );

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Opportunity opp : oppMap.values()) {
            Decimal totalPaid = 0;
            for (Transactionn__c tx : opp.Transactionn__r) {
                totalPaid += tx.Amount__c;
            }

            if (totalPaid > opp.Amount) {
                totalPaid = opp.Amount;
            }

            Opportunity op = new Opportunity();
            op.Id = opp.Id;
            op.Total_Paid__c = totalPaid;
            oppsToUpdate.add(op);
        }

        update oppsToUpdate;
    }
}