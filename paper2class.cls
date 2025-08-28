public with sharing class paper2class {
@AuraEnabled(cacheable=true)
public static List<Decimal> methodName() {
    List<Decimal> anslist = new List<Decimal>();

    for (Document__c doc : [SELECT valid_from_date__c FROM Document__c]) {
        if (!anslist.contains(doc.valid_from_date__c)) {
            anslist.add(doc.valid_from_date__c);
        }
    }

    anslist.sort(); 
    System.debug('Sorted Answer List: ' + anslist);

    return anslist;
}
}