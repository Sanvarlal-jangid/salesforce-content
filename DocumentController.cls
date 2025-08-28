public with sharing class DocumentController {
    @AuraEnabled(cacheable=true)
    public static List<Document__c> getDocuments() {
        return [
            SELECT Id, Name, Document_type__c, valid_from_date__c, Valid_to_date__c, isActive__c
            FROM Document__c
        ];
    }
}