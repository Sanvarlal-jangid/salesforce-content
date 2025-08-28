public with sharing class questionController {

    @AuraEnabled(cacheable=true)
    public static list<Question__c> quizeQuestion() {
         return [select Name ,OptionA__c,OptionB__c,OptionC__c,OptionD__c,Correct_Answer__c from Question__c limit 10];

    }
    
}