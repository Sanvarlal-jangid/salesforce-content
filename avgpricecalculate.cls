public class avgpricecalculate {
    
public static void updateaccountavg(List<OpportunityLineItem> oliList) {
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : oliList) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }


        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds]
        );

        Set<Id> accIds = new Set<Id>();
        for (Opportunity opp : oppMap.values()) {
            if (opp.AccountId != null) {
                accIds.add(opp.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        List<AggregateResult> aggResults = [SELECT Opportunity.AccountId accId, SUM(TotalPrice) totalSellingPrice,
                       SUM(Quantity) totalQuantity FROM OpportunityLineItem WHERE Opportunity.AccountId IN :accIds
                            AND TotalPrice >= 1000 GROUP BY Opportunity.AccountId];

        Map<Id, Decimal> avgMap = new Map<Id, Decimal>();
        for (AggregateResult ar : aggResults) {
            Id accId = (Id) ar.get('accId');
            Decimal total = (Decimal) ar.get('totalSellingPrice');
            Decimal qty = (Decimal) ar.get('totalQuantity');
            avgMap.put(accId, qty > 0 ? total / qty : 0);
        }

        List<Account> updateList = new List<Account>();
       List<Account> accList = [SELECT Id, Average_Product_Price__c FROM Account WHERE Id IN :accIds];
           for (Account acc : accList) {
                  acc.Average_Product_Price__c = avgMap.get(acc.Id);
                           updateList.add(acc);

                }

        
        if (!accList.isEmpty()) {
            update updateList;
        }
    }


}