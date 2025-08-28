/**
 * @description Class to perform various DML operations for training and testing purposes
 * @author sanvarlal jangid
 */
public with sharing class DMLAssignment {

    /**
     * @description Appends 'test' with a number to the Last_Name__c field of students
     *              whose First_Name__c starts with 'S', and updates them
     * @author sanvarlal jangid
     */
    public static void appendingName() {
        List<Student__c> stlist = [SELECT First_Name__c, Last_Name__c FROM Student__c WHERE First_Name__c LIKE 'S%' WITH SECURITY_ENFORCED];
        System.debug(stlist);
        Integer i = 1;
        for (Student__c s : stlist) {
            s.Last_Name__c = s.Last_Name__c + ' Test ' + i;
            i++;
        }
       
        if(Schema.sObjectType.Student__c.isUpdateable()) {
        update stlist;
        }
    }

    /**
     * @description Creates an Opportunity for all Accounts that currently do not have any Opportunities
     * @author sanvarlal jangid
     */
    public static void createOpportunitiesWithoutLinks() {
        List<Account> acclist = [SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Opportunity)WITH SECURITY_ENFORCED];
        List<Opportunity> opplist = new List<Opportunity>();
        for (Account acc : acclist) {
            Opportunity opp = new Opportunity(Name = acc.Name + ' First Opportunity', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
            opplist.add(opp);
        }
  
       Database.SaveResult[] ans=database.insert(opplist,false); 
   
       
    }

    /**
     * @description Demonstrates insert, delete, and undelete operations for Account and Contact records
     * @author sanvarlal jangid
     */
    public static void manipulateAccountAndContact() {
        Account acc = new Account(Name = 'Unive Container');
        Database.SaveResult ans = database.insert(acc,false);
        Contact con = new Contact(lastname = 'Carter last');
        con.AccountId = acc.Id;
        Database.SaveResult ans2  = database.insert(acc,false);
        Database.SaveResult ans3  = Database.insert(con,false);
        Database.DeleteResult ans4  =  Database.delete(acc,false);
        Database.UnDeleteResult ans5 = Database.undelete(acc,false); 
    }

    /**
     * @description Permanently deletes Student__c records from Recycle Bin where the second letter is 'r'
     * @author sanvarlal jangid
     */
    public static void deleteStudentsWithSecondLetterR() {
        List<SObject> recordsToDelete = [SELECT Id FROM Student__c WHERE IsDeleted = TRUE AND Name LIKE '_r%' WITH SECURITY_ENFORCED ALL ROWS ];
        if (!recordsToDelete.isEmpty()) {
            Database.emptyRecycleBin(recordsToDelete);
            System.debug('Deleted ' + recordsToDelete.size() + ' student records from the Recycle Bin.');
        } else {
            System.debug('No matching student records found.');
        }
    }

    /**
     * @description Undeletes Student__c records deleted by 'Salesforce Demo' user within the given date range
     * @param dateValue1 start date
     * @param dateValue2 end date
     * @author sanvarlal jangid
     */
    public static void undeleteStudentsDeletedByDemoUser(Date dateValue1, Date dateValue2) {
        List<Student__c> studentsToRestore = [SELECT Id FROM Student__c WHERE IsDeleted = TRUE
                                              AND LastModifiedBy.Name = 'Salesforce Demo'
                                              AND LastModifiedDate >= :dateValue1 
                                              AND LastModifiedDate <= :dateValue2 WITH SECURITY_ENFORCED ALL ROWS ];
        if (!studentsToRestore.isEmpty()) {
           if( Schema.sObjectType.Student__c.isUndeletable()){
            undelete studentsToRestore;
            }
        }
    }

    /**
     * @description Inserts Account and related Contact using one DML call with an external id field
     * @author sanvarlal jangid
     */
    public static void insertAccountContactRecords() {
        Account acc = new Account(Name = 'Test Account', Company_Email__c = 'testcompany@gmail.com');
        Account acc1 = new Account(Company_Email__c = 'testcompany@gmail.com');
        Contact con = new Contact(LastName = 'Doe', Account = acc1);
        List<SObject> recordsToInsert = new List<SObject>{acc, con};

       
       database.saveresult[] result=database.insert(recordsToInsert,false);
        System.debug('Inserted Account and Contact together successfully.');
        
    }

    /**
     * @description Inserts multiple accounts and creates related Contacts, Opportunities, and OpportunityLineItems
     * @return List<sObject> - Inserted accounts list
     * @author sanvarlal jangid
     */
    public static List<sObject> insertAndCreateRelatedRecords() {
        List<sObject> result = new List<sObject>();
        List<Account> accounts = new List<Account>();

        for (Integer i = 1; i <= 5; i++) {
            Account acc = new Account(Name = 'Souraabh ' + i);
            accounts.add(acc);
        }
       Database.Saveresult[] sr=database.insert(accounts,false);

        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' AND IsActive = TRUE WITH SECURITY_ENFORCED LIMIT 1 ];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'GenWatt Diesel 10kW' WITH SECURITY_ENFORCED LIMIT 1 ];

        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : accounts) {
            Contact contact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
            conList.add(contact);

            Opportunity opp = new Opportunity(Name = 'Opportunity for ' + acc.Name, AccountId = acc.Id, Pricebook2Id = pb.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
            oppList.add(opp);
        }

       Database.Saveresult[] r= database.insert(conList,false);
       Database.Saveresult[] vr= database.insert(oppList,false);

        List<OpportunityLineItem> opplineItems = new List<OpportunityLineItem>();
        for (Opportunity opp : oppList) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = prod.Id, Quantity = 1, TotalPrice = 2000);
            opplineItems.add(oli);
        }
       if(Schema.sObjectType.OpportunityLineItem.iscreateable()){
        insert opplineItems;
        }

        result.addAll(accounts);
        return result;
    }

    /**
     * @description Deletes Account records having 2 or more Opportunities where StageName is not 'Closed Won' or 'Closed Lost'
     * @author sanvarlal jangid
     */
    public static void deleteOpp() {
        List<AggregateResult> accid = [SELECT AccountId, COUNT(Id) FROM Opportunity 
                                       WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' WITH SECURITY_ENFORCED
                                       GROUP BY AccountId HAVING COUNT(Id) >= 2];

        List<Id> accountIds = new List<Id>();
        for (AggregateResult a : accid) {
            accountIds.add((Id)a.get('AccountId'));
        }

       Database.DeleteResult[] result = Database.delete(accountIds, false);
    }

    /**
     * @description Returns the total number of records present in any object (object name is passed as argument)
     * @param objectName - API name of the object
     * @return Integer - total record count
     * @author sanvarlal jangid
     */
    public static Integer totalRecordsInObject(String objectName) {
        String query = 'SELECT count() FROM ' + objectName;
        Integer totalCount = Database.countQuery(query);
        return totalCount;
    }

    /**
     * @description Inserts a list of Student__c records and rolls back all if less than 80% are successfully inserted
     * @param stdToInsertList - list of Student__c records to insert
     * @author sanvarlal jangid
     */
    public static void rollbackStudentRecords(List<Student__c> stdToInsertList) {
        if (stdToInsertList == null || stdToInsertList.isEmpty()) {
            return;
        }

        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] result = Database.insert(stdToInsertList, false);

        Integer successInsert = 0;
        for (Database.SaveResult r : result) {
            if (r.isSuccess()) {
                successInsert++;
            }
        }

        Integer successRate = ((successInsert * 100) / stdToInsertList.size());
        if (successRate < 80) {
            Database.rollback(sp);
            System.debug('Rolled back because only ' + successRate + '% of records inserted.');
        } else {
            System.debug('Inserted successfully. ' + successRate + '% of records inserted.');
        }
    }
}