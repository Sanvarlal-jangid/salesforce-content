trigger triggerlead on Lead (before insert,after update) {
    if(trigger.isbefore && trigger.isinsert){
        
        
   List<Lead> incomingleads = trigger.new;
       Set<String> leadKeys = new Set<String>();
       Map<String, Lead> incomingMap = new Map<String, Lead>();

         for (Lead ld : incomingLeads) {
           if (ld.Email != null && ld.Company != null && ld.City != null && ld.Industry != null) {
           String domain = ld.Email.substringAfter('@').toLowerCase();
           String key = ld.Company.toLowerCase() + '|' + domain + '|' + ld.City.toLowerCase() + '|' + ld.Industry.toLowerCase();
           leadKeys.add(key);
            incomingMap.put(key, ld);
        } 
     }
         set<string>exist = new set<string>();
         Map<String, Lead> existingMap = new Map<String, Lead>();
        for (Lead ex : [ SELECT Id, Company, Email, City, Industry FROM Lead 
                WHERE Special_Lead__c = true AND Email != null AND Company != null AND City != null AND Industry != null]) {
         String exDomain = ex.Email.substringAfter('@').toLowerCase();
         String exKey = ex.Company.toLowerCase() + '|' + exDomain + '|' + ex.City.toLowerCase() + '|' + ex.Industry.toLowerCase();
                    exist.add(exKey);
         if (leadKeys.contains(exKey)) {
         existingMap.put(exKey, ex);
      }
   }


/*for (String key : existingMap.keySet()) {
    if (incomingMap.containsKey(key)) {
        incomingMap.get(key).addError('A Special Lead with matching details already exists. Lead ID: ' + existingMap.get(key).Id);
    }
}
*/
          for (Lead ld : incomingLeads) {
              if (ld.Email != null && ld.Company != null && ld.City != null && ld.Industry != null) {
           String domain = ld.Email.substringAfter('@').toLowerCase();
           String key = ld.Company.toLowerCase() + '|' + domain + '|' + ld.City.toLowerCase() + '|' + ld.Industry.toLowerCase();
                  if(exist.contains(key)){
                      ld.addError('A Special Lead with matching details already exists. Lead ID: ' + existingMap.get(key).Id);
                  }
              }
          }
    }
     if(trigger.isAfter && trigger.isupdate){
         
         List<Lead> newLeads = trigger.new;
         Map<Id, Lead> oldLeadMap =trigger.oldMap;
     List<Lead> leadsToUpdate = new List<Lead>();
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();

        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : newLeads) {
            ownerIds.add(l.OwnerId);
        }

        Map<Id, User> ownerMap = new Map<Id, User>([
            SELECT Id, ManagerId FROM User WHERE Id IN :ownerIds
        ]);

        for (Lead l : newLeads) {
            Lead oldL = oldLeadMap.get(l.Id);

       

            Integer daysDiff = Date.today().daysBetween(l.LastModifiedDate.date());

            Lead updatedLead = new Lead(Id = l.Id);
            if (daysDiff <= 5) {
              

                User owner = ownerMap.get(l.OwnerId);
                if (owner != null && owner.ManagerId != null) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Lead updated recently. Approval needed.');
                    req.setObjectId(l.Id);
                    req.setNextApproverIds(new Id[] { owner.ManagerId });
                    approvalRequests.add(req);
                }
            } else {
                updatedLead.Lead_Status__c = 'Not Approved';
            }

            leadsToUpdate.add(updatedLead);
        }

        if (!leadsToUpdate.isEmpty()) update leadsToUpdate;
        if (!approvalRequests.isEmpty()) {
            for (Approval.ProcessSubmitRequest req : approvalRequests) {
                Approval.ProcessResult result = Approval.process(req);
                System.debug('Approval submitted for Lead: ' + req.getObjectId());
            }
        }
}
}



/*
trigger triggerlead on Lead (before insert) {
    if (trigger.isBefore && trigger.isInsert) {
        
        Set<String> existkey = new Set<String>();
        Map<String, Id> existingSpecialLeadIds = new Map<String, Id>(); // Map to store existing Special Lead IDs
        
        // Query for existing Special Leads and populate the set and map
        for (Lead ex : [ SELECT Id, Company, Email, City, Industry FROM Lead 
                         WHERE Special_Lead__c = true AND Email != null AND Company != null AND City != null AND Industry != null]) {
            String exDomain = ex.Email.substringAfter('@').toLowerCase();
            String exKey = ex.Company.toLowerCase() + '|' + exDomain + '|' + ex.City.toLowerCase() + '|' + ex.Industry.toLowerCase();
            existkey.add(exKey); 
            existingSpecialLeadIds.put(exKey, ex.Id);
        }
        
        List<Lead> incomingleads = trigger.new;
        for (Lead ld : incomingleads) {
            if (ld.Email != null && ld.Company != null && ld.City != null && ld.Industry != null) {
                String domain = ld.Email.substringAfter('@').toLowerCase();
                String currentLeadKey = ld.Company.toLowerCase() + '|' + domain + '|' + ld.City.toLowerCase() + '|' + ld.Industry.toLowerCase();
                
               
                if (existkey.contains(currentLeadKey)) {
                   
                    ld.addError('A Special Lead with matching details already exists. Lead ID: ' + existingSpecialLeadIds.get(currentLeadKey)); // Add error to duplicate
                } else {
                  
                    if (ld.Company_Size__c > 500 && isTierOneCity(ld.City) && countVowels(ld.Company) >= 2 && isOwnerActiveFor25Days(ld.OwnerId) ) { 
                       // ld.Special_Lead__c = true;
                    }
                }
            }
        }
    }
}

public static Boolean isTierOneCity(String city) {
    List<String> tierCities = new List<String>{'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Ahmedabad','Pune'};
    return tierCities.contains(city);
}

public static Integer countVowels(String input) {
    Integer count = 0;
    for (Integer i = 0; i < input.length(); i++) {
        String ch = input.substring(i, i + 1).toLowerCase();
        if ('aeiou'.contains(ch)) count++;
    }
    return count;
}

public static boolean isOwnerActiveFor25Days(Id userId) {
    User user = [SELECT LastLoginDate FROM User WHERE Id = :userId LIMIT 1];
    if (user.LastLoginDate != null) {
        Date twentyFiveDaysAgo = Date.today().addDays(-25);
        return user.LastLoginDate.date() >= twentyFiveDaysAgo;
    }
    return false;
}
*/