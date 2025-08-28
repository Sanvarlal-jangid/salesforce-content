global class ProductInterestEscalationBatch implements Database.Batchable<sObject>, Schedulable {


    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ProductInterestEscalationBatch());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime sevenDaysAgo = System.today().addDays(-7);

        return Database.getQueryLocator([
            SELECT Id, Contact__c, Opportunity__c, Product__c, Status__c, CreatedDate,
                   Contact__r.OwnerId,
                   Product__r.Name
            FROM ProductInterest__c
            WHERE (Status__c = 'New' OR Status__c = 'Contacted')
              AND CreatedDate < :sevenDaysAgo
        ]);
    }

    global void execute(Database.BatchableContext bc, List<ProductInterest__c> scope) {
        Set<Id> interestIds = new Set<Id>();
        for (ProductInterest__c pi : scope) {
            interestIds.add(pi.Id);
        }

        // Query existing escalation tasks once
        List<Task> existingTasks = [
            SELECT WhatId
            FROM Task
            WHERE WhatId IN :interestIds
              AND Subject LIKE 'Escalation: Urgent follow-up on%'
              AND ActivityDate >= :Date.today()
        ];

        Set<Id> alreadyEscalated = new Set<Id>();
        for (Task t : existingTasks) {
            alreadyEscalated.add(t.WhatId);
        }

        Map<Id, List<Task>> ownerTaskMap = new Map<Id, List<Task>>();
        List<ProductInterest__c> toUpdateStatus = new List<ProductInterest__c>();

        for (ProductInterest__c pi : scope) {
            if (!alreadyEscalated.contains(pi.Id)) {
                Id ownerId = pi.Contact__r.OwnerId;

                Task t = new Task();
                t.OwnerId = ownerId;
                t.Subject = 'Escalation: Urgent follow-up on ' + pi.Product__r.Name;
                t.Status = 'Not Started';
                t.Priority = 'High';
                t.ActivityDate = Date.today().addDays(2);
                t.WhatId = pi.Id;

                if (!ownerTaskMap.containsKey(ownerId)) {
                    ownerTaskMap.put(ownerId, new List<Task>());
                }
                ownerTaskMap.get(ownerId).add(t);

                pi.Status__c = 'No Response';
                toUpdateStatus.add(pi);
            }
        }

        List<Task> allTasks = new List<Task>();
        for (List<Task> taskList : ownerTaskMap.values()) {
            allTasks.addAll(taskList);
        }

        if (!allTasks.isEmpty()) insert allTasks;
        if (!toUpdateStatus.isEmpty()) update toUpdateStatus;
    }

    global void finish(Database.BatchableContext bc) {

    }
}