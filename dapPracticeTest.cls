public with sharing class dapPracticeTest {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts( List<String> selectedFields, String searchKeyword, String sortBy, String sortDirection
    ) {
       
        if (selectedFields == null || selectedFields.isEmpty()) {
            selectedFields = new List<String>{'Name', 'CreatedDate'};
        }

        if (!selectedFields.contains('Id')) {
            selectedFields.add('Id');
        }

        String query = 'SELECT ' + String.join(selectedFields, ',') + ' FROM Contact';

        if (searchKeyword != null && searchKeyword.trim() != '') {
            query += ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\'';
        }

        if (sortBy != null && sortBy != '') {
            String direction = (sortDirection != null && sortDirection.toLowerCase() == 'desc') ? 'DESC' : 'ASC';
            query += ' ORDER BY ' + sortBy + ' ' + direction;
        }

        System.debug('Final Query: ' + query);

        try {
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
        }
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
}