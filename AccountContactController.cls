public with sharing class AccountContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContacts() {
        return [SELECT Id, Name, Email, Phone, AccountId FROM Contact];
    }

    @AuraEnabled
    public static void associateContactsToAccount(Id accountId, List<Id> contactIds) {
        List<Contact> updates = new List<Contact>();
        for (Id cid : contactIds) {
            updates.add(new Contact(Id = cid, AccountId = accountId));
        }
        update updates;
    }
}