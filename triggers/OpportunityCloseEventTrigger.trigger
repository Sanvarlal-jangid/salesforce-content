trigger OpportunityCloseEventTrigger on OpportunityCloseEvent__e (after insert) {
    // Step 1: Collect all Close Dates from the platform events
    Set<Date> closeDates = new Set<Date>();
    for (OpportunityCloseEvent__e event : Trigger.New) {
        if (event.CloseDate__c != null) {
            closeDates.add(event.CloseDate__c);
        }
    }

    if (closeDates.isEmpty()) {
        return; 
    }

    List<Opportunity> oppsToClose = [ SELECT Id, AccountId, Amount FROM Opportunity WHERE CloseDate IN :closeDates
                                     AND StageName != 'Closed Won'];

    Map<Id, Decimal> accountAmountMap = new Map<Id, Decimal>();
    Map<Id, Integer> accountCountMap = new Map<Id, Integer>();

    for (Opportunity opp : oppsToClose) {
        opp.StageName = 'Closed Won';

        if (opp.AccountId != null) {
            // Sum Amount
            if (accountAmountMap.containsKey(opp.AccountId)) {
                accountAmountMap.put(opp.AccountId, accountAmountMap.get(opp.AccountId) + opp.Amount);
            } else {
                accountAmountMap.put(opp.AccountId, opp.Amount);
            }

            // Count Opportunities
            if (accountCountMap.containsKey(opp.AccountId)) {
                accountCountMap.put(opp.AccountId, accountCountMap.get(opp.AccountId) + 1);
            } else {
                accountCountMap.put(opp.AccountId, 1);
            }
        }
    }

    if (!oppsToClose.isEmpty()) {
        update oppsToClose;
    }

    List<Account> accountsToUpdate = new List<Account>();
    if (!accountAmountMap.isEmpty()) {
       List<Account>relatedAccounts =[ SELECT Id, Total_Closed_Opportunities__c, Total_Closed_Opportunity_Amount__c FROM Account
                                         WHERE Id IN :accountAmountMap.keySet()];

        for (Account acc : relatedAccounts) {
            acc.Total_Closed_Opportunities__c = accountCountMap.get(acc.Id);
            acc.Total_Closed_Opportunity_Amount__c = accountAmountMap.get(acc.Id);
            accountsToUpdate.add(acc);
        }

        update accountsToUpdate;
    }
}