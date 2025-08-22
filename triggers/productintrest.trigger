trigger productintrest on ProductInterest__c (after insert) {


   List<ProductInterest__c> interestList = trigger.new;
        Set<Id> contactIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for (ProductInterest__c pi : interestList) {
            if (pi.Contact__c != null) contactIds.add(pi.Contact__c);
            if (pi.Product__c != null) productIds.add(pi.Product__c);
        }

        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, OwnerId FROM Contact WHERE Id IN :contactIds]
        );

       
        Map<Id, Product2> productMap = new Map<Id, Product2>(
            [SELECT Id, Name FROM Product2 WHERE Id IN :productIds]
        );

        List<Task> tasksToCreate = new List<Task>();

        for (ProductInterest__c pi : interestList) {
            Contact con = contactMap.get(pi.Contact__c);
            Product2 prod = productMap.get(pi.Product__c);

            if (con != null && prod != null) {
                Task t = new Task();
                t.OwnerId = con.OwnerId;
                t.Subject = 'Reach out about ' + prod.Name;
                t.Status = 'Not Started';
                t.Priority = 'Medium';
                t.ActivityDate = Date.today().addDays(3);
                t.WhatId = pi.Id; 
                tasksToCreate.add(t);
            }
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
}