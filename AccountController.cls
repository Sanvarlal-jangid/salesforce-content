public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Phone, Industry FROM Account limit 10];
    }

  
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {

        return [
            SELECT Id, Name, Email, Account.Name, LeadSource
            FROM Contact
            LIMIT 100 
        ];
    }

  


   

    

    
    
    @AuraEnabled
    public static List<Contact> getContactsByAccount(Id accountId) {
        return [
            SELECT Id, Name, Email, Phone, Account.Name
            FROM Contact
            WHERE AccountId = :accountId
        ];
    }

    
  
}