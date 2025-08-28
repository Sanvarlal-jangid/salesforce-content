@RestResource(urlMapping='/CreateStudent')
Global class createstudentapi {
    
    @HttpPost
    global Static String mymethod(){
        //handle request
        RestRequest req = RestContext.request;
        String str = req.requestBody.tostring();
        Map<String,Object>mapobj = (Map<String,Object>)json.deserializeUntyped(str);
           //system.debug(mapobj.get('Name'));
        
        //process record
        Student__c std = new Student__c();
        std.First_Name__c = string.valueof(mapobj.get('Name'));
        std.Age__c  = Integer.valueof(mapobj.get('age'));
        
        
        insert std;
        
      
        return 'Inserted'; 
    }

}