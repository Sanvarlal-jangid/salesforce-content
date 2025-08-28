public with sharing class mocktestresult {
   

@AuraEnabled(cacheable=true)
public static List<Mock_test_Result__c> getdata() {
    return [
        SELECT Id, Date_of_attempt__c, Result_Status__c, Score__c,
               Student__c, Student__r.Name, Test_name__c
        FROM Mock_test_Result__c
    ];
}
}