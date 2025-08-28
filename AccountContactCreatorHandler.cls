public class AccountContactCreatorHandler {
    public static void createContactsForAccounts(List<Account> newAccounts) {
        system.debug('inside the class after trigger call');
        List<Contact> contactstoInsert = new List<Contact>();

     
        String profileId = UserInfo.getProfileId();
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

     
        Profile accountexecutive = [SELECT Id, Name FROM Profile WHERE Name = 'Account Executive'];

        for (Account acc : newAccounts) {
            
            // Check if the user is Account exctive
            if (currentUserProfile.Name == accountexecutive.Name) {
                system.debug('inside the conditon if accountexecutive profile');
                if (acc.No_of_Contact__c != null && acc.No_of_Contact__c > 0) {
                    for (Integer i = 0; i < acc.No_of_Contact__c; i++) {
                        Contact newCon = new Contact();
                        newCon.AccountId = acc.Id;
                        newCon.LastName = acc.Name + ' Contact ' + (i + 1);
                        contactstoInsert.add(newCon);
                    }
                }
            }
        }

      
        if (!contactstoInsert.isEmpty()) {
            try {
                insert contactstoInsert;
            } catch (Exception e) {
                System.debug('Errorrr : ' + e.getMessage());
               
            }
        }
    }
}