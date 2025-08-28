public with sharing class OpportunityCreatorController {

 


    @AuraEnabled(cacheable=true)
    public static List<Account> Allaccounts() {
       
        return [SELECT Id, Name FROM account ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(Id accountId) {
        if (accountId == null) {
            return new List<Contact>();
        }
        return [SELECT Id, Name FROM Contact WHERE AccountId = :accountId ORDER BY Name ASC];
    }

     @AuraEnabled(cacheable=true)
    public static List<Pricebook2> Allpricebooks() {
        
        return [SELECT Id, Name, IsDeleted, IsStandard FROM Pricebook2];
    } 

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductsByPricebookId(Id pricebookId) {
        if (pricebookId == null) {
            return new List<PricebookEntry>();
        }
  
        return [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :pricebookId
                AND IsActive = true ];
    }

 
    @AuraEnabled
    public static Id createOpportunityAndLineItems(Id accountId, Id pricebookId, Id contactId, Date closedDate, String lineItemsJson) {
        if (accountId == null || pricebookId == null || closedDate == null) {
           system.debug('Account, Pricebook, and Closed Date are required.');
        }

        List<OpportunityLineItemWrapper> lineItemsWrapper = (List<OpportunityLineItemWrapper>) JSON.deserialize(lineItemsJson, List<OpportunityLineItemWrapper>.class);


        if (lineItemsWrapper.isEmpty()) {
            throw new AuraHandledException('At least one product line item is required.');
        }

        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.Name = 'New Opportunity for ' + System.today().format();
        opp.StageName = 'Prospecting';
        opp.CloseDate = closedDate;
        opp.Pricebook2Id = pricebookId; 
        if (contactId != null) {
            opp.ContactId = contactId;
        }

        try {
            insert opp;
        } catch (Exception e) {
           
            throw new AuraHandledException('Error creating Opportunity: ' + e.getMessage());
        }

        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
     
        for (OpportunityLineItemWrapper itemWrapper : lineItemsWrapper) {

            if (itemWrapper.ProductId != null && itemWrapper.Quantity > 0) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id;
                oli.PricebookEntryId = itemWrapper.ProductId;
                oli.Quantity = itemWrapper.Quantity;
                oli.UnitPrice = itemWrapper.UnitPrice; 
                oppLineItems.add(oli);
            }
        }

        if (!oppLineItems.isEmpty()) {
            try {
                insert oppLineItems;
            } catch (Exception e) {
                Database.rollback(Database.setSavepoint());
                throw new AuraHandledException('Error creating Opportunity Line Items: ' + e.getMessage());
            }
        } else {
     
            throw new AuraHandledException('No valid product line items to save.');
        }

        return opp.Id;
    }

    public class OpportunityLineItemWrapper {
        @AuraEnabled public Id ProductId;   
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public Decimal ListPrice; 
        @AuraEnabled public Decimal Total;  
    }
}