@isTest
public class AccountTriggerHandlerTest {
    
    @isTest
    static void testInsertAccountCreatesOpportunity() {
        // Step 1: Create test accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{acc1, acc2};
        
        // Step 2: Call the trigger handler method
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id IN :new List<Id>{acc1.Id, acc2.Id}];
        Test.startTest();
        TriggerHelper.AccounttriggerAfterupdateinsert(accountList);
        Test.stopTest();
        
        // Step 3: Assert opportunities were created
        List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId IN :new List<Id>{acc1.Id, acc2.Id}];
        System.assertEquals(2, opps.size(), 'Two opportunities should be created for new accounts');
    }
    
    @isTest
    static void testNoDuplicateOpportunityCreated() {
        // Create account and manually add an opportunity
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Existing Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;
        
        // Re-trigger the handler
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Test.startTest();
        TriggerHelper.AccounttriggerAfterupdateinsert(accountList);
        Test.stopTest();
        
        // Assert that only one opportunity exists for the account
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id];
        System.assertEquals(1, opps.size(), 'No new opportunity should be created if one already exists');
    }
}