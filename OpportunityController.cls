public with sharing class OpportunityController {

    @AuraEnabled
    public static List<Opportunity> getOpenOpportunities() {
        return [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName != 'Closed' limit 10
        ];
    }

@AuraEnabled
public static List<Opportunity> searchOpportunities(String name, String status) {
    List<Opportunity> result;

    if (String.isNotBlank(name) && String.isNotBlank(status)) {
        result = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName != 'Closed'
            AND Name LIKE :('%' + name + '%')
            AND StageName = :status
        ];
    } else if (String.isNotBlank(name)) {
        result = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName != 'Closed'
            AND Name LIKE :('%' + name + '%')
        ];
    } else if (String.isNotBlank(status)) {
        result = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName != 'Closed'
            AND StageName = :status
        ];
    } else {
        result = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE StageName != 'Closed'
        ];
    }

    return result;
}


    @AuraEnabled
    public static void updateOpportunityStatuses(List<Id> oppIds, String newStatus) {
        List<Opportunity> oppsToUpdate = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        for (Opportunity opp : oppsToUpdate) {
            opp.StageName = newStatus;
        }
        update oppsToUpdate;
    }
}