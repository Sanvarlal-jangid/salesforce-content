@isTest
public class TestingAssignment {
    @isTest
    static void testInsertAccountCreatesOpportunity(){
        account a = new account(name='test account 2');
        account b=new account(name ='test account 1');
        List<Account>acclist=new List<Account>();
        acclist.add(a);
        acclist.add(b);
         
       insert acclist;
        
        Test.startTest();
        TriggerHelper.AccounttriggerAfterupdateinsert(acclist);
        Test.stopTest();
        Set<Id>accset = new Set<id>();
        for(account acc:acclist){
            accset.add(acc.id);
        }
        
        List<opportunity>opplist=[select id, name,accountid from opportunity where accountid in :accset];
        system.assertEquals(2,opplist.size());
    } 
        @isTest
    static void testupdateAccountCreatesOpportunity() {
       
        Account acc = new Account(Name = 'Existing Account');
        insert acc;

   
        account a1=[select id,name from account where id = :acc.id];
        a1.Name='existing account 2';
        update a1;

        
        Test.startTest();
        TriggerHelper.AccounttriggerAfterupdateinsert(new List<Account>{ a1 });
        Test.stopTest();

       
        List<Opportunity> oppList = [select id,accountid from opportunity where accountid =:acc.Id];
        System.assertEquals(1, oppList.size());
    }
    
   

    @isTest
    static void testAccountWithOpenOpportunity() {
        Account acc = new Account(Name = 'Test Account A');
        insert acc;

        Opportunity opp = new Opportunity(Name='Test Opportunity',StageName ='Prospecting',CloseDate = Date.today().addDays(30),
                                           AccountId = acc.Id);
        insert opp;

        Test.startTest();
        try {
            
            delete acc;
           
        } catch (DmlException e) {
                 System.assert(e.getMessage().contains('cannot delete this account it has open opportunity'),
                'The DmlException message did not contain the expected error message: ' + e.getMessage());        }
        Test.stopTest();
        
         List<Account> accountsAfterDeleteAttempt = [SELECT Id FROM Account WHERE Id = :acc.Id ALL ROWS];
        System.assertEquals(1, accountsAfterDeleteAttempt.size()); 
    }

    @isTest
    static void testAccountWithoutOpenOpportunity() {
       
        Account acc = new Account(Name = 'Test Account B');
        insert acc;
  
        Test.startTest();
        delete acc; 
        Test.stopTest();

        
       Boolean isDeleted = false; 
    try {
        Account deletedAcc = [SELECT Id FROM Account WHERE Id = :acc.Id];
    } catch (Exception e) {
        isDeleted = true; 
    }

    System.assertEquals(true, isDeleted); 
    }
    
    
    @isTest
    static void testWithExistingAccountAndContacts() {
        Account acc = new Account(Name = 'Test Account', NumberOfEmployees = 10);
        insert acc;

        Contact con1 = new Contact(LastName = 'golu', AccountId = acc.Id);
        Contact con2 = new Contact(LastName = 'jugnu', AccountId = acc.Id);
        insert new List<Contact>{ con1, con2 };

        String requestJson = '{"Name":"Test Account"}';

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestJson);

        RestResponse res = new RestResponse();

        RestContext.request = req;
   
        Test.startTest();
        String response = AccAndContAPI.getAccounAndContact();
        Test.stopTest();

        System.debug('Response from API: ' + response);

        System.assert(response.contains('“Name”=”John”') || response.contains('“Name”=”Jane”'),
                      'Expected contact names in the response');
        System.assert(response.contains('“Name”=”Test Account”'), 'Expected account name in the response');
    }
   
    @isTest
    static void testWithNoMatchingAccount() {

        String requestJson = '{"Name":"NonExistingAccount"}';

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestJson);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String response = AccAndContAPI.getAccounAndContact();
        Test.stopTest();

        System.debug('Response when no account: ' + response);

        System.assert(response.contains('No Account Exists with name NonExistingAccount'));
    }
      @isTest
    static void testLeadConversionAPI() {
        
        Lead lead1 = new Lead(LastName = 'Amrit Mittal', Company = 'Company A');
        Lead lead2 = new Lead(LastName = 'Tushar Sharma', Company = 'Company B');
        insert new List<Lead>{ lead1, lead2 };

      
 String jsonBody = '[{"LeadName" : "Amrit Mittal", "Createopp" : true},{"LeadName" : "Tushar Sharma", "Createopp" : false}]';

        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';  // POST method
        req.requestBody = Blob.valueOf(jsonBody); // Convert JSON to Blob
        RestContext.request = req;

       
        RestResponse res = new RestResponse();
        RestContext.response = res;

        
        Test.startTest();
        String response = LeadConvertApi_Q1b.convertLeadApi();
        Test.stopTest();

       
        System.debug('Response from API: ' + response);

        
        List<Lead> leadList = [SELECT Id, IsConverted FROM Lead WHERE Id IN :new List<Id>{ lead1.Id, lead2.Id }];
        for (Lead l : leadList) {
            System.assertEquals(true, l.IsConverted);
        }

        
        System.assert(response.contains('These leads are converted: ['));
    }
        // Mock class for Twilio API
    class TwilioMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"sid": "SMxxxxxxxxxx", "status": "queued"}');
            res.setStatusCode(201);
            return res;
        }
    }

    @isTest
    static void testTwilioMessageCallout() {
        Test.setMock(HttpCalloutMock.class, new TwilioMockResponse());

        Test.startTest();
        sendmessagetostudent.mymethod('Twilio User', '+911234567890', 'twilio@example.com');
        Test.stopTest();

        System.debug('Twilio callout tested successfully');
    }

}