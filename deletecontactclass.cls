public class deletecontactclass implements Database.Batchable<sObject>, Database.AllowsCallouts {

    

    private Set<Id> contactIdsToProcess;

    public deletecontactclass(Set<Id> ids) {
            this.contactIdsToProcess = ids;
    }

  public static void applybatch(Set<Id> contactIds) {
        deletecontactclass batch = new deletecontactclass(contactIds);
        Database.executeBatch(batch, 99);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
          return Database.getQueryLocator([ SELECT Id, FirstName, LastName, Email, Phone, Account.Name, Account.Website
            FROM Contact where Id IN :contactIdsToProcess]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
     list<string>contacttodelete=new list<string>();
        for(contact c:scope){
                       HttpRequest req = new HttpRequest();
            string endpoint ='https://api.hubapi.com/crm/v3/objects/contacts/'+c.Email+'?idProperty=email';
          req.setEndpoint(endpoint);
        req.setMethod('GET');
          req.setHeader('Authorization', 'Bearer pat-na2-31f252c6-ca29-466f-b9bb-67a7af7cc73f');


        Http http = new Http();
        
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                System.debug('successfull'+res.getbody());
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getbody().tostring()); 
                system.debug(result.get('id'));
                string s = result.get('id').tostring();
                contacttodelete.add(s);
                
            } else {
                System.debug('errror ' + res.getBody());
            }
        }
        for(string s:contacttodelete){
            HttpRequest req = new HttpRequest();
             req.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts/'+s);
               req.setMethod('DELETE');
          req.setHeader('Authorization', 'Bearer pat-na2-31f252c6-ca29-466f-b9bb-67a7af7cc73f');
             req.setHeader('Content-Type', 'application/json');

                Http http = new Http();
                  HttpResponse res = http.send(req);

               System.debug('Status Code: ' + res.getStatusCode());
               System.debug('Response: ' + res.getBody());

        }
       
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('HubSpot Contact Sync Batch finished.');
    }
}