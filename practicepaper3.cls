public with sharing class practicepaper3 {
  @AuraEnabled(cacheable=true)
  public static List<RealState__c> getRealState(){
    try {
        return  [select id ,City__c,Image__c,Price__c,Address__c,State__c from RealState__c];
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static contact getcontact(string contid){
    try {
        return [select id ,FirstName,Email,LastName,Phone,Image__c from contact where RealState__c =:contid limit 1];
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }
}