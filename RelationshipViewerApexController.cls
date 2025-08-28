public with sharing class RelationshipViewerApexController {

    // (Your existing RelatedListWrapper class remains the same)
    public class RelatedListWrapper {
        @AuraEnabled public String relationshipName;
        @AuraEnabled public String label;
        @AuraEnabled public String childSObjectApiName;
        @AuraEnabled public List<Map<String, Object>> records;
        @AuraEnabled public Integer totalCount;
    }

    @AuraEnabled(cacheable=true)
    public static List<RelatedListWrapper> getRelatedListsData(Id recordId, String parentSObjectApiName) {
        List<RelatedListWrapper> results = new List<RelatedListWrapper>();

        if (recordId == null || String.isBlank(parentSObjectApiName)) {
            System.debug('RecordId or ParentSObjectApiName is null or blank. Cannot fetch related lists.');
            return results;
        }

        // 1. Get information about the parent object.
        Schema.SObjectType parentSObjectType = Schema.getGlobalDescribe().get(parentSObjectApiName);

        if (parentSObjectType == null) {
            System.debug('Parent SObject Type not found: ' + parentSObjectApiName);
            return results;
        }

        // Get the describe result for the parent SObject
        Schema.DescribeSObjectResult parentDescribeResult = parentSObjectType.getDescribe();

        // 2. Get a list of all child relationships for the parent object.
        // This is the correct method: getChildRelationships() returns a List.
        List<Schema.ChildRelationship> childRelationships = parentDescribeResult.getChildRelationships();

        // If you need a map for quick lookup by relationship name, you can build it.
        // This makes it work like your original intent.
        Map<String, Schema.ChildRelationship> childRelationshipsMap = new Map<String, Schema.ChildRelationship>();
        for (Schema.ChildRelationship cr : childRelationships) {
            if (cr.getRelationshipName() != null) {
                childRelationshipsMap.put(cr.getRelationshipName(), cr);
            }
        }

        // 3. Loop through each child relationship found for the parent object.
        // Now iterate over the keys of your newly created map.
        for (String relationshipName : childRelationshipsMap.keySet()) {
            Schema.ChildRelationship currentRelationship = childRelationshipsMap.get(relationshipName);

            // Ensure this relationship actually links to another SObject and has a valid relationship name.
            if (currentRelationship.getChildSObject() != null && currentRelationship.getRelationshipName() != null) {
                String childObjectName = currentRelationship.getChildSObject().getDescribe().getName();
                String relationshipFieldName = currentRelationship.getField().getDescribe().getName();

                // Construct a SOQL query string dynamically.
                String query = 'SELECT Id, Name FROM ' + childObjectName +
                               ' WHERE ' + relationshipFieldName + ' = :recordId ' +
                               ' ORDER BY Name LIMIT 5';

                String countQuery = 'SELECT COUNT() FROM ' + childObjectName +
                                    ' WHERE ' + relationshipFieldName + ' = :recordId';

                List<sObject> relatedRecords = new List<sObject>();
                Integer totalCount = 0;

                try {
                    relatedRecords = Database.query(query);
                    totalCount = Database.countQuery(countQuery);
                } catch (Exception e) {
                    System.debug('Error querying related list ' + childObjectName + ' for ' + parentSObjectApiName + ': ' + e.getMessage());
                    continue;
                }

                if (!relatedRecords.isEmpty()) {
                    RelatedListWrapper wrapper = new RelatedListWrapper();
                    wrapper.relationshipName = currentRelationship.getRelationshipName();
                    wrapper.label = currentRelationship.getRelationshipName() + ' (' + totalCount + ')';
                    wrapper.childSObjectApiName = childObjectName;
                    wrapper.records = new List<Map<String, Object>>();
                    wrapper.totalCount = totalCount;

                    for (sObject s : relatedRecords) {
                        Map<String, Object> recordMap = new Map<String, Object>();
                        recordMap.put('Id', s.Id);
                        recordMap.put('Name', s.get('Name')); // Use get('Name') for generic sObjects.
                        wrapper.records.add(recordMap);
                    }
                    results.add(wrapper);
                }
            }
        }
        return results;
    }
}