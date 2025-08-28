public with sharing class practicetestclass {
   @AuraEnabled(cacheable=true)
   public static List<Opportunity> getopportunity(){
     system.debug('int the function of getopportunity');
    return [ SELECT Id, Name, Campaign.Name, Type , CloseDate , Account.Name, TotalOpportunityQuantity
FROM Opportunity];
} 


  
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldApiName) {
        List<String> values = new List<String>();
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sobjectType != null) {
            Schema.DescribeFieldResult fieldResult = sobjectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                values.add(entry.getLabel());
            }
        }
        return values;
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




 @AuraEnabled
public static void updateOpportunities(List<Opportunity> opportunities) {
    update opportunities;
}
}