public class HubSpotContactManager implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public class HubSpotWrapper {
        public List<Input> inputs = new List<Input>();
    }

    public class Input {
        public Properties properties;
        public String id;
        public String idProperty;
    }

    public class Properties {
        public String email;
        public String firstname;
        public String lastname;
        public String phone;
        public String company;
        public String website;
        public String lifecyclestage;
    }

    private Set<Id> contactIdsToProcess;

    public HubSpotContactManager(Set<Id> ids) {
            this.contactIdsToProcess = ids;
    }

  public static void applybatch(Set<Id> contactIds) {
        HubSpotContactManager batch = new HubSpotContactManager(contactIds);
        Database.executeBatch(batch, 99);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
          return Database.getQueryLocator([ SELECT Id, FirstName, LastName, Email, Phone, Account.Name, Account.Website
            FROM Contact where Id IN :contactIdsToProcess]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
     

        List<Input> contactEntries = new List<Input>();

        for (Contact c : scope) {
                  Input input = new Input();
             input.properties = new Properties();
             input.properties.email = c.Email;
            input.properties.firstname = c.firstName;
                 input.properties.lastname = c.lastName;
            input.properties.phone = c.phone;
             input.properties.company ='HubSpot';
            input.properties.website = 'hubspot.com';
             input.properties.lifecyclestage = 'marketingqualifiedlead'; 

            input.id = c.Email;
            input.idProperty = 'email';

            contactEntries.add(input);
        }

        if (!contactEntries.isEmpty()) {
            sendToHubSpotCreateUpdate(contactEntries);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('HubSpot Contact Sync Batch finished.');
    }

    private void sendToHubSpotCreateUpdate(List<Input> contactEntries) {
        HubSpotWrapper payload = new HubSpotWrapper();
        payload.inputs.Addall(contactEntries);

         String jsonBody = JSON.serialize(payload);
        System.debug('JSON Body ' + jsonBody);

           HttpRequest req = new HttpRequest();
          req.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts/batch/upsert');
        req.setMethod('POST');
           req.setHeader('Content-Type', 'application/json');
          req.setHeader('Authorization', 'Bearer pat-na2-31f252c6-ca29-466f-b9bb-67a7af7cc73f');

        req.setBody(jsonBody);

        Http http = new Http();
        
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                System.debug('successfull');
            } else {
                System.debug('errror ' + res.getBody());
            }
      
    }
}