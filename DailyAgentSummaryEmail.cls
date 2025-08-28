public class DailyAgentSummaryEmail {

    public static void sendDailySummaryEmails() {


      
   //   List<User> allAgents=   [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'dsoujaprofile' AND IsActive = TRUE ];
         List<User> allAgents=   [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE ];
       system.debug('agent user'+allAgents);
        Set<Id> agentIds = new Set<Id>();

        for (User u : allAgents) {
            agentIds.add(u.Id);
        }


        List<Case> allCases = [SELECT Id, OwnerId, CaseNumber, Subject, Status, Priority, Description
                               FROM Case WHERE OwnerId IN :agentIds AND Status != 'Closed'];

   
        List<Task> allTasks = [SELECT Id, OwnerId, Subject, Status, Priority, ActivityDate, WhatId
                               FROM Task WHERE OwnerId IN :agentIds AND Status != 'Completed'];

       
        Set<Id> taskCaseIds = new Set<Id>();
        for (Task t : allTasks) {
            if (t.WhatId != null && String.valueOf(t.WhatId).startsWith('500')) {
                taskCaseIds.add(t.WhatId);
            }
        }

        Map<Id, Case> relatedCaseMap = new Map<Id, Case>();
        if (!taskCaseIds.isEmpty()) {
            for (Case c : [SELECT Id, CaseNumber, Subject FROM Case WHERE Id IN :taskCaseIds]) {
                relatedCaseMap.put(c.Id, c);
            }
        }

       
        Map<Id, List<Case>> agentCaseMap = new Map<Id, List<Case>>();
        for (Case c : allCases) {
            if (!agentCaseMap.containsKey(c.OwnerId)) {
                agentCaseMap.put(c.OwnerId, new List<Case>());
            }
            agentCaseMap.get(c.OwnerId).add(c);
        }

        Map<Id, List<Task>> agentTaskMap = new Map<Id, List<Task>>();
        for (Task t : allTasks) {
            if (!agentTaskMap.containsKey(t.OwnerId)) {
                agentTaskMap.put(t.OwnerId, new List<Task>());
            }
            agentTaskMap.get(t.OwnerId).add(t);
        }

  
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (User agent : allAgents) {
            String body = 'Daily Task & Case Summary\n\n';
            body += 'Hi ' + agent.Name + ',\n\n';
            body += 'Here is the summary of your open cases and tasks as of today:\n\n';

     
            body += 'Open Cases:\n';
            List<Case> cases = agentCaseMap.get(agent.Id);
            if (cases == null || cases.isEmpty()) {
                body += 'No open cases.\n\n';
            } else {
                for (Case c : cases) {
                    body += '- Case Number: ' + c.CaseNumber + '\n';
                    body += '  Subject: ' + c.Subject + '\n';
                    body += '  Status: ' + c.Status + '\n';
                    body += '  Priority: ' + c.Priority + '\n';
                    body += '  Description: ' + c.Description + '\n\n';
                }
            }

       
            body += 'Assigned Tasks:\n';
            List<Task> tasks = agentTaskMap.get(agent.Id);
            if (tasks == null || tasks.isEmpty()) {
                body += 'No assigned tasks.\n';
            } else {
                for (Task t : tasks) {
                    String caseNumber = '';
                    String caseSubject = '';
                    if (relatedCaseMap.containsKey(t.WhatId)) {
                        Case related = relatedCaseMap.get(t.WhatId);
                        caseNumber = related.CaseNumber;
                        caseSubject = related.Subject;
                    }

                    body += '- Task Name: ' + t.Subject + '\n';
                    body += '  Associated Case: ' + caseNumber + ' (' + caseSubject + ')\n';
                    body += '  Status: ' + t.Status + '\n';
                    body += '  Priority: ' + t.Priority + '\n';
                    body += '  Due Date: ' + String.valueOf(t.ActivityDate) + '\n\n';
                }
            }


            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { agent.Email });
            email.setSubject('Your Daily Case & Task Summary');
            email.setPlainTextBody(body);

            emails.add(email);
        }

    
        if (!emails.isEmpty()) {
           // Messaging.sendEmail(emails);
              List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);

     for(Messaging.SendEmailResult MSR : results)
        {
            if(MSR.success )
            {
                system.debug('Mail Send Successfully');
            }
            else
            {
                system.debug('The Email Error is :- ' + MSR.errors[0].message);
            }
        }
    }
      
    
  }
}