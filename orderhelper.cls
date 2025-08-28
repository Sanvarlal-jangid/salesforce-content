public class orderhelper {
    public static void handleorders(list<order>newlist,Map<Id,order>oldmap){
        Set<id>orderids = new Set<id>();
        for(order o:newlist){
            order t = oldmap.get(o.id);
            if(t.Status__c == 'Draft' && o.Status__c=='Processing'){
               orderids.add(o.Id);
            }
        }
        
        list<OrderItem>itemlist = [SELECT OrderId, Id, Product2Id, Quantity, UnitPrice, ListPrice,
                                   Total_Amount__c, Tax_Amount__c, Type__c, TotalPrice FROM OrderItem WHERE OrderId IN:orderids];
        
       
         list<orderitem>updateitemlist = new list<orderitem>();
        for(orderItem OT:itemlist){
            orderItem tempitem = new orderItem();
        decimal tax= TaxJarCalloutService.calculateSalesTax(OT.Id);
           
          
                    tempitem.Id=OT.id;
                   tempitem.Tax_Amount__c =tax;
                tempitem.Total_Amount__c=tempitem.TotalPrice+tax;
            
            updateitemlist.add(tempitem);
            
            
        }
        update updateitemlist;
        
         Map<Id,list<orderitem>>orderToorderitem = new Map<Id,list<orderitem>>();
       
        for(orderItem item:updateitemlist){
            if(orderToorderitem.containskey(item.OrderId)){
                orderToorderitem.get(item.OrderId).add(item);
            }else{
                orderToorderitem.put(item.OrderId,new list<OrderItem>{item});
            }
            
        }
        
        list<order>orderupdatelist = new list<order>();
      
        for(Id o:orderids){
          list<orderitem>itlist= orderToorderitem.get(o);
            decimal total=0;
            decimal totaltax=0;
            for(orderitem a:itlist){
                 total = a.Total_Amount__c+total;
                totaltax = a.Tax_Amount__c+totaltax;
            }
            order temp = new order();
           temp.Total_Amount__c=total;
            temp.Tax_Amount__c=totaltax;
            
            orderupdatelist.add(temp);
        }
        update orderupdatelist;

        
        
    }
}