@RestResource(urlMapping='/mergeAccounts')
global with sharing class AccountDuplicate {

    public class AccountData {
        public String Name;
        public String Website;
        public String Type;
        public String Email;
        public String Phone;
        public String Industry;
    }

    public class AccountWrapper {
        public List<AccountData> Accounts;
    }

    @HttpPost
    global static void mergeAccountRecords() {
        RestRequest req = RestContext.request;
        String jsonBody = req.requestBody.toString();
        
        
   
        AccountWrapper wrapper = (AccountWrapper)JSON.deserialize(jsonBody, AccountWrapper.class);
        List<AccountData> accountList = wrapper.Accounts;
        system.debug('accountlsit'+accountList);
        
            
       Map<string,List<AccountData>>groupedAccounts = new Map<string,List<AccountData>>();
        
        Set<string>name = new Set<string>();
         Set<string>web = new Set<string>();
       for (AccountData acc : accountList) {
           
            if (String.isEmpty(acc.Name) || String.isEmpty(acc.Website)) continue;
               name.add(acc.Name);
               web.add(acc.Website);
            String key = acc.Name+ acc.Website;
            if (!groupedAccounts.containsKey(key)) {
                groupedAccounts.put(key, new List<AccountData>());
            }
            groupedAccounts.get(key).add(acc);
        }
       
        
         
         List<Account> existingAccounts = [
            SELECT Id, Name, Website, Type, Phone, Industry, Email__c FROM Account WHERE Name IN :name  AND Website IN :web];
        
            system.debug('existing accounts exist or not '+existingAccounts);
        
                Map<String, Account> existingAccountMap = new Map<String, Account>();
              for (Account acc : existingAccounts){
                   String key = acc.Name+acc.Website;
                     existingAccountMap.put(key, acc);
        }
        
        List<Account> accountstoInsert = new List<Account>();
        List<Account> accountstoUpdate = new List<Account>();
           
                Set<String> keys = groupedAccounts.keySet();
        
        for (String key : keys) {
            List<AccountData> duplicates = groupedAccounts.get(key);
            Account acc;

            if (existingAccountMap.containsKey(key)) {
                acc = existingAccountMap.get(key);
            } else {
                AccountData first = duplicates[0];
                acc = new Account();
                acc.Name = first.Name;
                acc.Website = first.Website;
                acc.Type = first.Type;
                acc.Phone = first.Phone;
                acc.Industry = first.Industry;
                acc.Email__c = first.Email;
                accountstoInsert.add(acc);
                continue; 
            }

            for (AccountData dup : duplicates) {
                if (String.isBlank(acc.Type) && dup.Type != null) acc.Type = dup.Type;
                if (String.isBlank(acc.Phone) && dup.Phone != null) acc.Phone = dup.Phone;
                if (String.isBlank(acc.Industry) && dup.Industry != null) acc.Industry = dup.Industry;
                if (String.isBlank(String.valueOf(acc.Email__c)) && dup.Email != null) acc.Email__c = dup.Email;
            }

            accountstoUpdate.add(acc);
        }

        if (!accountsToInsert.isEmpty()) insert accountsToInsert;
        if (!accountsToUpdate.isEmpty()) update accountsToUpdate;
      }

}