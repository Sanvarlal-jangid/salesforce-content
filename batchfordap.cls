global class batchfordap implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global Set<Id> orderIds;

    global batchfordap(List<Order> orders) {
        orderIds = new Set<Id>();
        for (Order o : orders) {
            orderIds.add(o.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, OrderId, Quantity, UnitPrice, TotalPrice, Type__c,
                   Product2.Name, Order.BillingStreet, Order.BillingCity, Order.BillingState, Order.BillingPostalCode,
                               Order.BillingCountry, Order.Account.Email__c FROM OrderItem WHERE OrderId IN :orderIds]);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<OrderItem> items = (List<OrderItem>) scope;
        Map<Id, List<OrderItem>> orderToItems = new Map<Id, List<OrderItem>>();
        Map<Id, Order> orderMap = new Map<Id, Order>();
        List<OrderItem> updatedItems = new List<OrderItem>();

        ShopkeeperAddress__mdt shop = [SELECT Street__c, City__c, State__c, Zip__c, Country__c FROM ShopkeeperAddress__mdt LIMIT 1];

        for (OrderItem item : items) {
            if (!orderToItems.containsKey(item.OrderId)) {
                orderToItems.put(item.OrderId, new List<OrderItem>());
            }
            orderToItems.get(item.OrderId).add(item);
        }

        for (Id orderId : orderToItems.keySet()) {
            List<OrderItem> itemList = orderToItems.get(orderId);
            Map<Id, Decimal> taxMap = TaxJarCalloutService.calculateSalesTaxBulk(itemList);
            Decimal totalTax = 0;
            Decimal totalAmount = 0;

            for (OrderItem item : itemList) {
                Decimal tax = taxMap.get(item.Id);
                item.Tax_Amount__c = tax;
                item.Total_Amount__c = item.TotalPrice + tax;
                updatedItems.add(item);
                totalTax += tax;
                totalAmount += item.Total_Amount__c;
            }

            Order ord = new Order(Id = orderId);
            ord.Tax_Amount__c = totalTax;
            ord.Total_Amount__c = totalAmount;
            ord.Status = 'Activated';
            orderMap.put(orderId, ord);
        }

        update updatedItems;
        update orderMap.values();

        // Send emails
     /*  
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (Id orderid : orderToItems.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { 'sanvarlal@cyntexa.com' });
            mail.setSubject('Order Activated: ' + orderid);
            list<orderitem>itemlist = orderToitems.get(orderid);
         
              String body = 'Your order has been activated. Details:\n\n';
        for (OrderItem item : itemList) {
            body += 'Product: ' + (item.Product2 != null ? item.Product2.Name : 'N/A') + '\n' +
                    'Quantity: ' + item.Quantity + '\n' +
                    'Price: ' + item.TotalPrice + '\n' +
                    'Tax: ' + item.Tax_Amount__c + '\n' +
                    'Total: ' + item.Total_Amount__c + '\n\n';
            
        
        }
              mail.setPlainTextBody(body);
            emailsToSend.add(mail);
           
    }
         Messaging.sendEmail(emailsToSend); */
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
 


    }
}