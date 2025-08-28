@RestResource(urlMapping='/Insetaccountcontact')
global with sharing class PracticeresourceQ2 {
    
   global class Accountwrapper {
     public String sourceid;
     public String Name;
     public String Phone;
    public String website;
     public List<ContactWrapper> Contact;
}

       global class Contactwrapper {
         public String sourceid;
        public String firstname;
         public String Email;
}    
    
 
    global class ContactResponse {
    public Integer Status;
    public String contactid;
    public String Error;
}

global class sendResponse {
    public Integer Status;
    public String accountid;
    public String Error;
    public List<ContactResponse> contact;
}


    @HttpPost
    global static sendResponse processIncomingData() {
        sendResponse response = new sendResponse();
        RestRequest req = RestContext.request;
        //system.debug(req.requestbody);
        String str = req.requestbody.tostring();
       // system.debug(str);
         List<Accountwrapper>reqst=(List<Accountwrapper>)JSON.deserialize(str,List<Accountwrapper>.class);
        system.debug(reqst);
        
        Set<String>accsrcids = new Set<String>();
        Set<String>consrcids = new Set<String>();

        
        for(Accountwrapper a :reqst){
            if(a.sourceid != null){
                accsrcids.add(a.sourceid);
            }
            if(a.contact != null){
                for(Contactwrapper c : a.contact){
                    if(c.sourceid != null){
                        consrcids.add(c.sourceid);
                    }
                }
            }
        }
        Map<String,Account>sidwithacc = new Map<String,Account>();
        List<Account>aclist = [select id ,sourceid__c ,Name, Phone, Website from account where sourceid__c in :accsrcids];
        for(Account ac:aclist){
            sidwithacc.put(ac.sourceid__c,ac);
        }
        
      Map<String,contact>sidwithcon = new Map<String,contact>();
        
       List<contact>conlist = [select id ,sourceid__c from contact where sourceid__c in :consrcids];
        for(contact c:conlist){
            sidwithcon.put(c.sourceid__c,c);
        }
        
        List<Account>upsertelist = new List<Account>();
        for(Accountwrapper acc : reqst){
            
           
            if(acc.sourceid != null && sidwithacc.containskey(acc.sourceid)){
                Account a = sidwithacc.get(acc.sourceid);
                a.Name = acc.Name;
                a.Website = acc.website;
                a.Phone = acc.Phone;
                upsertelist.Add(a);
              
                
            }else if (acc.sourceid != null){
                account a = new account();
                 a.Name = acc.Name;
                a.Website = acc.website;
                a.Phone = acc.Phone;
                a.sourceid__c = acc.sourceid;
            }
            
        }
        
        
        
        
        
        

      
        

        return response;
    }
}