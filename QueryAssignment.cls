/**
 * @description class to test query assignments
 * @author sanvarlal jangid
 */
public with sharing class QueryAssignment {
    /**
 * @description method to get sum of opportunity amount by fiscal year
 * @return  List<AggregateResult>
 */
    public static List<AggregateResult> getClosedOpportunitySumByFiscalYear(){
        List<AggregateResult>lst=[SELECT  FISCAL_YEAR(CreatedDate) ,SUM(Amount) amount  FROM Opportunity  WHERE StageName IN ('Closed Won', 'Closed Lost') AND OwnerId =:UserInfo.getUserId() WITH SECURITY_ENFORCED GROUP BY FISCAL_YEAR(CreatedDate) ];
        system.debug(lst);
        return lst;
    }
    /**
 * @description method to fetch opportunity records between two dates
 * @param firstDate 
 * @param secondDate
 * @return  List<Opportunity>
 */
    public static List<Opportunity> fetchOpportunitiesBetweenDates(Date firstDate, Date secondDate){
        List<Opportunity> lis = [Select name , CloseDate from Opportunity where CloseDate >= :firstDate AND CloseDate <= :secondDate and Owner.name like 'Saurman D’souza' WITH SECURITY_ENFORCED];
        return lis;
    }
    
/**
 * @description method to fetch accounts with related opportunities, contacts and notes
 * @return List<Account>
 */
public static List<Account> fetchAccountsWithRelatedData() {
    List<Account> result = [SELECT Id, Name,(SELECT Id, Name, StageName, CloseDate FROM Opportunities), 
                                   (SELECT Id, FirstName, LastName, Email FROM Contacts), 
                                   (SELECT Id, Title, Body FROM Notes) 
                            FROM Account
                            WHERE Name LIKE 'B%'  WITH SECURITY_ENFORCED];

    return result;
}

   /**
 * @description method to fetch related opportunity, contact and note records for opportunity
 * @return List<Opportunity>
 */
    public static List<Opportunity> fetchRelatedDataForOpportunity() {
      List<Opportunity> oppList = [Select Name, Account.Name,
                          (Select Contact.Name From OpportunityContactRoles),
                          (Select Title From Notes) From Opportunity Where Name like '%A' WITH SECURITY_ENFORCED];
        return oppList;

    
}   /**
 * @description method to fetch the records which have the test in all fields in opportunitties
 * @return List<List<sObject>>
 */
    public static List<List<sObject>> fetchTestOpportunityRecords(){
    Id currUser = UserInfo.getUserId();
    List<List<sObject>> result = [FIND 'test' IN ALL FIELDS  RETURNING Opportunity (Id, Name,CloseDate WHERE CloseDate = THIS_FISCAL_YEAR) ,Account(Id, Name, Owner.Name WHERE OwnerId = :currUser) ];
    return result;
}
    
    public static Map<Id, List<Opportunity>> opportunitiesRelatedToAccountMap  = new Map<Id, List<Opportunity>>(); 
    public static Map<Id, List<Contact>> contactsRelatedToAccountMap = new Map<Id, List<Contact>>();
    public static Map<Id, List<Note>> notesRelatedToAccountMap = new Map<Id, List<Note>>();
    
       
 /**
 * @description method to set the map of opportunities related to account, contacts and notes
 
 */
    public static void setOppContactNotesRelatedToAccount(){
        List<Account> accList = [Select Name, BillingCity, (Select Name, StageName From Opportunities), (Select FirstName From Contacts), (Select Title From Notes) From Account Where Name like 'B%' WITH SECURITY_ENFORCED];
        for(Account var : accList){
		List<Opportunity> opplist = var.Opportunities;
            opportunitiesRelatedToAccountMap.put(var.Id, opplist);
            
            List<Contact> conlist = var.Contacts;
            contactsRelatedToAccountMap.put(var.Id, conlist);
            
            List<Note> notelist = var.Notes;
            notesRelatedToAccountMap.put(var.Id, notelist);
        }
     }
      
     /**
 * @description method to get the total number of students of each batch
 * @return  List<AggregateResult>
 */
    public static List<AggregateResult> totalStudentsOfEachBatch(){
        List<AggregateResult>lst=[select Batch__r.Name, count(Student__c) from Student_in_Batch__c WITH SECURITY_ENFORCED group by Batch__r.Name ];
        return lst;
    }
    /**
 * @description method to get the sorted list of students with avg rating
 * @return  List<AggregateResult>
 */
    public static List<AggregateResult> sortedListOfStudentWithAvgRating(){
         List<AggregateResult>res=[select Rating_of_Student__c,AVG(Rating_out_of_10__c) averageRating  from Rating__c WITH SECURITY_ENFORCED group by Rating_of_Student__c order by AVG(Rating_out_of_10__c) ];
        return res;
    }
/**
 * @description method to get the students with first name starting with a and ending with letter a
 * @return  List<Student__c>
 */
    public static List<Student__c> getStudentsStartWithAA(){
        List<Student__c>lst=[select First_Name__c from Student__c where First_Name__c like '%aa%' WITH SECURITY_ENFORCED];
        return lst;
    }
    /**
 * @description method to get the batches with course faculty
 * @return  static List<Batch__c>
 */
    public static List<Batch__c> getBatchesWithCourseAndFaculty(){
        List<Batch__c>batches=[Select Name, Course__r.Name, Course__r.Faculty_Name__r.Name From Batch__c WITH SECURITY_ENFORCED];
        return batches;
    }
    /**
 * @description method to get the unique students name from students
 * @return  List<AggregateResult>
 */
    public static List<AggregateResult> getDiscreteStudentsCount() {
        List<AggregateResult>rslt=[select Count_Distinct(First_Name__c) from Student__c WITH SECURITY_ENFORCED];
        return rslt;
    }
    /**
 * @description method to get the students with age less than 30
 * @return  List<Student__c> 
 */
    public static List<Student__c> getSortedStudentsOver25(){
    List<Student__c>result =[select First_Name__c from Student__c where Age__c > 25 WITH SECURITY_ENFORCED order by Age__c  ];   
        return result;
    }
/**
 * @description method to get the students in batch with name testing
 * @return  List<Student_in_Batch__c> 
 */
    public static List<Student_in_Batch__c> getRecordsWithNameTesting() {
       List<Student_in_Batch__c>lst =[Select Name, Batch__r.Course__r.Faculty_Name__r.Name, Student__r.First_Name__c From Student_in_Batch__c Where Batch__r.Course__r.Faculty_Name__r.Name like '%Testing%' AND Student__r.First_Name__c like '%Testing%' WITH SECURITY_ENFORCED];
        return lst;
    }
/**
 * @description method to find the student with given list name
 * @return  List<Student__c>
 */
  public static List<Student__c> getStudentPresentInList() {
 	List<String> names = new List<String>{'John', 'Jack', 'Will', 'David'};
    List<Student__c>lst  = [select  first_name__c ,Registration_Date__c from student__c where first_name__c in :names AND Registration_Date__c = THIS_QUARTER  WITH SECURITY_ENFORCED];
        return lst;

  } 
  /**
 * @description method to get the student name and course name
 * @return List<String>
 */
    public static List<String> getStudentCourseFacultyNameList(){
  List<Student_IN_Batch__C> l = [Select Student__r.First_Name__c, Batch__r.Course__r.Name, Batch__r.Course__r.Faculty_Name__r.Name , name From Student_in_Batch__c Where Student__r.First_Name__c like 'Kri%' AND Batch__r.Course__r.Faculty_Name__r.Name like 'Kri%' AND Batch__r.Course__r.Name != 'Php' WITH SECURITY_ENFORCED];
        String temp;
        List<String>ans=new List<String>();
for(Student_in_batch__c s : l){
   temp=s.Student__r.First_Name__c + '-'+ s.name+'-' + s.Batch__r.Course__r.Name ;
    ans.add(temp);
}
return ans;        
    }
    /**
 * @description method to get the student name and course name
 * @param courseName
 * @param fee1
 * @param fee2
 * @return  List<Student__c>
 */
    public static List<Student__c> getStudentsBasedOnCourseAndFee(String courseName, Integer fee1, Integer fee2){
        List<Student__c> stulist = [Select First_Name__c From Student__c Where Course_Opted__c = :courseName AND Fee_Deposited__c > :fee1 AND Fee_Deposited__c < :fee2 WITH SECURITY_ENFORCED];
        return stulist;
    }
    
    
}