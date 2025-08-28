public with sharing class lookuphelper {
    @AuraEnabled(cacheable=true)
  
    public static List<Contact> getContacts(String accid) {
        System.debug('accid from class'+accid);
        try {
            if (accid != null) {
                return [SELECT Id, Name, AccountId, Phone FROM Contact WHERE AccountId = :accid];
            } else {
                throw new AuraHandledException('Account Id cannot be null.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deletecontact(List<id>conlist){
      System.debug('conlist id '+conlist);
      List<contact> delcon=new List<contact>();
        try {
            List<contact>contactlist = [SELECT Id,Name,Accountid FROM contact WHERE id IN:conlist];
           delete contactlist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    
}