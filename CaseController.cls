public with sharing class CaseController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCases() {
        return [
            SELECT Id, CaseNumber, Subject, Description, Status, Priority, CreatedDate
            FROM Case
            LIMIT 10
        ];
    }
}