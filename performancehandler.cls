public class performancehandler {
    public static void updatedata(list<Performance__c>plist,list<Performance__c>olist){
        Set<id>empid = new Set<id>();
        Set<id>perid = new Set<id>();
        for(Performance__c p:plist){
            perid.add(p.Id);
            if(p.Employee__c != null){
                empid.add(p.Employee__c);
            }
        }
         for(Performance__c p:olist){
            perid.add(p.Id);
            if(p.Employee__c != null){
                empid.add(p.Employee__c);
            }
        }
        
        Map<Id, Performance__c> empIdAndPerformance = new Map<Id, Performance__c>();
        for(Performance__c p : pList){
            empIdAndPerformance.put(p.employee__c, p);
        }

        
        List<AggregateResult>result = [select Employee__c,avg(Rating__c)avg from Performance__c
                                       where id in :perid group by Employee__c];
        Map<id,Decimal>empwithavg = new Map<id,Decimal>();
        for(aggregateResult ar  : result){
            empwithavg.put((id)ar.get('Employee__c'),(Decimal)ar.get('avg'));
            
            
        }
        
        
        List<Employee__c>emplist = [select id,Name,Email__c,AVG_rating__c,Bonus__c,CTC__c,Monthly_pay__c from Employee__c where id in :empid];
        
        List<Employee__c>employeeToUpdate = new List<Employee__c>();
        for(Employee__c emp : emplist){
            emp.AVG_rating__c = empwithavg.get(emp.Id);
            if(emp.AVG_rating__c < 2){
                		Emp.Bonus__c = 0;
            		}
          	else if(emp.AVG_rating__c < 3 && emp.AVG_rating__c >= 2){
                		emp.Bonus__c = 5;
            		}
           	else if(emp.AVG_rating__c < 4 && emp.AVG_rating__c >= 3){
                		emp.Bonus__c = 10;
            		}
           	else if(emp.AVG_rating__c < 5 && emp.AVG_rating__c >= 4){
                		emp.Bonus__c = 15;
            		}
           	else if(emp.AVG_rating__c == 5){
                		emp.Bonus__c = 20;
            		}
            emp.CTC__c += emp.CTC__c * (emp.Bonus__c/100);
            emp.Monthly_pay__c = (emp.CTC__c * .70)/12;
            
            employeeToUpdate.add(emp);
            emailtoemployee.sendmail(emp.id, emp.Name, emp.Bonus__c, emp.CTC__c, emp.Monthly_pay__c,
                                     emp.AVG_rating__c, emp.Email__c,empIdAndPerformance);
        }
        Database.saveResult[] rs = database.update(employeeToUpdate, false);
       
        
        
        
    }
    
}