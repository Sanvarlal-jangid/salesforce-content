trigger olitrigger on OpportunityLineItem (before insert,after insert) {
    if(trigger.isBefore && trigger.isInsert){
       List<OpportunityLineItem> oliList = trigger.new;
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : oliList) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }
          
   
        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds];
        Map<Id, Id> oppToAccountMap = new Map<Id, Id>();
        for (Opportunity opp : oppList) {
            if(opp.AccountId != null){
            oppToAccountMap.put(opp.Id, opp.AccountId);
            }
        }

      
        List<Contact> contacts = [SELECT Id, AccountId, Is_Primary__c FROM Contact WHERE  AccountId IN :oppToAccountMap.values() ];
       Map<Id, Boolean> accountHasPrimaryContact = new Map<Id, Boolean>();
        for (Contact con : contacts) {
            if (con.Is_Primary__c) {
                accountHasPrimaryContact.put(con.AccountId, true);
            }
        }

   
        for (OpportunityLineItem oli : oliList) {
            Id accId = oppToAccountMap.get(oli.OpportunityId);
            if (!accountHasPrimaryContact.containsKey(accId)) {
                oli.addError('Primary contact is missing for the related account.');
            }
        }
    }

   
    
      if(trigger.isAfter && trigger.isInsert){
         List<OpportunityLineItem> oliList = trigger.new;
        Set<Id> oppIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for (OpportunityLineItem oli : oliList) {
            if (oli.OpportunityId != null) oppIds.add(oli.OpportunityId);
            if (oli.Product2Id != null) productIds.add(oli.Product2Id);
        }


        List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds];
        Map<Id, Id> oppToAccountMap = new Map<Id, Id>();
        for (Opportunity opp : oppList) {
            oppToAccountMap.put(opp.Id, opp.AccountId);
        }

        List<Contact> contacts = [SELECT Id, AccountId, Is_Primary__c FROM Contact WHERE AccountId IN :oppToAccountMap.values()];
        Map<Id, Contact> accountPrimaryContactMap = new Map<Id, Contact>();
        for (Contact con : contacts) {
            if (con.Is_Primary__c) {
                accountPrimaryContactMap.put(con.AccountId, con);
            }
        }

        Set<String> keys = new Set<String>();
        Map<OpportunityLineItem, Contact> oliToContact = new Map<OpportunityLineItem, Contact>();
        for (OpportunityLineItem oli : oliList) {
            Id accId = oppToAccountMap.get(oli.OpportunityId);
            Contact con = accountPrimaryContactMap.get(accId);
            if (con != null) {
                String key = con.Id + '-' + oli.OpportunityId + '-' + oli.Product2Id;
                keys.add(key);
                oliToContact.put(oli, con);
            }
        }

        List<ProductInterest__c> existingRecords = [
            SELECT Contact__c, Opportunity__c, Product__c FROM ProductInterest__c
            WHERE Opportunity__c IN :oppIds AND Product__c IN :productIds
        ];

        Set<String> existingKeys = new Set<String>();
        for (ProductInterest__c pi : existingRecords) {
            String key = pi.Contact__c + '-' + pi.Opportunity__c + '-' + pi.Product__c;
            existingKeys.add(key);
        }

        List<ProductInterest__c> newRecords = new List<ProductInterest__c>();
        for (OpportunityLineItem oli : oliList) {
            Contact con = oliToContact.get(oli);
            if (con != null) {
                String key = con.Id + '-' + oli.OpportunityId + '-' + oli.Product2Id;
                if (!existingKeys.contains(key)) {
                    ProductInterest__c pi = new ProductInterest__c(
                        Contact__c = con.Id,
                        Opportunity__c = oli.OpportunityId,
                        Product__c = oli.Product2Id,
                        Status__c = 'New'
                    );
                    newRecords.add(pi);
                }
            }
        }

        if (!newRecords.isEmpty()) {
            insert newRecords;
        }
    }
}