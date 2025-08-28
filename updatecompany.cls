public class updatecompany {
    public static void updateavgonc(List<Employee__c>elist){
        Set<id>comid = new Set<id>();
        set<id>eid = new set<id>();
        for(Employee__c e:elist){
            if(e.Company__c != null){
            comid.add(e.Company__c);
            }
        }
        List<AggregateResult>alist = [select Company__c,avg(AVG_rating__c)avg from Employee__c where id in :eid group by Company__c];
        map<id,Decimal>compwithavg = new   map<id,Decimal>();
        for(aggregateResult a:alist){
            compwithavg.put((id)a.get('Company__c'),(Decimal)a.get('avg'));
        }
        List<Company__c>clist = [select id,Avg_employee_rating__c from Company__c where id in :comid];
        List<Company__c>updatelist = new   List<Company__c>();
        for(Company__c c:clist){
        c.Avg_employee_rating__c = compwithavg.get(c.id);
            updatelist.add(c);
    }
        update updatelist;
}
}