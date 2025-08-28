public class TaxJarCalloutService2 {

    public class LineItem {
        public String id;
        public Decimal quantity;
        public Decimal unit_price;
        public Decimal discount;
        public String product_tax_code;
    }

    public class TaxJarRequest {
        public String from_country;
        public String from_zip;
        public String from_state;
        public String from_city;
        public String from_street;
        public String to_country;
        public String to_zip;
        public String to_state;
        public String to_city;
        public String to_street;
        public Decimal amount;
        public Decimal shipping;
        public List<LineItem> line_items;
    }

    public static void calculateSalesTax(Id orderid) {
        //order id '801dL00001JCekeQAD'
        decimal a = 100;
        decimal d = 0;

        // Fetch the order record to get TotalAmount
        Order orderRecord = [SELECT Id, TotalAmount FROM Order WHERE Id = :orderid LIMIT 1];

        TaxJarRequest requestBody = new TaxJarRequest();
        requestBody.from_country = 'US'; 
        requestBody.from_zip = '94025'; 
        requestBody.from_state = 'CA'; 
        requestBody.from_city = 'Menlo Park';
        requestBody.from_street = '2825 Sand Hill Rd'; 

        requestBody.to_country = 'US';
        requestBody.to_zip = '92093';
        requestBody.to_state = 'CA';
        requestBody.to_city = 'Los Angeles';
        requestBody.to_street = '9424 S. Alameda Street';

        requestBody.amount = orderRecord.TotalAmount;
        requestBody.shipping = a;

        List<LineItem> lineItems = new List<LineItem>();
/*
        for (OrderItem oi : [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderid]) {
            LineItem item = new LineItem();
            item.id = oi.Id;
            item.quantity = oi.Quantity;
            item.unit_price = oi.UnitPrice;
            item.discount = d;
            item.product_tax_code = '19007'; // oi.Product2.TaxJar_Product_Code__c
            lineItems.add(item);
        } */

        
        LineItem item = new LineItem();
        item.id = '1';
        item.quantity = 1;
        item.unit_price = 30;
        item.discount = 0;
        item.product_tax_code = '19006';
        lineItems.add(item);
        

        requestBody.line_items = lineItems;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.taxjar.com/v2/taxes'); 
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer 2356c849b0a4725cf32fd929786f8ce7'); 
        request.setBody(JSON.serialize(requestBody));

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());

            try {
                MainClass data = (MainClass) JSON.deserialize(response.getBody(), MainClass.class);
                System.debug(data);
               
            } catch (Exception e) {
                System.debug('Deserialization error: ' + e.getMessage());
            }
        } else {
            System.debug('Error calculating sales tax: ' + response.getStatus() + ' - ' + response.getBody());
            // return response.getStatus();
        }
    }
   
public class MainClass{
	public cls_tax tax;
}
	public class cls_tax {
		public decimal amount_to_collect;	//0
		public cls_breakdown breakdown;
		public boolean freight_taxable;
		public boolean has_nexus;
		public cls_jurisdictions jurisdictions;
		public decimal order_total_amount;	//130100
		public decimal rate;	//0
		public decimal shipping;	//100
		public String tax_source;	//destination
		public decimal taxable_amount;	//0
	}
	public class cls_breakdown {
		public decimal city_tax_collectable;	//0
		public decimal city_tax_rate;	//0
		public decimal city_taxable_amount;	//0
		public decimal combined_tax_rate;	//0
		public decimal county_tax_collectable;	//0
		public decimal county_tax_rate;	//0
		public decimal county_taxable_amount;	//0
		public List<cls_line_items> line_items;
		public decimal special_district_tax_collectable;	//0
		public decimal special_district_taxable_amount;	//0
		public decimal special_tax_rate;	//0
		public decimal state_tax_collectable;	//0
		public decimal state_tax_rate;	//0
		public decimal state_taxable_amount;	//0
		public decimal tax_collectable;	//0
		public decimal taxable_amount;	//0
	}
	public class cls_line_items {
		public decimal city_amount;	//0
		public decimal city_tax_rate;	//0
		public decimal city_taxable_amount;	//0
		public decimal combined_tax_rate;	//0
		public decimal county_amount;	//0
		public decimal county_tax_rate;	//0
		public decimal county_taxable_amount;	//0
		public String id;	//802dL00000L2uGXQAZ
		public decimal special_district_amount;	//0
		public decimal special_district_taxable_amount;	//0
		public decimal special_tax_rate;	//0
		public decimal state_amount;	//0
		public decimal state_sales_tax_rate;	//0
		public decimal state_taxable_amount;	//0
		public decimal tax_collectable;	//0
		public decimal taxable_amount;	//0
	}
	public class cls_jurisdictions {
		public String city;	//LA 
		public String country;	
		public String county;	
		public String state;	
	}
}