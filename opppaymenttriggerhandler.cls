public class opppaymenttriggerhandler {
    public static void handleAfterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Id> eligibleOppIds = new List<Id>();

        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            Boolean becameClosedWon = opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won';
            Boolean hasEmail = String.isNotBlank(opp.Email__c);

            if (becameClosedWon && hasEmail) {
                eligibleOppIds.add(opp.Id);
            }
        }

        if (!eligibleOppIds.isEmpty()) {
            Map<Id, Integer> oppProductCounts = new Map<Id, Integer>();

            for (AggregateResult ar : [SELECT OpportunityId, COUNT(Id) total FROM OpportunityLineItem
                                       WHERE OpportunityId IN :eligibleOppIds GROUP BY OpportunityId]) {
                                           
                oppProductCounts.put((Id) ar.get('OpportunityId'), (Integer) ar.get('total'));
            }

            for (Id oppId : eligibleOppIds) {
                if (oppProductCounts.containsKey(oppId) && oppProductCounts.get(oppId) > 0) {
                    StripeService.generatePaymentLink(oppId);
                }
            }
        }
    }
}