global class OverdueOpportunityBatch implements Database.Batchable<sObject>, Database.Stateful {

    // Store overdue opportunities across chunks
    public List<Opportunity> allOverdueOpps = new List<Opportunity>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Name, CloseDate, StageName, AccountId FROM Opportunity WHERE StageName != \'Closed\' AND CloseDate < TODAY'
        );
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Opportunity> updatedOpps = new List<Opportunity>();
        Map<Id, Integer> accOverdueMap = new Map<Id, Integer>();

        for (Opportunity opp : scope) {
            Integer daysLate = Date.today().daysBetween(opp.CloseDate);
            opp.OverDue__c = true;
            opp.OverDue_Days__c = daysLate;
            updatedOpps.add(opp);
            allOverdueOpps.add(opp);

            Id accId = opp.AccountId;
            if (accId != null) {
                if (!accOverdueMap.containsKey(accId)) {
                    accOverdueMap.put(accId, 1);
                } else {
                    accOverdueMap.put(accId, accOverdueMap.get(accId) + 1);
                }
            }
        }

        update updatedOpps;

        List<Account> accUpdates = new List<Account>();
        for (Id accId : accOverdueMap.keySet()) {
            Account acc = new Account(Id = accId);
            acc.Total_Overdue_Opportunities__c = accOverdueMap.get(accId);
            accUpdates.add(acc);
        }

        update accUpdates;
    }

    global void finish(Database.BatchableContext BC) {

        String emailBody = ' Daily Overdue Opportunity Report\n';
        emailBody += 'Total Overdue Opportunities: ' + String.valueOf(allOverdueOpps.size()) + '\n\n';

        for (Opportunity opp : allOverdueOpps) {
            emailBody += '- ' + opp.Name +
                         ' | Close Date: ' + String.valueOf(opp.CloseDate) +
                         ' | Overdue Days: ' + String.valueOf(opp.OverDue_Days__c) + '\n';
        }
        List<String>toAddresses = new List<String>{};   
            
   List<User>u = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator'];
                for(user ui:u){
                  toAddresses.add(ui.Email);
                }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(' Overdue Opportunities Summary');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}