public class ContactTriggerHandler {
    
    public static void handleContactChanges(List<Contact> newList, List<Contact> oldList, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        

        Profile accountexecutive = [SELECT Id FROM Profile WHERE Name = 'Account Executive' LIMIT 1];
        if (UserInfo.getProfileId() != accountexecutive.Id) return;

     
        Set<Id> accountIds = new Set<Id>();
        if (isInsert || isUpdate) {
            for (Contact c : newList) if (c.AccountId != null) accountIds.add(c.AccountId);
        }
        if (isUpdate || isDelete) {
            for (Contact c : oldList) if (c.AccountId != null) accountIds.add(c.AccountId);
        }

  
        List<Account> accounts = [SELECT Id, Name, Email__c, No_of_Contact__c, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIds];

       
       List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Contact_Change_Log__c> logs = new List<Contact_Change_Log__c>();

     
        String changeType = isInsert ? 'Insert' : isUpdate ? 'Update' : 'Delete';

        // Get Lightning Email Template ID
 //       Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Alert_Mail_Template' LIMIT 1].Id;

        for (Account acc : accounts) {
            Integer actual = acc.Contacts.size();
            Integer expected = acc.No_of_Contact__c != null ? Integer.valueOf(acc.No_of_Contact__c) : 0;

            // Send email if contact count mismatch
            if (actual != expected && acc.Email__c != null) {
              /*    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                mail.setTargetObjectId(UserInfo.getUserId()); // Required for merge fields
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new String[] { acc.Email__c });
                mail.setWhatId(acc.Id); // Link to Account for merge fields
                emails.add(mail);*/
                
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { acc.Email__c });
                mail.setSubject('Alert for Account: ' + acc.Id);

                String body = 'Dear Customer,\n\n' +
                              'Please be informed that there has been an ' + changeType +
                              ' of contacts for your account with Account ID: ' + acc.Id + '.\n\n' +
                              'Thank you,\n' +
                              'LogisticsPro Management Team';

                mail.setPlainTextBody(body);
                emails.add(mail); 
            }

          
            logs.add(new Contact_Change_Log__c(
               
                Change_Type__c = changeType,
                Changed_By__c = UserInfo.getUserId(),
                Change_Time__c = System.now()
            ));

            // external notification bheji yha se
         
             WebhookNotifier.sendContactChangeNotification(acc.Id, actual, changeType);
        }

        if (!emails.isEmpty()) Messaging.sendEmail(emails);
        if (!logs.isEmpty()) insert logs;
    }
}