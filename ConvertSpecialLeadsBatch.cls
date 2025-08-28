global class ConvertSpecialLeadsBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, LastModifiedDate, OwnerId
            FROM Lead
            WHERE Special_Lead__c = TRUE AND LastModifiedDate <= LAST_N_DAYS:5
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Lead> leads = (List<Lead>)scope;

        Set<Id> ownerIds = new Set<Id>();
        for (Lead lead : leads) {
            if (lead.OwnerId != null) {
                ownerIds.add(lead.OwnerId);
            }
        }

        Map<Id, User> ownerMap = new Map<Id, User>([
            SELECT Id, ManagerId FROM User WHERE Id IN :ownerIds
        ]);

        Set<Id> managerIds = new Set<Id>();
        for (User owner : ownerMap.values()) {
            if (owner.ManagerId != null) {
                managerIds.add(owner.ManagerId);
            }
        }

        Map<Id, User> managerMap = new Map<Id, User>([
            SELECT Id, Email FROM User WHERE Id IN :managerIds
        ]);

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Lead lead : leads) {
          
                User owner = ownerMap.get(lead.OwnerId);
                

                User manager = managerMap.get(owner.ManagerId);
             

                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(lead.Id);
                leadConvert.setConvertedStatus('Qualified');
                leadConvert.setDoNotCreateOpportunity(false);
                leadConvert.setOwnerId(lead.OwnerId);

                Database.LeadConvertResult convertedLead = Database.convertLead(leadConvert);

                if (convertedLead.isSuccess()) {
                    Id oppId = convertedLead.getOpportunityId();

                    if (oppId != null) {
                        Opportunity opp = new Opportunity(Id = oppId, OwnerId = manager.Id);
                        oppsToUpdate.add(opp);

                        Integer untouchedDays = Date.today().daysBetween(lead.LastModifiedDate.date());

                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] { manager.Email });
                        email.setSubject('Special Lead Converted');
                        email.setPlainTextBody(
                            'Lead ' + lead.Id + ' was converted after ' + untouchedDays +
                            ' days of no activity. Opportunity is now assigned to you.'
                        );
                        emails.add(email);
                    }
                }

           
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('ConvertSpecialLeadsBatch completed.');
    }
}