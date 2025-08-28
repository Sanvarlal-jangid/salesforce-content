public class ShipmentCaseEmailHandler {

    public static void sendResolvedEmail(List<Shipment_Case__c> newCases, Map<Id, Shipment_Case__c> oldCasesMap) {
        set<string>ordernumbers = new set<string>();
        for(Shipment_Case__c s:newCases){
            if(s.Order_Number__c != null){
                ordernumbers.add(s.Order_Number__c);
            }
        }
        list<Orderr__c>olist = [select id,name,customer_email__c,Total_Amount__c from Orderr__c where name in:ordernumbers];
        
        map<string,string>numbertoemail = new map<string,string>();
        for(Orderr__c o:olist){
            if(o.customer_email__c != null){
            numbertoemail.put(o.name,o.customer_email__c);
                }
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Shipment_Case__c newCase : newCases) {
            Shipment_Case__c oldCase = oldCasesMap.get(newCase.Id);

            if (newCase.Case_status__c == 'Resolved' && oldCase.Case_status__c != 'Resolved') {
                
                

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                String emailPlainTextBody = '';
                emailPlainTextBody += 'Dear ' +newCase.Customer_Name__c+'\n\n';
                emailPlainTextBody += 'We\'re delighted to inform you that your Shipment Case with the title "' + (string) newCase.Case_Title__c + '" and ID #' + newCase.Id + ' has been successfully resolved.\n\n';
                emailPlainTextBody += 'Case Details:\n';
                emailPlainTextBody += 'Case Title: ' + (string) newCase.Case_Title__c + '\n';
                emailPlainTextBody += 'Order Number: ' + newCase.Order_Number__c+ '\n';
                emailPlainTextBody += 'Case Status: Resolved\n\n';
                emailPlainTextBody += 'If you have any further questions or concerns, please don\'t hesitate to reach out. We appreciate your patience.\n\n';
                emailPlainTextBody += 'Best regards,\n\n';
                emailPlainTextBody += 'United Goods\n';
                emailPlainTextBody += 'Customer Support Team\n\n';


                mail.setPlainTextBody(emailPlainTextBody);


                mail.setSubject('Your Shipment Case: ' + newCase.Case_Title__c + ' has been Resolved');

                List<String> toAddresses = new List<String>{numbertoemail.get(newCase.Order_Number__c)};
                mail.setToAddresses(toAddresses);

              

                emailsToSend.add(mail);
            }
        }

        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception e) {
                System.debug('Error sending emails: ' + e.getMessage());
            }
        }
    }
}