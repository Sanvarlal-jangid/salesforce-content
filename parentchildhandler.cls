public with sharing class parentchildhandler {
    @AuraEnabled(cacheable=true)
    public static List<contact>  getContacts(ID accountId){
        try{
            system.debug('account id from lwc '+accountId);
            return [SELECT Id,Name,AccountId,Phone FROM Contact WHERE AccountId =: accountId];
        }catch(Exception e){
                throw new AuraHandledException('error while returning contact related to account id '+e.getMessage());
        }
 }
}