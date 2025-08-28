public class treegrid {
@AuraEnabled(cacheable = true)
    public static list<Account> getAccountsWithChildAccounts()
    {
        	return [SELECT id, name,NumberOfEmployees , AccountNumber , ParentId From Account];
	}
    
     @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountId) {
        return [SELECT Id, Name, CloseDate,stageName, (SELECT ContentDocumentId FROM ContentDocumentLinks) FROM Opportunity WHERE AccountId = :accountId];
    }
    
    
}