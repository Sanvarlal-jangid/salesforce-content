@RestResource(urlMapping='/mergeAccountsss')
global with sharing class AccountMergeHandler {
    
   
      @HttpPost
    global static void processAccounts() {
           RestRequest req = RestContext.request;
        String jsonBody = req.requestBody.toString();
        
          List<Object> accListData = new list<object>();
        
        Map<String, Object> wrapperMap = new map<string,object>();
        try{
               wrapperMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
       accListData = (List<Object>) wrapperMap.get('Accounts');
          
        }catch(exception e){
            system.debug('error deserialising the req'+e.getMessage());
        }
    
        
          if (accListData == null || accListData.isEmpty()) {
            return;
        }
        
        // Collect Name and Website for duplicate check
        Set<String> names = new Set<String>();
        Set<String> websites = new Set<String>();
        
        for (Object obj : accListData) {
            Map<String, Object> accData = (Map<String, Object>) obj;
            if (accData.containsKey('Name')) names.add((String) accData.get('Name'));
            if (accData.containsKey('Website')) websites.add((String) accData.get('Website'));
        }
        
 
 List<Account> existingAccList = [
            SELECT Id, Name, Website, Email__c, Phone, Type, Industry, BillingCity, BillingState, BillingCountry, BillingStreet
            FROM Account WHERE Name IN :names AND Website IN :websites];
        
        // Map of existing Accounts based on Name+Website
        Map<String, Account> existingAccMap = new Map<String, Account>();
        for (Account acc : existingAccList) {
            String key = acc.Name + '|' + acc.Website;
            existingAccMap.put(key, acc);
        }
        
        List<Account> toInsert = new List<Account>();
        List<Account> toUpdate = new List<Account>();
        
        Map<String, Account> newAccConsolidated = new Map<String, Account>();
        
      
        for (Object obj : accListData) {
            Map<String, Object> accData = (Map<String, Object>) obj;
            String name = (String) accData.get('Name');
            String website = (String) accData.get('Website');
            if (name == null || website == null) continue;
            
            String key = name + '|' + website;
            
            if (existingAccMap.containsKey(key)) {
                // Existing record found -> merge fields
                Account existingAcc = existingAccMap.get(key);
                mergeFields(existingAcc, accData);
                if (!toUpdate.contains(existingAcc)) {
                    toUpdate.add(existingAcc);
                }
            } else {
                // New record case
                if (!newAccConsolidated.containsKey(key)) {
                    Account newAcc = new Account();
                    mergeFields(newAcc, accData);
                    newAccConsolidated.put(key, newAcc);
                } else {
                    Account mergedAcc = newAccConsolidated.get(key);
                    mergeFields(mergedAcc, accData);
                }
            }
        }
        
        // Final insert & update
        toInsert.addAll(newAccConsolidated.values());
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    
 
    private static void mergeFields(Account acc, Map<String, Object> accData) {
        for (String fieldName : accData.keySet()) {
            Object newValue = accData.get(fieldName);
            if (newValue == null) continue;
            
            try {
                // Skip Name/Website (used for duplicate key)
                if (fieldName == 'Name' || fieldName == 'Website') {
                    acc.put(fieldName, newValue); // required for insert
                    continue;
                }
                
                Object existingValue = acc.get(fieldName);
                
                if (existingValue == null || String.valueOf(existingValue).trim() == '') {
                    acc.put(fieldName, newValue);
                }
            } catch (Exception e) {
                // Ignore invalid fields (if JSON has a field not present in Salesforce)
                System.debug('Skipping field: ' + fieldName + ' - ' + e.getMessage());
            }
        }
    }
}