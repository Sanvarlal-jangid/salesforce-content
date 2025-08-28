public with sharing class collegeStudentinfo {

    @AuraEnabled(cacheable=true)
   public static List<Hiring_Fresh_Graduates__c> getHiringstudent() {
        
                 return [SELECT Id,
                   name,
                   Student_Email__c,
                 Student_Phone_Number__c,
                   Status__c,
                   Profile__c,
                   Year__c,
                   College_Information__r.Name,
                   College_Information__r.Id
            FROM Hiring_Fresh_Graduates__c];
         
    
       
    }
    
    

      
}