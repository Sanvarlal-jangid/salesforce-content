@RestResource(urlMapping='/TaxReturnSync')
global with sharing class TaxReturnService {

    // Input JSON wrappers
    global class TaxRecord {
        public String Amount;
        public String Month;
        public Long external_id;
    }

    global class ContactRequestWrapper {
        public String Name;
        public String Email;
        public List<TaxRecord> Salaries;
    }

    // Output JSON
    global class ErrorItem {
        public String record;
        public String error;
        public ErrorItem(String record, String error) {
            this.record = record;
            this.error = error;
        }
    }

    global class UpsertResponse {
        public Integer SuccessCount = 0;
        public Integer FailedCount = 0;
        public List<ErrorItem> Records = new List<ErrorItem>();
    }

    @HttpPost
    global static UpsertResponse processIncomingData() {
        UpsertResponse response = new UpsertResponse();
        RestRequest req = RestContext.request;

        List<ContactRequestWrapper> inputList;
        try {
            String requestBody = req.requestBody.toString();
            inputList = (List<ContactRequestWrapper>) JSON.deserialize(requestBody, List<ContactRequestWrapper>.class);
        } catch (Exception e) {
            response.FailedCount = 1;
            response.Records.add(new ErrorItem('ALL', 'Invalid JSON format'));
            return response;
        }

        // Step 1: Collect all Emails and External IDs
        Set<String> emails = new Set<String>();
        Set<Long> externalIds = new Set<Long>();
        for (ContactRequestWrapper c : inputList) {
            if (!String.isBlank(c.Email)) {
                emails.add(c.Email);
            }
            if (c.Salaries != null) {
                for (TaxRecord t : c.Salaries) {
                    if (t.external_id != null) {
                        externalIds.add(t.external_id);
                    }
                }
            }
        }

        // Step 2: Query existing records
        Map<String, Contact> existingContacts = new Map<String, Contact>();
        for (Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
            existingContacts.put(c.Email, c);
        }

        Map<Long, Tax_return__c> existingTaxReturns = new Map<Long, Tax_return__c>();
        for (Tax_return__c t : [SELECT Id, External_Id_c__c FROM Tax_return__c WHERE External_Id_c__c IN :externalIds]) {
            existingTaxReturns.put((Long)t.External_Id_c__c, t);
        }

        // Step 3: Prepare Contacts for upsert
        List<Contact> contactsToInsert = new List<Contact>();
        Map<String, Contact> emailToNewContact = new Map<String, Contact>();

        for (ContactRequestWrapper cw : inputList) {
            if (String.isBlank(cw.Email)) {
                response.FailedCount++;
                response.Records.add(new ErrorItem(cw.Name, 'Missing Email'));
                continue;
            }

            if (!existingContacts.containsKey(cw.Email)) {
                Contact newCon = new Contact();
                newCon.Email = cw.Email;
                newCon.LastName = String.isBlank(cw.Name) ? 'Unknown' : cw.Name;
                contactsToInsert.add(newCon);
                emailToNewContact.put(cw.Email, newCon);
            }
        }

        insert contactsToInsert;
        response.SuccessCount += contactsToInsert.size();

        // Merge new contacts into map
        for (Contact c : contactsToInsert) {
            existingContacts.put(c.Email, c);
        }

        // Step 4: Prepare Tax_return__c records for insert/update
        List<Tax_return__c> taxUpserts = new List<Tax_return__c>();

        for (ContactRequestWrapper cw : inputList) {
            if (!existingContacts.containsKey(cw.Email)) {
                continue;
            }

            Id contactId = existingContacts.get(cw.Email).Id;

            if (cw.Salaries != null) {
                for (TaxRecord tr : cw.Salaries) {
                    if (String.isBlank(tr.Month) || String.isBlank(tr.Amount) || tr.external_id == null) {
                        response.FailedCount++;
                        response.Records.add(new ErrorItem(String.valueOf(tr.external_id), 'Missing required tax fields'));
                        continue;
                    }

                    Tax_return__c tax = existingTaxReturns.containsKey(tr.external_id)
                        ? existingTaxReturns.get(tr.external_id)
                        : new Tax_return__c(External_Id_c__c = tr.external_id);

                    tax.Month__c = tr.Month;
                    tax.Amount__c = Decimal.valueOf(tr.Amount);
                    tax.Contact__c = contactId;

                    taxUpserts.add(tax);
                }
            }
        }

        // Step 5: Upsert tax returns
        upsert taxUpserts External_Id_c__c;
        response.SuccessCount += taxUpserts.size();

        return response;
    }
}