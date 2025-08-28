public with sharing class ObjectSchemaController {

    @AuraEnabled(cacheable=true)
    public static List<ChildRelationshipInfo> getChildObjectInfo(String parentApiName) {
        List<ChildRelationshipInfo> childInfoList = new List<ChildRelationshipInfo>();
        try {
            Schema.DescribeSObjectResult parentDescribe = Schema.getGlobalDescribe().get(parentApiName).getDescribe();
            for (Schema.ChildRelationship childRel : parentDescribe.getChildRelationships()) {
                // Get child object API name
                String childObjectName = String.valueOf(childRel.getChildSObject());
                // Get relationship name for SOQL
                String relationshipName = childRel.getRelationshipName();

                // Construct SOQL query to fetch child records
                String query = 'SELECT Id, Name FROM ' + childObjectName + ' WHERE ' + relationshipName + '.Id = :parentId LIMIT 10'; // Example query, adjust fields as needed

                // Add to list, you might want to fetch records here or in a separate call
                childInfoList.add(new ChildRelationshipInfo(childObjectName, relationshipName));
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('Error fetching child object info: ' + e.getMessage());
        }
        return childInfoList;
    }

    // Inner class to hold child relationship details
    public class ChildRelationshipInfo {
        @AuraEnabled public String childApiName;
        @AuraEnabled public String relationshipName;

        public ChildRelationshipInfo(String childApiName, String relationshipName) {
            this.childApiName = childApiName;
            this.relationshipName = relationshipName;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getChildRecords(String childApiName, String parentId, String relationshipName) {
        List<SObject> childRecords = new List<SObject>();
        try {
            // Construct SOQL query dynamically
            String query = 'SELECT Id, Name FROM ' + childApiName + ' LIMIT 10'; // Adjust fields as needed
            childRecords = Database.query(query);
        } catch (Exception e) {
            System.debug('Error fetching child records: ' + e.getMessage());
        }
        return childRecords;
    }
}