public class expandopportunitystage {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getAllOpportunities() {
        // Fetches Name, Amount, and StageName for all opportunities
        return [SELECT Id, Name, Amount, StageName FROM Opportunity];
    }

    @AuraEnabled
    public static String updateOpportunity(Opportunity opp) {
        try {
            update opp;
            return 'Success';
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteOpportunity(Id oppId) {
        try {
            Opportunity oppToDelete = new Opportunity(Id = oppId);
            delete oppToDelete;
            return 'Success';
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}