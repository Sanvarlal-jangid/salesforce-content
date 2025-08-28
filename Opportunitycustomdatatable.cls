
public with sharing class Opportunitycustomdatatable {

    // Method to get a list of all Accounts to populate the dropdown
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountOptions() {
        return [SELECT Id, Name FROM Account ORDER BY Name ASC];
    }

    // Method to get a list of all Opportunities associated with a specific Account
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String accountId) {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate
            FROM Opportunity
            WHERE AccountId = :accountId
            ORDER BY CloseDate DESC
        ];
    }

    // Method to get the picklist values for the 'StageName' field on the Opportunity object
    @AuraEnabled(cacheable=true)
    public static List<String> getStageOptions() {
        List<String> stageNames = new List<String>();
        // Use Schema.describeSObjects to get field information
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            stageNames.add(entry.getLabel());
        }
        return stageNames;
    }

    // Method to update a single Opportunity record
    @AuraEnabled
    public static void updateOpportunity(String opportunityId, String fieldName, Object value) {
        Opportunity opp = new Opportunity(Id = opportunityId);

        if (fieldName == 'Amount') {
            opp.Amount = (Decimal)value;
        } else if (fieldName == 'StageName') {
            opp.StageName = (String)value;
        }
        
        update opp;
    }
}