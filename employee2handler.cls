public class employee2handler {
    public static void tocheckparent(List<Employee2__c> elist) {
        Set<Id> parentIds = new Set<Id>();

        for (Employee2__c e : elist) {
            if (e.Parent_employee__c != null) {
                parentIds.add(e.Parent_employee__c);
            }
        }

        List<Employee2__c> parentList = [ select Id, RecordTypeId from Employee2__c where Id IN :parentIds];

        Map<Id, Employee2__c> pidWithEmp = new Map<Id, Employee2__c>();
        for (Employee2__c p : parentList) {
            pidWithEmp.put(p.Id, p);
        }

        Id devRecordTypeId = Schema.SObjectType.Employee2__c.getRecordTypeInfosByName().get('Dev').getRecordTypeId();

        Id baRecordTypeId = Schema.SObjectType.Employee2__c.getRecordTypeInfosByName().get('BA').getRecordTypeId();

        for (Employee2__c e : elist) {
            if (e.Parent_employee__c != null && e.RecordTypeId == devRecordTypeId) {
                Employee2__c par = pidWithEmp.get(e.Parent_employee__c);
                if (par != null && par.RecordTypeId == devRecordTypeId) {
                    e.Parent_employee__c.addError('dev child doesnt have dev parent');
                }
            }
        }
    }
    
public static void onlyOneChild(List<Employee2__c> elist) {
    Set<Id> parentIds = new Set<Id>();
    Set<Id> currentIds = new Set<Id>();
    Map<Id, Integer> newCount = new Map<Id, Integer>();

    for (Employee2__c e : elist) {
        if (e.Parent_employee__c != null) {
            parentIds.add(e.Parent_employee__c);
            Integer count = newCount.containsKey(e.Parent_employee__c) ? newCount.get(e.Parent_employee__c) : 0;
            newCount.put(e.Parent_employee__c, count + 1);
        }
        if (e.Id != null) currentIds.add(e.Id);
    }

    Map<Id, Integer> existingCount = new Map<Id, Integer>();
    for (AggregateResult ar : [
        SELECT Parent_employee__c pid, COUNT(Id) cnt
        FROM Employee2__c
        WHERE Parent_employee__c IN :parentIds
        GROUP BY Parent_employee__c
    ]) {
        existingCount.put((Id)ar.get('pid'), (Integer)ar.get('cnt'));
    }

    // Adjust for current records being updated
    for (Employee2__c e : elist) {
        if (e.Id != null && e.Parent_employee__c != null && existingCount.containsKey(e.Parent_employee__c)) {
            existingCount.put(e.Parent_employee__c, existingCount.get(e.Parent_employee__c) - 1);
        }
    }

    for (Employee2__c e : elist) {
        if (e.Parent_employee__c != null) {
            Integer existing = existingCount.containsKey(e.Parent_employee__c) ? existingCount.get(e.Parent_employee__c) : 0;
            Integer incoming = newCount.containsKey(e.Parent_employee__c) ? newCount.get(e.Parent_employee__c) : 0;
            if (existing + incoming > 1) {
                e.addError('A parent cannot have more than one child.');
            }
        }
    }
}


    public static void updatefields(List<Employee2__c>elist){
           Set<Id> parentIds = new Set<Id>();

        for (Employee2__c e : elist) {
            if (e.Parent_employee__c != null) {
                parentIds.add(e.Parent_employee__c);
            }
        }
        if(parentids.isEmpty()) return;
        List<Employee2__c> parentList = [ select Id,Name, RecordTypeId ,Dev_score__c,Max_BA_score__c,Max_Dev_score__c,Sum_BA_score__c,Sum_Dev_score__c from Employee2__c where Id IN :parentIds];

        Map<Id, Employee2__c> pidWithparent = new Map<Id, Employee2__c>();
        for (Employee2__c p : parentList) {
            pidWithparent.put(p.Id, p);
        } 
        
        Id devRecordTypeId = Schema.SObjectType.Employee2__c.getRecordTypeInfosByName().get('Dev').getRecordTypeId();

        Id baRecordTypeId = Schema.SObjectType.Employee2__c.getRecordTypeInfosByName().get('BA').getRecordTypeId();
        
        List<Employee2__c>updatelist = new List<Employee2__c>();
        
        
        for(Employee2__c e:elist){
          
            

            if(e.Parent_employee__c != null ){
                Employee2__c papa = pidWithparent.get(e.Parent_employee__c);
              
                
                system.debug(papa);
                if(papa.RecordTypeId == devRecordTypeId){
                if(e.RecordTypeId == baRecordTypeId ){
                    papa.Max_Dev_score__c = e.Max_Dev_score__c;
                    papa.Sum_Dev_score__c = e.Sum_Dev_score__c;
                    papa.Max_BA_score__c = Math.Max(e.Max_BA_score__c,e.BA_score__c);
                    papa.Sum_BA_score__c = e.BA_score__c + e.Sum_BA_score__c;
                    
                }
                
                    
                }else if (papa.RecordTypeId == baRecordTypeId){
                    system.debug('this is in conditon in if parent is ba'+ papa.Name);
                    if(e.RecordTypeId == baRecordTypeId){
                        papa.Max_Dev_score__c = e.Max_Dev_score__c;
                        papa.Max_BA_score__c = math.max(e.Max_BA_score__c,e.BA_score__c);
                        papa.Sum_BA_score__c = e.BA_score__c + e.Sum_BA_score__c;
                        papa.Sum_Dev_score__c = e.Sum_Dev_score__c;
                    }else{
                        system.debug('this is in conditon in if child is dev '+ e.Name);
                        papa.Max_Dev_score__c = math.max(e.Max_Dev_score__c , e.Dev_score__c);
                        papa.Max_BA_score__c = e.Max_BA_score__c;
                        papa.Sum_BA_score__c =  e.Sum_BA_score__c; 
                        papa.Sum_Dev_score__c = e.Sum_Dev_score__c + e.Dev_score__c;
                    }
                }
                updatelist.add(papa);
            }
        }
       update updatelist;
    }

}