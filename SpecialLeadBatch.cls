global class SpecialLeadBatch implements Database.Batchable<SObject>, Database.Stateful {
    Integer specialLeadCount = 0;
    Map<String, Integer> referralLeadCount = new Map<String, Integer>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Company, Company_Size__c, City__c, Email, Industry, OwnerId,
                                          Referral_Person_Email__c, Special_Lead__c FROM Lead WHERE CreatedDate = TODAY]);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : scope) {
            ownerIds.add(l.OwnerId);
        }
        Map<Id, User> users = new Map<Id, User>([SELECT Id, CreatedDate, IsActive FROM User WHERE Id IN :ownerIds]);
        for (Lead l : scope) {
            if (l.Company_Size__c > 500 && isTier1City(l.City__c) &&
                countVowels(l.Company) >= 2 && users.containsKey(l.OwnerId) &&  isOwnerActiveFor25Days(l.OwnerId) ) {

                l.Special_Lead__c = true;
                specialLeadCount++;
                if (l.Referral_Person_Email__c != null) {
                    referralLeadCount.put(l.Referral_Person_Email__c,
                        referralLeadCount.containsKey(l.Referral_Person_Email__c) ? referralLeadCount.get(l.Referral_Person_Email__c) + 1 : 1);
                }
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('Success ');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<User> managers = [SELECT Email FROM User WHERE IsActive = true AND( Profile.Name = 'System Administrator' OR UserRole.Name = 'Manager')];
        for (User u : managers) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { u.Email });
            email.setSubject('Special Leads Processed');
            email.setPlainTextBody('Total Special Leads Identified: ' + specialLeadCount);
            emails.add(email);
        }
        for (String refEmail : referralLeadCount.keySet()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { refEmail });
            email.setSubject('Your Referred Leads Update');
            email.setPlainTextBody('Number of your leads marked Special: ' + referralLeadCount.get(refEmail));
            emails.add(email);
        }
        List<Messaging.SendEmailResult> SMR = Messaging.sendEmail(emails);
        
        
        for(Messaging.SendEmailResult MSR : SMR)
        {
            if(MSR.success )
            {
                system.debug('Mail Send Successfully');
            }
            else
            {
                system.debug('The Email Error is :- ' + MSR.errors[0].message);
            }
        }
    }

    public Boolean isTier1City(String city) {
        List<String> tier1Cities = new List<String>{'Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Hyderabad', 'Kolkata'};
            for(string s:tier1Cities)
            if(city == s){
                return true;
            }
            return false ;
    }

    public Integer countVowels(String str) {
        Integer count = 0;
        if (str != null) {
            for (Integer i = 0; i < str.length(); i++) {
                if ('aeiouAEIOU'.contains(String.valueOf(str.charAt(i)))) count++;
            }
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
}