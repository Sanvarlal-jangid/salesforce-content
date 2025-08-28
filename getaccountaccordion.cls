public with sharing class getaccountaccordion {
      @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsforaccodion() {
		system.debug('in getAccountsforaccodion');
        return [
       SELECT Id, Name, Rating, Phone,
                (SELECT Id, FirstName, LastName FROM Contacts),
                (SELECT Id, Name, StageName FROM Opportunities)
            FROM Account 
        ];
    }
}