public class shipmentcasehandler {

    
    public static void populatecustomer(list<Shipment_Case__c>nlist){
        set<string>orderno = new set<string>();
        for(Shipment_Case__c s:nlist){
            if(s.Order_Number__c != null){
                orderno.add(s.Order_Number__c);
            }
        }
        system.debug('setof order'+orderno);
        list<Orderr__c>orderlist = [select id,Name ,Total_Amount__c,Customer__c,Order_Date__c from Orderr__c where Name like :orderno];
        map<string,string>notoname = new map<string,string>();
        for(Orderr__c o:orderlist){
            if(o.Customer__c != null){
                notoname.put(o.Name,o.Customer__c);
            }
        }
        for(Shipment_Case__c s:nlist){
            if(s.Order_Number__c != null){
                s.Case_status__c ='open';
                s.Customer_name__c = notoname.get(s.Order_Number__c);
                if((s.Resolution_field__c != null || !String.isBlank(s.Resolution_field__c)) && s.Order_Number__c != null){
                    s.Case_status__c='resolved';
                }

            }
        }
    }
    public static void updatestatus(list<Shipment_Case__c>newlist){
        
        list <Shipment_Case__c> nlist = [SELECT Id, Case_Title__c, Name, Case_status__c, Order_Number__c, Resolution_field__c, 
                                         Case_Age__c FROM Shipment_Case__c where id in:newlist];
        list<Shipment_Case__c>updatelist = new list<Shipment_Case__c>();
        
        for(Shipment_Case__c s:nlist){
            Shipment_Case__c  temp = new Shipment_Case__c();
            if((s.Resolution_field__c != null || !String.isBlank(s.Resolution_field__c)) && s.Order_Number__c != null){
                temp.id = s.id;
                temp.Case_status__c = 'resolved';
                updatelist.add(temp);
            }      
        }
        update updatelist;
    }
}