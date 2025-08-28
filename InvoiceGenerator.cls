public class InvoiceGenerator {

    public class SampleClass {
        public String sender;
        public String to;
        public String notes;
        public List<Item> items;
    }

    public class Item {
        public String name;
        public Integer quantity;
        public Double unit_cost;
    }
     @future(callout=true)
    public static void generateInvoice(Id orderId) {
        list<orderitem>Oilist = [SELECT Quantity,Product2.Name, UnitPrice, Id, OrderId FROM OrderItem where OrderId =:orderId ];
        SampleClass sample = new SampleClass();
        sample.sender = 'Nikolaus Ltd';
        sample.to = 'Acme, Corp.';
        sample.notes = 'Thanks for your business!';
        
        list<Item>itemlist = new list<Item>();
        if(!Oilist.isEmpty()){
            for(orderitem OI:Oilist){
                Item nitem = new Item();
                nitem.name=OI.Product2.Name;
                nitem.quantity = Integer.valueof(OI.Quantity);
                nitem.unit_cost =OI.UnitPrice;
                itemlist.add(nitem);
            }
        }
        sample.items = itemlist;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://invoice-generator.com');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer sk_dKa1dFYhSaXlerEr0k4yuiYkPrVpw1Xw');
        request.setHeader('Content-Type', 'application/json');

        String jsonBody = JSON.serialize(sample);
        jsonBody = jsonBody.replace('"sender"', '"from"'); 
        System.debug('Generated JSON Body (after replacement): ' + jsonBody);

        request.setBody(jsonBody);
        
        Http http = new Http();
    
            HttpResponse response = http.send(request);

           
            if (response.getStatusCode() == 200) {
                Blob pdfContent = response.getBodyAsBlob();
                String fileName = 'Invoice' + orderId + '.pdf';
                
            
                Attachment attach = new Attachment();
                attach.ParentId = orderId;
                attach.Name = fileName;
                attach.Body = pdfContent;
                //attach.ContentType = 'application/pdf';
                
                try {
                    insert attach;
                    System.debug('PDF invoice successfully attached to Order: ' + orderId);
                } catch (Exception e) {
                    System.debug('Error attaching PDF: ' + e.getMessage());
                }
                  
                
            } else {
                System.debug('API Error Status Code: ' + response.getStatusCode());
                System.debug('API Error Response Body: ' + response.getBody());
            }
       
    }
}