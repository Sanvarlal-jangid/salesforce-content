/*
 * @RestResource(urlMapping='/exportaccounts/*')
global class ExternalAccountProcessor {
    
    public class AccountInput {
        public String Name;
        public Decimal AnnualRevenue;
        public Decimal No_of_Account;
        public Decimal No_of_Contact;
        public boolean Contact_per_Account;
    }
  @HttpPost
    global static void  importAccounts() {
           RestRequest req = RestContext.request;

 List<AccountInput>inputList = (List<AccountInput>) JSON.deserialize( req.requestBody.toString(),List<AccountInput>.class );
       list<Account>parentaccounts = new list<Account>();
       map<string,account>nametoparent = new map<string,account>();
        for(AccountInput IL:inputList){
            Account acc = new Account();
            acc.name = IL.Name;
            acc.AnnualRevenue = IL.AnnualRevenue;
            parentaccounts.Add(acc);      
            nametoparent.put(IL.Name,acc);
        }
        
        try{
        insert parentaccounts;
        }catch(exception e){
            system.debug('error while inserting parentaccoutns'+e.getmessage());
        }
    
        
      map<Id,List<Account>>parenttochildaccount = new map<Id,List<Account>>();
        list<account>childstoinsert = new list<account>();
        
     for(AccountInput IL:inputList){
         Account temp=nametoparent.get(IL.Name);
         Decimal amount = temp.AnnualRevenue/IL.No_of_Account;
         for(Integer i=1;i<=IL.No_of_Account;i++){
             Account childacc = new Account();
             childacc.ParentId = temp.Id;
             childacc.name=temp.name+i;
             childacc.AnnualRevenue=amount;
             childstoinsert.add(childacc);
             if(!parenttochildaccount.containskey(temp.id)){
                parenttochildaccount.put(temp.id,new List<account>());
             }
             parenttochildaccount.get(temp.id).add(childacc);
             
         }
    }
        
           try{
        insert childstoinsert;
        }catch(exception e){
            system.debug('error while inserting childaccounts'+e.getmessage());
        }
        list<contact>allchildstoinsert=new list<contact>();
        for(AccountInput IL:inputList){
             Account temp=nametoparent.get(IL.Name); 
            if(IL.Contact_per_Account){
                List<account>accountlist = parenttochildaccount.get(temp.id);
              list<contact>contactlist=  createchildtoeachaccount(accountlist,IL.No_of_Contact);
                allchildstoinsert.addAll(contactlist);
                
            }else{
                for(integer i =1;i<=IL.No_of_Contact;i++){
                  contact con = new contact();
                   con.accountid=temp.Id;
                   con.LastName =temp.Name+i;
                    allchildstoinsert.add(con);
                }
            }
        }
           try{
        insert allchildstoinsert;
        }catch(exception e){
            system.debug('error while inserting childacccontacts'+e.getmessage());
        }
        
        
}
    public static list<contact> createchildtoeachaccount(list<account>accountlist,Decimal noofcontact){
        list<contact>listofcontact = new list<contact>();
        for(account acc:accountlist){
            for(integer i=1;i<=noofcontact;i++){
                
                contact con = new contact();
                con.accountid=acc.Id;
                con.LastName =acc.Name+i;
               
                listofcontact.add(con);
                
            }
        }
        return listofcontact;
        
    }
}
*/
@RestResource(urlMapping='/exportaccounts/*')
global class ExternalAccountProcessor {
    
     
    global class AccountInput {
        public String Name;
        public Decimal AnnualRevenue;
        public Decimal No_of_Account;
        public Decimal No_of_Contact;
        public boolean Contact_per_Account;
    }

    global class AccountResponse {
        @AuraEnabled public String Status;
        @AuraEnabled public String Account_Id;
        @AuraEnabled public String Message;
    }

    @HttpPost
    global static List<AccountResponse> importAccounts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 

 List<AccountInput>inputList = (List<AccountInput>) JSON.deserialize( req.requestBody.toString(),List<AccountInput>.class );
        List<AccountResponse> responses = new List<AccountResponse>(); 

        List<Account> parentaccounts = new List<Account>();
        Map<String, Account> nametoparent = new Map<String, Account>();

        for (AccountInput IL : inputList) {
            AccountResponse currentResponse = new AccountResponse();
            currentResponse.Account_Id = null;
            
            if (IL.AnnualRevenue != null && IL.AnnualRevenue <= 0) {
                currentResponse.Status = 'Error';
                currentResponse.Message = 'Annual Revenue must be greater than zero.';
                responses.add(currentResponse);
                continue; 
            }

            Account acc = new Account();
            acc.name = IL.Name;
            acc.AnnualRevenue = IL.AnnualRevenue;
            parentaccounts.add(acc);
            nametoparent.put(IL.Name, acc);

            currentResponse.Status = 'Success';
            currentResponse.Message = 'Account and related record created successfully.';
            responses.add(currentResponse);
        }

      
       
     
             Database.SaveResult[] srParent = Database.insert(parentaccounts, false); 
   

        for (Integer i = 0; i < parentaccounts.size(); i++) {
            if (srParent != null && i < srParent.size() && srParent[i].isSuccess()) {
                for (AccountResponse resp : responses) {
                    if (resp.Status == 'Success' && nametoparent.get(inputList[i].Name) == parentaccounts[i]) {
                        resp.Account_Id = srParent[i].getId();
                        break; 
                    }
                }
            } else if (srParent != null && i < srParent.size() && !srParent[i].isSuccess()) {
                for (AccountResponse resp : responses) {
                    if (resp.Status == 'Success' && resp.Message == 'Account and related record created successfully.') {
                        resp.Status = 'Error';
                        resp.Message = srParent[i].getErrors()[0].getMessage(); 
                        resp.Account_Id = null;
                        break;
                    }
                }
            }
        }

        Map<Id, List<Account>> parenttochildaccount = new Map<Id, List<Account>>();
        List<Account> childstoinsert = new List<Account>();

        for (AccountInput IL : inputList) {
            Account temp = nametoparent.get(IL.Name);
            if (temp != null && temp.Id != null) {
                Decimal amount = (IL.No_of_Account != null && IL.No_of_Account > 0) ? temp.AnnualRevenue / IL.No_of_Account : 0; // Handle division by zero

                for (Integer i = 1; i <= IL.No_of_Account; i++) {
                    Account childacc = new Account();
                    childacc.ParentId = temp.Id;
                    childacc.name = temp.name + ' Child ' + i; 
                    childacc.AnnualRevenue = amount;
                    childstoinsert.add(childacc);
                    if (!parenttochildaccount.containsKey(temp.id)) {
                        parenttochildaccount.put(temp.id, new List<Account>());
                    }
                    parenttochildaccount.get(temp.id).add(childacc);
                }
            }
        }
        
      
            insert childstoinsert;
       

        List<Contact> allchildstoinsert = new List<Contact>();
        for (AccountInput IL : inputList) {
            Account temp = nametoparent.get(IL.Name);
            if (temp != null && temp.Id != null) {
                if (IL.Contact_per_Account) {
                    List<Account> accountlist = parenttochildaccount.get(temp.id);
                    if (accountlist != null) {
                        List<Contact> contactlist = createchildtoeachaccount(accountlist, IL.No_of_Contact);
                        allchildstoinsert.addAll(contactlist);
                    }
                } else {
                    for (integer i = 1; i <= IL.No_of_Contact; i++) {
                        Contact con = new Contact();
                        con.accountid = temp.Id;
                        con.LastName = temp.Name + ' Contact ' + i; 
                        allchildstoinsert.add(con);
                    }
                }
            }
        }

  
            insert allchildstoinsert;
       

        res.statusCode = 200; 
        res.addHeader('Content-Type', 'application/json');
        
        return responses;
    }

    public static List<Contact> createchildtoeachaccount(List<Account> accountlist, Decimal noofcontact) {
        List<Contact> listofcontact = new List<Contact>();
        for (Account acc : accountlist) {
            for (integer i = 1; i <= noofcontact; i++) {
                Contact con = new Contact();
                con.accountid = acc.Id;
                con.LastName = acc.Name + ' Child Contact ' + i; 
                listofcontact.add(con);
            }
        }
        return listofcontact;
    }
}