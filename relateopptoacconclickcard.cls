public with sharing class relateopptoacconclickcard {

    @AuraEnabled(cacheable=true)
    public static List<Account> getrecords() {
        return [SELECT Id, Name, AnnualRevenue, 
                       (SELECT Id FROM Opportunities) 
                FROM Account 
                WHERE Id IN (SELECT AccountId FROM Opportunity)];
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getopp() {
        return [SELECT Id, Name, AccountId, Account.Name, ExpectedRevenue 
                FROM Opportunity 
                WHERE ExpectedRevenue != null AND AccountId != null];
    }

    @AuraEnabled
    public static void relateOpportunitiesToAccount(Id accountId, List<Id> opportunityIds) {
        List<Opportunity> oppsToUpdate = [
            SELECT Id FROM Opportunity WHERE Id IN :opportunityIds
        ];
        for (Opportunity opp : oppsToUpdate) {
            opp.AccountId = accountId;
        }
        update oppsToUpdate;
    }
}