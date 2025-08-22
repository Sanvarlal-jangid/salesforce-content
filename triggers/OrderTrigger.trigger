trigger OrderTrigger on Order (before insert,after insert) {
    if(trigger.isbefore && trigger.isinsert){
    Set<String> allProductNames = new Set<String>();
    set<id>oppids =new set<id>();

    
    for (Order ord : Trigger.new) {
        if (ord.products_in__c != null) {
            String cleaned =  ord.products_in__c.substring(1, ord.products_in__c.length() - 1);
            List<String> entries = cleaned.split(',');

            for (String entry : entries) {
                entry = entry.trim();
                if (entry.contains('(') && entry.contains(')')) {
                    String name = entry.substringBefore('(');
                      name=name.trim();
                    allProductNames.add(name);
                }
            }
            if(ord.OpportunityId!=null){
                oppids.add(ord.OpportunityId);
            }
        }
    }
     list<opportunitylineitem> olilist = [SELECT Id, OpportunityId, Product2.name, ProductCode, Name, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :oppids];
    
        Map<Id, Map<String, Integer>> opptoprodtoquantity = new Map<Id, Map<String, Integer>>();
    
            for(opportunitylineitem oli : olilist){
              if (!opptoprodtoquantity.containsKey(oli.OpportunityId)) {
                  opptoprodtoquantity.put(oli.OpportunityId, new Map<String, Integer>());
               }
              Map<String, Integer> invMap = opptoprodtoquantity.get(oli.OpportunityId);
                if (!invMap.containsKey(oli.Product2.name)) {
                 invMap.put(oli.Product2.name, (Integer)oli.Quantity);
                } else {
                 invMap.put(oli.Product2.name, invMap.get(oli.Product2.name) + (Integer)oli.Quantity);
                   }
             }

    system.debug(opptoprodtoquantity);
    
    Map<String, Product2> validProducts = new Map<String, Product2>();
    if (!allProductNames.isEmpty()) {
        for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN :allProductNames]) {
            validProducts.put(prod.Name, prod);
        }
    }

    for (Order ord : Trigger.new) {
        if (ord.products_in__c != null) {
            List<String> invalidNames = new List<String>();
            list<string>invalidquantity = new list<string>();
          String cleaned =  ord.products_in__c.substring(1, ord.products_in__c.length() - 1);
            List<String> entries = cleaned.split(',');

            for (String entry : entries) {
                entry = entry.trim();
                    Integer startIndex = entry.indexOf('(') + 1; 
                    Integer endIndex = entry.indexOf(')');

                     String numberString = entry.substring(startIndex, endIndex);
                     Integer extractedNumber = Integer.valueOf(numberString);
                     
                if (entry.contains('(') && entry.contains(')')) {
                    String name = entry.substringBefore('(');
                      name=name.trim();
                    if (!validProducts.containsKey(name)) {
                        invalidNames.add(name);
                    }
                    if(ord.OpportunityId!=null){
                       map<string,integer>prodtoquantity= opptoprodtoquantity.get(ord.OpportunityId);
                        integer quntity = prodtoquantity.get(name);
                        if(extractedNumber > quntity){
                            invalidquantity.add(name);
                        }
                    }
                } 
            }

            if (!invalidNames.isEmpty()) {
                ord.addError('Invalid product names: ' + invalidNames);
            }
             if (!invalidquantity.isEmpty()) {
                ord.addError('Invalid product quantity: ' + invalidquantity);
            }
            
        }
    }
    }

   if (Trigger.isAfter && Trigger.isInsert) {
    
    Map<Id, Order> ordersToProcess = new Map<Id, Order>();
    Set<String> allProductNames = new Set<String>();
    Set<Id> opportunityIds = new Set<Id>();

    for (Order ord : Trigger.new) {
        if (ord.products_in__c != null && ord.OpportunityId != null) {
            ordersToProcess.put(ord.Id, ord);
            opportunityIds.add(ord.OpportunityId);

            String cleaned = ord.products_in__c.substring(1, ord.products_in__c.length() - 1);
            for (String entry : cleaned.split(',')) {
                if (entry.contains('(') && entry.contains(')')) {
                    String productName = entry.substringBefore('(').trim();
                    allProductNames.add(productName);
                }
            }
        }
    }

    if (ordersToProcess.isEmpty()) return;

    // Get Opportunities and Pricebooks
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
        [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id IN :opportunityIds]
    );

    // Update Orders with Pricebook2Id from Opportunity
    List<Order> ordersToUpdate = new List<Order>();
    for (Order ord : ordersToProcess.values()) {
        Opportunity opp = opportunityMap.get(ord.OpportunityId);
        if (opp != null && opp.Pricebook2Id != null) {
            Order updatedOrd = new Order(Id = ord.Id, Pricebook2Id = opp.Pricebook2Id);
            ordersToUpdate.add(updatedOrd);
        }
    }

  update ordersToUpdate;

 
    Map<Id, Order> updatedOrderMap = new Map<Id, Order>(
        [SELECT Id, Pricebook2Id, OpportunityId, products_in__c FROM Order WHERE Id IN :ordersToProcess.keySet()]
    );

   
    Set<Id> pricebookIds = new Set<Id>();
    for (Order ord : updatedOrderMap.values()) {
        if (ord.Pricebook2Id != null) {
            pricebookIds.add(ord.Pricebook2Id);
        }
    }

    List<PricebookEntry> pricebookEntries = [SELECT Id, Product2.Name, Pricebook2Id, UnitPrice FROM PricebookEntry
                               WHERE IsActive = true AND Product2.Name IN :allProductNames AND Pricebook2Id IN :pricebookIds];

    Map<Id, Map<String, PricebookEntry>> pricebookMap = new Map<Id, Map<String, PricebookEntry>>();
    for (PricebookEntry pbe : pricebookEntries) {
        if (!pricebookMap.containsKey(pbe.Pricebook2Id)) {
            pricebookMap.put(pbe.Pricebook2Id, new Map<String, PricebookEntry>());
        }
        pricebookMap.get(pbe.Pricebook2Id).put(pbe.Product2.Name, pbe);
    }


    List<OrderItem> orderItemsToInsert = new List<OrderItem>();

    for (Order ord : updatedOrderMap.values()) {
        Map<String, PricebookEntry> productEntries = pricebookMap.get(ord.Pricebook2Id);
        if (productEntries == null) continue;

        String cleaned = ord.products_in__c.substring(1, ord.products_in__c.length() - 1);
        for (String entry : cleaned.split(',')) {
            if (entry.contains('(') && entry.contains(')')) {
                String productName = entry.substringBefore('(').trim();
                String quantityStr = entry.substringBetween('(', ')').trim();

                if (String.isNotBlank(productName) && String.isNotBlank(quantityStr)) {
                
                        Integer quantity = Integer.valueOf(quantityStr);
                        PricebookEntry pbe = productEntries.get(productName);
                        if (pbe != null) {
                            OrderItem item = new OrderItem( OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = quantity,
                                UnitPrice = pbe.UnitPrice
                            );
                            orderItemsToInsert.add(item);
                        }
                    
                }
            }
        }
    }

    if (!orderItemsToInsert.isEmpty()) {
        try{
        insert orderItemsToInsert;
        System.debug('Inserted OrderItems: ' + orderItemsToInsert.size());
        } catch(exception e){
                system.debug('eror in insert orderlineitem'+e.getMessage());
            }
    } else {
        System.debug('No OrderItems to insert');
    }
       
       
       
       for (Order ord : updatedOrderMap.values()) {
       invoicegenerator.generateinvoice(ord.id);
   }
}
    
   
   


                
}