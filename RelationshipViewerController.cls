public with sharing class RelationshipViewerController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<SObject>> getRelatedRecords(Id recordId) {
        Map<String, List<SObject>> relatedDataMap = new Map<String, List<SObject>>();

        if (recordId == null) return relatedDataMap;

        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        List<Schema.ChildRelationship> childRelationships = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .getChildRelationships();

        for (Schema.ChildRelationship childRel : childRelationships) {
            String childObject = String.valueOf(childRel.getChildSObject());
            String fieldName = String.valueOf(childRel.getField());

            if (childObject != null && fieldName != null &&
                !childObject.startsWith('Hist') &&
                !childObject.startsWith('Feed') &&
                !childObject.endsWith('ChangeEvent') &&
                Schema.getGlobalDescribe().containsKey(childObject) &&
                Schema.getGlobalDescribe().get(childObject).getDescribe().isQueryable()) {

                String soql = 'SELECT Id, Name FROM ' + childObject + 
                              ' WHERE ' + fieldName + ' = :recordId LIMIT 10';

                try {
                    List<SObject> records = Database.query(soql);
                    relatedDataMap.put(childObject, records);
                } catch (Exception e) {
                    System.debug('Query failed for ' + childObject + ': ' + e.getMessage());
                }
            }
        }

        return relatedDataMap;
    }
}