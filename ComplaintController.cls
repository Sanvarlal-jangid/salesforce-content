public with sharing class ComplaintController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [
            SELECT Id, CaseNumber, Subject, Status, Contact.Name, ContactId, Product__c 
            FROM Case
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<CaseComment> getCaseComments(Id caseId) {
        return [
            SELECT Id, CommentBody, CreatedBy.Name, CreatedDate
            FROM CaseComment
            WHERE ParentId = :caseId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void addCaseComment(Id caseId, String commentText) {
        insert new CaseComment(
            CommentBody = commentText,
            ParentId = caseId,
            IsPublished = true
        );
    }
}