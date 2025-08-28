public class totalrevenueonopp {
    public static void updateaccounttotalrevenue(List<opportunity>opplist){
        Set<id>accids = new Set<id>();
        for(opportunity opp:opplist){
            if(opp.accountid!=null && opp.amount!=null){
                accids.add(opp.accountid);
            }
        }
        system.debug(accids);
        List<AggregateResult>result=[select accountid,sum(amount)sumopp from opportunity where accountid in :accids group by accountid];
        Map<id,Decimal>sumofopportunity = new Map<id,Decimal>();
        
        for(aggregateResult ar : result){
            sumofopportunity.put((id)ar.get('accountid'),(Decimal)ar.get('sumopp'));
        }
                                 
        List<Account>acclist = [select id ,AnnualRevenue, Status__c, Target_Amount__c from account where id in :accids];
        
        List<Account>updatelist = new List<Account>();
        for(account acc:acclist){
            if(sumofopportunity.containskey(acc.Id)){
                acc.AnnualRevenue=sumofopportunity.get(acc.id);
                if(acc.Target_Amount__c < sumofopportunity.get(acc.id))
                {
                    acc.Status__c = 'Complete';
                }
                else
                {
                    acc.Status__c = 'open';
                }
                updatelist.add(acc);
                
            }
            Database.SaveResult[] resultupdat = database.update(updatelist,false);
        }
        
    }
    /**
     public static void checkAmount(List<Account> accList) {
       
         Set<Id>aboveTarget=new Set<Id>();
        Set<Id>belowTarget=new Set<Id>();

        for (Account a:accList) {
            if (a.AnnualRevenue != null && a.Target_Amount__c != null) {
                if (a.AnnualRevenue > a.Target_Amount__c) {
                    aboveTarget.add(a.id);
                } else {
                    belowTarget.add(a.id);
                }
            }
        }

        List<Account>accsToUpdateComplete=[select Id, Status__c from Account WHERE Id in :aboveTarget];
         
        for (Account acc:accsToUpdateComplete) {
            acc.Status__c='complete';
        }

        List<Account>accsToUpdateOpen=[select Id, Status__c from Account where Id in :belowTarget];
        for (Account acc:accsToUpdateOpen) {
            acc.Status__c = 'open';
        }

         if (!accsToUpdateComplete.isEmpty()){
             update accsToUpdateComplete;
         }
         if (!accsToUpdateOpen.isEmpty()){
         update accsToUpdateOpen;
         } 
    } */
}