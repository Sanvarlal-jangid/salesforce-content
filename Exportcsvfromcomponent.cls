public with sharing class ExportCsvFromComponent {

    @AuraEnabled(cacheable=true)
    public static List<Account> getData() {
        return [
            SELECT Id, Name,
                (SELECT Id, FirstName, LastName FROM Contacts LIMIT 1),
                (SELECT Id, OwnerId, Status, AccountId, EffectiveDate, EndDate, TotalAmount FROM Orders)
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order)
        ];
    }
}
