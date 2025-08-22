trigger OrderInventoryCheck on OrderItem (before insert) {
  
    Set<Id> orderIds = new Set<Id>();
    for (OrderItem oi : Trigger.new) {
        if (oi.OrderId != null) {
            orderIds.add(oi.OrderId);
        }
    }


    Map<Id, Id> orderToOpportunity = new Map<Id, Id>();
    Set<Id> opportunityIds = new Set<Id>();
    List<Order> orderList = [ SELECT Id, OpportunityId FROM Order WHERE Id IN :orderIds];

    for (Order ord : orderList) {
        if (ord.OpportunityId != null) {
            orderToOpportunity.put(ord.Id, ord.OpportunityId);
            opportunityIds.add(ord.OpportunityId);
        }
    }


    Map<Id, Map<Id, Integer>> inventoryByOpportunity = new Map<Id, Map<Id, Integer>>();
    List<OpportunityLineItem> oppProdList = [ SELECT OpportunityId, Product2Id, Quantity FROM OpportunityLineItem
                                             WHERE OpportunityId IN :opportunityIds];

    for (OpportunityLineItem oli : oppProdList) {
        Id oppId = oli.OpportunityId;
        Id prodId = oli.Product2Id;
        Integer qty = Integer.valueOf(oli.Quantity);

        if (!inventoryByOpportunity.containsKey(oppId)) {
            inventoryByOpportunity.put(oppId, new Map<Id, Integer>());
        }

        Map<Id, Integer> invMap = inventoryByOpportunity.get(oppId);
        if (!invMap.containsKey(prodId)) {
            invMap.put(prodId, qty);
        } else {
            invMap.put(prodId, invMap.get(prodId) + qty);
        }
    }

    Map<Id, Map<Id, Integer>> consumedQtyByOpportunity = new Map<Id, Map<Id, Integer>>();
    List<Order> ordersWithOpp = [SELECT Id, OpportunityId FROM Order WHERE OpportunityId IN :opportunityIds];

    Set<Id> allOrderIds = new Set<Id>();
    for (Order ord : ordersWithOpp) {
        allOrderIds.add(ord.Id);
    }

    List<OrderItem> existingOrderItems = [SELECT OrderId, Product2Id, Quantity FROM OrderItem WHERE OrderId IN :allOrderIds ];

    Map<Id, Id> existingOrderToOppMap = new Map<Id, Id>();
    for (Order ord : ordersWithOpp) {
        existingOrderToOppMap.put(ord.Id, ord.OpportunityId);
    }

    for (OrderItem oi : existingOrderItems) {
        Id ordId = oi.OrderId;
        Id oppId = existingOrderToOppMap.get(ordId);
        Id prodId = oi.Product2Id;
        Integer qty = Integer.valueOf(oi.Quantity);

        if (!consumedQtyByOpportunity.containsKey(oppId)) {
            consumedQtyByOpportunity.put(oppId, new Map<Id, Integer>());
        }

        Map<Id, Integer> conMap = consumedQtyByOpportunity.get(oppId);
        if (!conMap.containsKey(prodId)) {
            conMap.put(prodId, qty);
        } else {
            conMap.put(prodId, conMap.get(prodId) + qty);
        }
    }


    for (OrderItem oi : Trigger.new) {
        Id ordId = oi.OrderId;
        Id oppId = orderToOpportunity.get(ordId);
        Id prodId = oi.Product2Id;
        Integer requestedQty = Integer.valueOf(oi.Quantity);

        if (oppId == null || prodId == null) continue;

        Integer totalInventory = 0;
        if (inventoryByOpportunity.containsKey(oppId)) {
            Map<Id, Integer> invMap = inventoryByOpportunity.get(oppId);
            if (invMap.containsKey(prodId)) {
                totalInventory = invMap.get(prodId);
            }
        }

        Integer alreadyConsumed = 0;
        if (consumedQtyByOpportunity.containsKey(oppId)) {
            Map<Id, Integer> conMap = consumedQtyByOpportunity.get(oppId);
            if (conMap.containsKey(prodId)) {
                alreadyConsumed = conMap.get(prodId);
            }
        }

        Integer remainingQty = totalInventory - alreadyConsumed;
        if (requestedQty > remainingQty) {
            oi.addError('Not enough inventory for Product: ' + prodId +
                        '. Available: ' + remainingQty + ', Requested: ' + requestedQty);
        }
    }
}