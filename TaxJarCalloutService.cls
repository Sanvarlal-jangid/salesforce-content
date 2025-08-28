public class TaxJarCalloutService {
    public class LineItem {
        public String id;
        public Decimal quantity;
        public Decimal unit_price;
        public Decimal discount = 0;
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
        public Decimal shipping = 0;
        public List<LineItem> line_items;
    }

    public class MainClass {
        public cls_tax tax;
    }

    public class cls_tax {
        public Decimal amount_to_collect;
        public Decimal taxable_amount;
    }

    public static Map<Id, Decimal> calculateSalesTaxBulk(List<OrderItem> items) {
        Map<Id, Decimal> taxMap = new Map<Id, Decimal>();
		ShopkeeperAddress__mdt shop = [SELECT Street__c, City__c, State__c, Zip__c, Country__c FROM ShopkeeperAddress__mdt LIMIT 1];
        for (OrderItem item : items) {
            TaxJarRequest req = new TaxJarRequest();
            req.from_country = shop.Country__c;
            req.from_zip =  String.valueOf(shop.Zip__c);
            req.from_state = shop.State__c;
            req.from_city = shop.City__c;
            req.from_street = shop.Street__c;

            req.to_country = 'US'; //item.Order.BillingCountry;
            req.to_zip = '90002';//item.Order.BillingPostalCode;
            req.to_state = 'CA';//item.Order.BillingState;
            req.to_city = 'Los Angeles';//item.Order.BillingCity;
            req.to_street = '1335 E 103rd St'; //item.Order.BillingStreet;

            req.amount = item.TotalPrice;
            req.line_items = new List<LineItem>();

            LineItem li = new LineItem();
            li.id = item.Id;
            li.quantity = item.Quantity;
            li.unit_price = item.UnitPrice;
            li.product_tax_code = '20010';  //ProductTaxCodeMapping__mdt.getInstance(item.Type__c).Tax_Code__c;
            req.line_items.add(li);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.taxjar.com/v2/taxes');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer 2356c849b0a4725cf32fd929786f8ce7');
            request.setBody(JSON.serialize(req));

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                 System.debug(response.getBody());
                MainClass result = (MainClass) JSON.deserialize(response.getBody(), MainClass.class);
                system.debug(result);
                taxMap.put(item.Id, result.tax.amount_to_collect);
            } else {
                taxMap.put(item.Id, 0);
            }
        }

        return taxMap;
    }
}