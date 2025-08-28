public class orderitemmshandler {

    public static void rollup(set<id>orderids){
List<AggregateResult> aggregateResults = [SELECT Orderr__c, SUM(product_price__c) totalAmount FROM OrderItemss__c WHERE Orderr__c IN :orderids 
                                               group by  Orderr__c];   
        
        map<id,decimal>idtototalamount = new map<id,decimal>();
        for(AggregateResult  ar:aggregateResults){
            idtototalamount.put((id)ar.get('Orderr__c'),(decimal) ar.get('totalAmount'));
        }
        
        list<Orderr__c>olist = [select id,Total_Amount__c from Orderr__c where id in:orderids];
        
        List<Orderr__c>updateorder =new list<Orderr__c>();
        
        for(Orderr__c ol:olist){
            Orderr__c o = new Orderr__c();
            o.id = ol.id;
            o.Total_Amount__c = idtototalamount.get(ol.id);
            updateorder.add(o);
        }
        update updateorder;
    }
}