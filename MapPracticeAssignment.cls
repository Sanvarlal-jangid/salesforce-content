public class MapPracticeAssignment {
        
    
    public static Map<String, Contact> getContactMapByEmail() {
        Map<String, Contact> mp=new Map<String,Contact>();
      List<Contact>contactlist=[select firstname,lastname ,email from contact];
        for(contact c:contactlist){
            mp.put(c.email,c);
        }
        return mp;        
}
    
    public static Map<String, List<Account>> getAccountMapByIndustry() {
        List<Account>acclist=[select name,numberofemployees,industry from Account];
        Map<String, List<Account>> accMap = new Map<String, List<Account>>();
        for(Account acc:acclist){
            if(accMap.containskey(acc.industry)){
                accMap.get(acc.industry).add(acc);
            }else{
                List<Account> hold = new List<Account>();
                hold.Add(acc);
                    accMap.put(acc.industry,hold);
            }
        }
        return accMap;
        
    }

    
    public static Map<String, List<Contact>> groupContactsByFirstLetter() {
              List<Contact>contactlist=[select firstname,lastname ,email from contact];
            
        Map<String, List<Contact>> conmap = new Map<String, List<Contact>>();
        for(contact c:contactlist){
            string s=c.firstname.substring(0,1).toUpperCase();
            if(conmap.containskey(s)){
                conmap.get(s).add(c);
            }else{
                List<contact>hold=new List<contact>();
                hold.add(c);
                conmap.put(s,hold);
            }
        }
        return conmap;

    }
    
    public static Map<String, Decimal> calculateStageAmounts() {
          List<Opportunity> oppList = [SELECT StageName, Amount 
                                       FROM Opportunity 
                                  WHERE StageName != NULL AND Amount != NULL];
         Map<String, Decimal> opmap = new Map<String, Decimal>();
        for(Opportunity opp:oppList){
            if(opmap.containskey(opp.stageName)){
                opmap.put(opp.stageName,opmap.get(opp.stageName)+opp.Amount);
            }else{
                opmap.put(opp.stageName,opp.Amount);
            }
        }
        return opmap;
    }
    
    public static Map<String, List<Opportunity>> groupOpportunitiesByLeadSourceAndStage(){
        List<Opportunity> opplist = [Select Name, LeadSource, StageName From Opportunity WITH SECURITY_ENFORCED];
        Map<String, List<Opportunity>> opmap = new Map<String, List<Opportunity>>();
        for(Opportunity op : opplist){
            String hold = op.LeadSource +'-'+op.StageName;
            if(opmap.containsKey(hold)){
				opmap.get(hold).add(op);
            }
            else{
                List<Opportunity> holdlist = new List<Opportunity>();
                holdlist.add(op);
                opmap.put(hold, holdlist);
            }
        }
        return opmap;
    }
    public static Map<String, List<Lead>> groupLeadsByStatus (){
        List<Lead> leadlist = [Select FirstName, LastName, Email, Status From Lead WITH SECURITY_ENFORCED];
        Map<String, List<Lead>> leadmap = new Map<String, List<Lead>>();
        for(Lead le : leadlist){
            if(leadmap.containsKey(le.Status)){
				leadmap.get(le.Status).add(le);
            }
            else{
                List<Lead> hold = new List<Lead>();
                hold.add(le);
                leadmap.put(le.Status, hold);
            }
        }
        return leadmap;
    }
     public static Map<String, List<Bank_Account__c>> getBankAccountsByRecordType(){
        List<Bank_Account__c> balist = [Select Name, RecordType.Name, Email__c From Bank_Account__c WITH SECURITY_ENFORCED];
        Map<String, List<Bank_Account__c>> bamap = new Map<String, List<Bank_Account__c>>();
        for(Bank_Account__c ba : balist){
            
            if(bamap.containsKey(ba.RecordType.Name)){
				bamap.get(ba.RecordType.Name).add(ba);
        }
            else{
                List<Bank_Account__c> hold = new List<Bank_Account__c>();
                hold.add(ba);
                bamap.put(ba.RecordType.Name, hold);
            }
        
    }
        return bamap;
}
    
    public static Map<String, List<Case>> getCasesByPriority(){
        List<Case> caselist = [Select CaseNumber, Priority From Case WITH SECURITY_ENFORCED];
        Map<String, List<Case>> casemap = new Map<String, List<Case>>();
        for(Case ca : caselist){
            if(casemap.containsKey(ca.Priority)){
                casemap.get(ca.Priority).add(ca);
            }
            else{
                List<Case> hold = new List<Case>();
                hold.add(ca);
                casemap.put(ca.Priority, hold);
            }
        }
        return casemap;
    }
    
     public static Map<String, Integer> buildStudentMap(){
		List<Student__c> stulist = [Select CreatedBy.Name, Name From Student__c WITH SECURITY_ENFORCED];
        Map<String, Integer> stumap = new Map<String, Integer>();
        for(Student__c stu : stulist){
            if(stumap.containsKey(stu.CreatedBy.Name)){
                stumap.put(stu.CreatedBy.Name, stumap.get(stu.CreatedBy.Name)+1);
            }
            else{
                stumap.put(stu.CreatedBy.Name, 1);
            }
        }
        return stumap;
    }
    
       public static Map<String, List<Account>> buildAccountMap(){
        List<Account> acclist = [Select Name, NumberOfEmployees, BillingCountry From Account WITH SECURITY_ENFORCED];
        Map<String, List<Account>> accmap = new Map<String, List<Account>>();
        for(Account acc : acclist){
            if(accmap.containsKey(acc.BillingCountry)){
                accmap.get(acc.BillingCountry).add(acc);
            }
            else{
                List<Account> hold = new List<Account>();
                hold.add(acc);
                accmap.put(acc.BillingCountry, hold);
            }
        }
        return accmap;
    }
       public static Map<String, List<Contact>> getContactsByMailingState(){
        List<Contact> conlist = [Select FirstName, LastName, MailingState From Contact WITH SECURITY_ENFORCED];
        Map<String, List<Contact>> conmap = new Map<String, List<Contact>>();
        for(Contact con : conlist){
            if(conmap.containsKey(con.MailingState)){
                conmap.get(con.MailingState).add(con);
            }
            else{
                List<Contact> hold = new List<Contact>();
                hold.add(con);
                conmap.put(con.MailingState, hold);
            }
        }
        return conmap;
    }
    
    public static Map<Id, List<Faculty__c>> getFacultyByOwner(){
        List<Faculty__c> faclist = [Select Name, OwnerId From Faculty__c WITH SECURITY_ENFORCED];
        Map<Id, List<Faculty__c>> facmap = new Map<Id, List<Faculty__c>>();
        for(Faculty__c fac : faclist){
            if(facmap.containsKey(fac.OwnerId)){
                facmap.get(fac.OwnerId).add(fac);
            }
            else{
                List<Faculty__c> hold = new List<Faculty__c>();
                hold.add(fac);
                facmap.put(fac.OwnerId, hold);
            }
        }
        return facmap;
    }
    
}