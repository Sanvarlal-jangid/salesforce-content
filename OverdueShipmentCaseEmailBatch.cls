global class OverdueShipmentCaseEmailBatch implements Database.Batchable<sObject>, Schedulable {

     
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator([SELECT Id, Case_Title__c, Name, Customer_name__c,Case_status__c, Order_Number__c, Resolution_field__c, Case_Age__c 
                                         FROM Shipment_Case__c WHERE Case_status__c ='open' AND CreatedDate < :System.today()]);
                                         //.addDays(-5)
    }

  
    global void execute(Database.BatchableContext BC, List<Shipment_Case__c> scope) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        list<Shipment_Case__c>updatelist = new list<Shipment_Case__c>();
        for(Shipment_Case__c c:scope){
            Shipment_Case__c temp = new Shipment_Case__c();
                   temp.id = c.id;
                 Date createdDate = c.CreatedDate.date();
                Date todayDate = Date.today();
                Integer daysBetween = createdDate.daysBetween(todayDate);  
             c.Case_Age__c = daysBetween;
            updatelist.add(temp);
        }
        update updatelist;
        
     list<Orderr__c>olist = [select id,name,customer_email__c,Total_Amount__c from Orderr__c];
        
        map<string,string>numbertoemail = new map<string,string>();
        for(Orderr__c o:olist){
            if(o.customer_email__c != null){
            numbertoemail.put(o.name,o.customer_email__c);
                }
        }
        for (Shipment_Case__c currentCase : scope) {
            try {
               
                String recipientEmail =numbertoemail.get(currentCase.Order_Number__c);
                String recipientName =  currentCase.Customer_name__c;

                if (String.isNotBlank(recipientEmail)) {
                    Messaging.SingleEmailMessage email = createOverdueCaseEmail(currentCase, recipientEmail, recipientName);
                    if (email != null) {
                        emailsToSend.add(email);
                    }
                } else {
                    System.debug('Skipping email for Case ' + currentCase.Id + ': No valid recipient email found.');
                }
            } catch (Exception e) {
                System.debug('Error processing Case ' + currentCase.Id + ': ' + e.getMessage());
            }
        }

        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend, false); 
                System.debug('Successfully sent ' + emailsToSend.size() + ' overdue case emails.');
            } catch (Exception e) {
                System.debug('Error sending bulk emails: ' + e.getMessage());
            }
        }
    }

  
    global void finish(Database.BatchableContext BC) {
        System.debug('Overdue Shipment Case Email Batch finished successfully.');

    }

    global void execute(SchedulableContext SC) {

        Database.executeBatch(new OverdueShipmentCaseEmailBatch(), 100); 
    }
  global static void mymethod() {

        Database.executeBatch(new OverdueShipmentCaseEmailBatch(), 100); 
    }

  

  
    private static Messaging.SingleEmailMessage createOverdueCaseEmail(Shipment_Case__c c, String recipientEmail, String recipientName) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      

        Integer caseAgeDays = System.today().daysBetween(c.CreatedDate.date()); 
        mail.setSubject('hope this message finds you well. We would like to bring your attention to an open Shipment Case that requires immediate action');
        
        String emailBody = 'Dear ' + (String.isNotBlank(recipientName) ? recipientName : 'Case Owner') + ',\n\n';
        emailBody += 'I hope this message finds you well. We would like to bring your attention to an open Shipment Case that requires immediate action.\n\n';
        emailBody += 'Case Details:\n';
        emailBody += 'Case Title: ' + c.Case_Title__c + '\n';
        emailBody += 'Customer Name: ' + recipientName + '\n';
        emailBody += 'Order Number: ' + c.Order_Number__c+ '\n'; 
        emailBody += 'Case Status: ' + c.Case_status__c + '\n';
        emailBody += 'Case Age: ' + caseAgeDays + ' days\n\n';
        emailBody += 'Please take immediate action to resolve this case.';
        mail.setPlainTextBody(emailBody);

        

        mail.setToAddresses(new List<String>{recipientEmail});

        return mail;
    }
}