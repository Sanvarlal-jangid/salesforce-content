public with sharing class datefilterintable {
   
    @AuraEnabled(cacheable=true)
    public static List<Order> getorders(){
        try {
            return [select id ,OrderNumber,EffectiveDate,AccountId,Account.Name,Status__c,TotalAmount from order];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}