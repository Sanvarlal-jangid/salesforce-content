public with sharing class DragAndDropComponentHandler {

   
    @AuraEnabled(cacheable=true)
    public static List<Project_Task__c> getAllTasks() {
        return [
            SELECT Id, Name, Status__c, Assigned_To__c, Assigned_To__r.Name, Due_Date__c, Priority__c, Project__c, Project__r.Name
            FROM Project_Task__c
        
        ];
    }

    
    @AuraEnabled
    public static String updateTaskStatus(Id taskId, String newStatus) {
        try {
            Project_Task__c task = new Project_Task__c(Id = taskId, Status__c = newStatus);
            update task;
            return 'Success';
        } catch (Exception e) {
         
            return 'Error updating task status: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String saveTask(Project_Task__c taskToSave) {
        try {
            // Basic validation: Task Name should not be empty
            if (String.isBlank(taskToSave.Name)) {
                return 'Validation Error: Task Name cannot be empty.';
            }
            upsert taskToSave;
            return 'Success';
        } catch (Exception e) {
            // Return error message for LWC to display
            return 'Error saving task: ' + e.getMessage();
        }
    }

  
    @AuraEnabled(cacheable=true)
    public static List<String> getTaskDetailsFieldSetFields() {
        List<String> fieldNames = new List<String>();
        // Iterate over the fields defined in the 'TaskDetailsFieldSet'
        for (Schema.FieldSetMember fsm : Schema.SObjectType.Project_Task__c.FieldSets.TaskDetailsFieldSet.getFields()) {
            fieldNames.add(fsm.getFieldPath()); // Adds API name of the field
        }
        return fieldNames;
    }
    
@AuraEnabled(cacheable=true)
public static List<Project_Task__c> getPaginatedTasks(String status, Integer offsetVal, Integer limitSize) {
    return [
        SELECT Id, Name, Status__c, Assigned_To__c, Assigned_To__r.Name, Project__c, Project__r.Name,
               Due_Date__c, Priority__c
        FROM Project_Task__c
        WHERE Status__c = :status
        ORDER BY CreatedDate ASC
        LIMIT :limitSize OFFSET :offsetVal
    ];
}

}