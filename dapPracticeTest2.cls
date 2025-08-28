public with sharing class dapPracticeTest2 {

    @AuraEnabled
    public static List<Contact> getContacts(
        List<String> selectedFields,
        List<Map<String, Object>> filters,
        String conjunction,
        String sortBy,
        String sortDirection
    ) {
        // Default field selection fallback
        String fieldStr = 'Id, Name';

        if (selectedFields != null && !selectedFields.isEmpty()) {
            List<String> cleanedFields = new List<String>();
            for (String f : selectedFields) {
                if (!String.isBlank(f)) {
                    cleanedFields.add(f.trim());
                }
            }

            if (!cleanedFields.isEmpty()) {
                fieldStr = String.join(cleanedFields, ', ');
                // Ensure Id is always included for lightning-datatable key field
                if (!cleanedFields.contains('Id')) {
                    fieldStr = 'Id, ' + fieldStr;
                }
            }
        }

        List<String> conditions = new List<String>();

        if (filters != null && !filters.isEmpty()) {
            for (Map<String, Object> filter : filters) {
                String field = (String)filter.get('field');
                String condition = (String)filter.get('condition');
                String value = (String)filter.get('value');

                if (!String.isBlank(field) && !String.isBlank(condition)) {
                    value = String.escapeSingleQuotes(value);

                    if (condition == 'LIKE') {
                        conditions.add(field + ' LIKE \'%' + value + '%\'');
                    } else if (condition == 'STARTS_WITH') {
                        conditions.add(field + ' LIKE \'' + value + '%\'');
                    } else if (condition == 'ENDS_WITH') {
                        conditions.add(field + ' LIKE \'%' + value + '\'');
                    } else if (condition == 'IN') {
                        List<String> parts = value.split(',');
                        List<String> quotedValues = new List<String>();
                        for (String val : parts) {
                            quotedValues.add('\'' + String.escapeSingleQuotes(val.trim()) + '\'');
                        }
                        conditions.add(field + ' IN (' + String.join(quotedValues, ', ') + ')');
                    } else {
                        conditions.add(field + ' ' + condition + ' \'' + value + '\'');
                    }
                }
            }
        }

        String whereClause = conditions.isEmpty()
            ? ''
            : ' WHERE ' + String.join(conditions, ' ' + conjunction + ' ');

        String query = 'SELECT ' + fieldStr + ' FROM Contact' + whereClause;

        if (!String.isBlank(sortBy)) {
            query += ' ORDER BY ' + sortBy;
            if (!String.isBlank(sortDirection)) {
                query += ' ' + sortDirection;
            }
        }

        System.debug('Final SOQL Query: ' + query);

        List<Contact> contacts = Database.query(query);

        // Flatten relationship field if selected
        if (selectedFields.contains('Account.Name')) {
            for (Contact c : contacts) {
                if (c.Account != null) {
                    c.put('AccountName', c.Account.Name);
                } else {
                    c.put('AccountName', '');
                }
            }
        }

        return contacts;
    }

    @AuraEnabled
    public static void updateContacts(List<Contact> contactsToUpdate) {
        if (contactsToUpdate != null && !contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (Exception e) {
                throw new AuraHandledException('Error updating contacts: ' + e.getMessage());
            }
        }
    }

    // Optional: Export All Fields Utility
    public static List<Contact> exportAllContactFieldData() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        List<String> fieldNames = new List<String>();

        for (String fieldName : fieldMap.keySet()) {
            fieldNames.add(fieldName);
        }

        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM Contact';
        System.debug('Export All Contact SOQL: ' + query);

        return Database.query(query);
    }
}