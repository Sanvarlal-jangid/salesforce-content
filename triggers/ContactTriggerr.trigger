trigger ContactTriggerr on Contact (after insert, after update) {

    Set<Id> contactsForHubSpotCreateUpdate = new Set<Id>();
    Set<Id> contactsForHubSpotDelete = new Set<Id>();

    if (Trigger.isInsert) {
        for (Contact newContact : Trigger.new) {
            if (newContact.AccountId == null) {
                contactsForHubSpotCreateUpdate.add(newContact.Id);
            }
        }
    }

    if (Trigger.isUpdate) {
        for (Contact newContact : Trigger.new) {
            Contact oldContact = Trigger.oldMap.get(newContact.Id);

 
            if (oldContact.AccountId == null && newContact.AccountId != null) {
                contactsForHubSpotDelete.add(newContact.Id);
            }
       
            else if (oldContact.AccountId != null && newContact.AccountId == null ||
                     oldContact.AccountId == null && newContact.AccountId == null) {
                contactsForHubSpotCreateUpdate.add(newContact.Id);
            }
        }
    }

 
    if (!contactsForHubSpotCreateUpdate.isEmpty()) {
        HubSpotContactManager.applybatch(contactsForHubSpotCreateUpdate);
    }

    if (!contactsForHubSpotDelete.isEmpty()) {
        deletecontactclass.applybatch(contactsForHubSpotDelete);
    }

}