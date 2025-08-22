trigger RewardPointTrigger on Reward_Point__c (after insert, after update) {

    // Step 1: Collect all affected Account IDs
    Set<Id> accountIds = new Set<Id>();
    for (Reward_Point__c rp : Trigger.new) {
        if (rp.Account__c != null) {
            accountIds.add(rp.Account__c);
        }
    }

    // Step 2: Get all Reward Points for those Accounts
    List<Reward_Point__c> allPoints = [
        SELECT Account__c, Points__c, Status__c
        FROM Reward_Point__c
        WHERE Account__c IN :accountIds
    ];

    // Step 3: Create maps to summarize point values
    Map<Id, Decimal> earnedPoints = new Map<Id, Decimal>();
    Map<Id, Decimal> redeemedPoints = new Map<Id, Decimal>();
    Map<Id, Decimal> expiredPoints = new Map<Id, Decimal>();

    for (Reward_Point__c rp : allPoints) {
        Id accId = rp.Account__c;
        Decimal pts = rp.Points__c;

        if (rp.Status__c == 'Earned') {
            if (!earnedPoints.containsKey(accId)) {
                earnedPoints.put(accId, pts);
            } else {
                earnedPoints.put(accId, earnedPoints.get(accId) + pts);
            }
        }

        if (rp.Status__c == 'Redeemed') {
            if (!redeemedPoints.containsKey(accId)) {
                redeemedPoints.put(accId, pts);
            } else {
                redeemedPoints.put(accId, redeemedPoints.get(accId) + pts);
            }
        }

        if (rp.Status__c == 'Expired') {
            if (!expiredPoints.containsKey(accId)) {
                expiredPoints.put(accId, pts);
            } else {
                expiredPoints.put(accId, expiredPoints.get(accId) + pts);
            }
        }
    }

    // Step 4: Update summary fields on Account
    List<Account> accountsToUpdate = new List<Account>();

    for (Id accId : accountIds) {
        Decimal earned = earnedPoints.containsKey(accId) ? earnedPoints.get(accId) : 0;
        Decimal redeemed = redeemedPoints.containsKey(accId) ? redeemedPoints.get(accId) : 0;
        Decimal expired = expiredPoints.containsKey(accId) ? expiredPoints.get(accId) : 0;
        Decimal available = earned - redeemed - expired;

        Account acc = new Account();
        acc.Id = accId;
        acc.Total_Earned__c = earned;
        acc.Total_Redeemed__c = redeemed;
        acc.Total_Expired__c = expired;
        acc.Available_Points__c = available;

        accountsToUpdate.add(acc);
    }

    // Step 5: Save changes
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}