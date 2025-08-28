@RestResource(urlMapping='/issueReport/*')
global with sharing class IssueReportService {
    
     global class MyCaseWrapper {
        public String subject;
        public String description;
        public String origin;
        public String priority;
        public String status;
        public String type;
    }

    @HttpPost
    global static string createIssueReport() {
        RestRequest req = RestContext.request;
        String jsonBody = req.requestBody.toString();

      
        system.debug('jsonbdoy'+jsonBody);
        MyCaseWrapper caseData = (MyCaseWrapper) JSON.deserialize(jsonBody, MyCaseWrapper.class);
        system.debug('wrapperobject'+caseData);
        

       
        List<Case> existing = [SELECT Id FROM Case WHERE Subject = :caseData.Subject LIMIT 1];
        if (!existing.isEmpty()) {
            system.debug('Duplicate subject. Case not created.');
            return 'Duplicate subject. Case not created';
        }
    
         List<AggregateResult> results = [  SELECT OwnerId, COUNT(Id)tsks FROM task GROUP BY OwnerId ];
        map<id ,integer>usertotask = new map<id,integer>();
       for (AggregateResult ar : results) {
            Id ownerId = (Id) ar.get('OwnerId');
            Integer count = (Integer) ar.get('tsks');
            usertotask.put(ownerId, count);
        
       }
       
       Case newCase = new Case(
                Subject = caseData.subject,
                Description = caseData.description,
                Origin = caseData.origin,
                Priority = caseData.priority,
                Status = caseData.status,
                Type = caseData.type
            );

            
            Database.SaveResult sr = Database.insert(newCase, false); 

              if (sr.isSuccess()) {
                       System.debug('case inserted successfully: ' + sr.getId());
                    } else {
                     for (Database.Error err : sr.getErrors()) {
                        System.debug('Error inserting case: ' + err.getMessage());
                    }
                   }


        List<User>agents = [SELECT Id FROM User WHERE IsActive = TRUE];
        list<task>taskinsert = new list<task>();
        Boolean taskAssigned = false;
        for(user u:agents){
            integer totaltask = usertotask.get(u.Id);
            if(totaltask < 2){
               Task t = new Task(WhatId = newCase.Id, OwnerId = u.Id, Subject =newCase.Subject, Status = 'Not Started');
                taskinsert.add(t);
                taskAssigned = true;
                break;
            }
        }
          list<Database.SaveResult> kr = Database.insert(taskinsert, false); 
        for(Database.SaveResult tr :kr){
              if (tr.isSuccess()) {
                       System.debug('task inserted successfully: ' + tr.getId());
                    } else {
                     for (Database.Error err : tr.getErrors()) {
                        System.debug('Error inserting task: ' + err.getMessage());
                    }
                   }
        }
        Id queue=[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'assigntasktouser'].id;
         if (!taskAssigned) {
            Task t = new Task(WhatId = newCase.Id, OwnerId=queue, Subject =newCase.Subject, Status = 'Not Started');
            insert t;
        }
     
        
     return 'inserted case';
   
       }
}