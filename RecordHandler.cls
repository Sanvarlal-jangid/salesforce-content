public with sharing class RecordHandler {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String objectApiName) {
        String query;
        if (objectApiName == 'Case') {
            query = 'SELECT Id, CaseNumber, OwnerId, Owner.Name FROM Case ORDER BY CreatedDate DESC LIMIT 20';
        } else {
            query = 'SELECT Id, Name, OwnerId, Owner.Name FROM ' + objectApiName + ' ORDER BY CreatedDate DESC LIMIT 20';
        }
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name, Username, Email FROM User WHERE IsActive = TRUE LIMIT 50];
    }

  

    @AuraEnabled
    public static void assignRecords(String objectApiName, List<Id> recordIds, Id newOwnerId) {
        List<SObject> records = new List<SObject>();
        for (Id recordId : recordIds) {
            SObject sObj = (SObject) Type.forName('Schema.' + objectApiName).newInstance();
            sObj.put('Id', recordId);
            sObj.put('OwnerId', newOwnerId);
            records.add(sObj);
        }
        update records;
    }
    /*
    String objectApiName = 'Account'; // Replace this with your desired object name
Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
Schema.SObjectType objectType = globalDescribeMap.get(objectApiName);

if (objectType != null) {
    SObject sObj = objectType.newSObject();
    // Now you can use sObj just like any other object
    sObj.put('Name', 'Test Account');
    insert sObj;
} else {
    System.debug('Invalid object API name: ' + objectApiName);
}
*/

}