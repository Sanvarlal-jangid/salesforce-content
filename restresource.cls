@RestResource(urlMapping='/shipmentcase/*')
global  class restresource {
    
   public class OrderData {
    public String ordernumber;
    public String casetitle;
}

    @HttpPost
    global static void createOrders() {
        RestRequest req = RestContext.request;
        String jsonBody = req.requestBody.toString();

        List<OrderData> orderList = (List<OrderData>) JSON.deserialize(jsonBody, List<OrderData>.class);
        system.debug(orderList);
list<Shipment_Case__c>insertlsit = new list<Shipment_Case__c>();
        for (OrderData order : orderList) {
            Shipment_Case__c c = new Shipment_Case__c();
            c.Case_Title__c=order.casetitle;
                c.Order_Number__c = order.ordernumber;
            
            insertlsit.add(c);
                            
        }
        insert insertlsit;
      
    }
}