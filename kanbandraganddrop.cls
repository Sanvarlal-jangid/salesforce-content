public with sharing class kanbandraganddrop {
     @AuraEnabled(cacheable=true)
    public static List<opportunity> getAllopportunity() {
        return [
            SELECT Id, Name, CloseDate,Amount,StageName FROM opportunity
        
        ];
    }
    @AuraEnabled
    public static void updateoppStatus(Id taskId,String taskNewStatus){
   
            Opportunity opp = new Opportunity(Id = taskId, StageName = taskNewStatus);
            update opp;
           
       
    }




    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getopportunityAll(String stageName, Integer offset, Integer limitSize) {
        String query = 'SELECT Id, Name, Amount, StageName FROM Opportunity WHERE StageName = :stageName ORDER BY Name LIMIT :limitSize OFFSET :offset';
        return Database.query(query);
    }

  

   
}