public with sharing class OpportunityControllerTest {

    // Method to get picklist values for a given field
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> picklistValues = new List<String>();
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
            if (objType != null) {
                Schema.sObjectField field = objType.getDescribe().fields.getMap().get(fieldApiName);
                if (field != null) {
                    List<Schema.PicklistEntry> entries = field.getDescribe().getPicklistValues();
                    for (Schema.PicklistEntry entry : entries) {
                        picklistValues.add(entry.getValue());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching picklist values: ' + e.getMessage());
            throw new AuraHandledException('Error fetching picklist values: ' + e.getMessage());
        }
        return picklistValues;
    }

    // Method to get opportunities based on a picklist value
  /*  @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String picklistFieldApiName, String picklistValue, List<String> fieldSetFields) {
        String query = 'SELECT Id, Name'; // Always include Id and Name
        if (fieldSetFields != null && !fieldSetFields.isEmpty()) {
            for (String fieldName : fieldSetFields) {
                query += ', ' + fieldName;
            }
        }
        query += ' FROM Opportunity';
        if (picklistValue != 'All Opportunities') { // Assuming 'All Opportunities' is a special tab
            query += ' WHERE ' + picklistFieldApiName + ' = :picklistValue';
        }
        query += ' ORDER BY Name ASC'; // Default sorting

        try {
            return Database.query(query);
        } catch (Exception e) {
            System.debug('Error fetching opportunities: ' + e.getMessage());
            throw new AuraHandledException('Error fetching opportunities: ' + e.getMessage());
        }
    }*/
    // Corrected Method to get opportunities based on a picklist value
@AuraEnabled(cacheable=true)
public static List<Opportunity> getOpportunities(String picklistFieldApiName, String picklistValue, List<String> fieldSetFields) {

    
  String query = 'SELECT ';

// Add fields from fieldSetFields, handling comma placement
if (fieldSetFields != null && !fieldSetFields.isEmpty()) {
    Integer index = 0;
    for (String fieldName : fieldSetFields) {
        if (index > 0) {
            query += ', ';
        }
        query += fieldName;
        index++;
    }
}

// Final query looks like: SELECT Id, Name, Email, Phone, etc.
System.debug('Query: ' + query);


    query += ' FROM Opportunity';

    // Append WHERE clause only if a specific picklist value is selected
    if (picklistValue != 'All Opportunities') {
        query += ' WHERE ' + picklistFieldApiName + ' = \'' + String.escapeSingleQuotes(picklistValue) + '\'';
    }

    query += ' ORDER BY Name ASC'; // Default sorting

    System.debug('Final SOQL Query: ' + query);

    try {
        List<Opportunity> results = Database.query(query);
        System.debug('Fetched Opportunities: ' + results.size());
        return results;
    } catch (Exception e) {
        System.debug('Error fetching opportunities: ' + e.getMessage());
        throw new AuraHandledException('Error fetching opportunities: ' + e.getMessage());
    }
}


    // Method to get field names from a field set
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldSetFields(String objectApiName, String fieldSetName) {
        List<String> fieldNames = new List<String>();
        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
            for (Schema.FieldSetMember fsm : Schema.getGlobalDescribe().get(objectApiName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
                if (fieldMap.containsKey(fsm.getFieldPath())) {
                    fieldNames.add(fsm.getFieldPath());
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching field set fields: ' + e.getMessage());
            throw new AuraHandledException('Error fetching field set fields: ' + e.getMessage());
        }
        return fieldNames;
    }

    // Method to update opportunities (for inline editing)
    @AuraEnabled
    public static void updateOpportunities(List<Opportunity> opportunitiesToUpdate) {
        try {
            update opportunitiesToUpdate;
        } catch (Exception e) {
            System.debug('Error updating opportunities: ' + e.getMessage());
            throw new AuraHandledException('Error updating opportunities: ' + e.getMessage());
        }
    }

    // Method to create a new opportunity
    @AuraEnabled
    public static Id createOpportunity(Opportunity newOpportunity) {
        try {
            insert newOpportunity;
            return newOpportunity.Id;
        } catch (Exception e) {
            System.debug('Error creating opportunity: ' + e.getMessage());
            throw new AuraHandledException('Error creating opportunity: ' + e.getMessage());
        }
    }
}