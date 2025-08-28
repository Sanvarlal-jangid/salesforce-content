/**
 * @author Sanvarlal Jangid
 * @description This REST API converts Lead records based on their names and a flag (Createopp)
 * @param JSON body
 */
@RestResource(urlMapping='/convertLead')
global class LeadConvertApi_Q1b {
    
    global class LeadInput {
        public String LeadName;
        public Boolean Createopp;
    }

    @HttpPost
    global static String convertLeadApi() {
        RestRequest req = RestContext.request;
        
        List<LeadInput> inputs = (List<LeadInput>) JSON.deserialize(req.requestBody.toString(), List<LeadInput>.class);
        List<id> convertedlead = new List<id>();
        List<String> strlistWithOpp = new List<String>();
        List<String> strlistWithoutOpp = new List<String>();
        
        for(LeadInput l : inputs){
            if(l.Createopp == true){
                strlistWithOpp.add(l.LeadName);
            }else{
                strlistWithoutOpp.add(l.LeadName);
            }
        }
        
        List<Lead> leadRecordsWithOpp = [Select id From Lead Where Name = :strlistWithOpp AND isConverted = false WITH SECURITY_ENFORCED];
        List<Lead> leadRecordsWithoutOpp = [Select id From Lead Where Name = :strlistWithoutOpp AND isConverted = false WITH SECURITY_ENFORCED];
        
        if(leadRecordsWithOpp.isEmpty() && leadRecordsWithoutOpp.isEmpty()){
            return 'No leads were processed.';
        }

        List<Database.leadConvert> convertedlistWithOpp = new List<Database.leadConvert>();
        for(Lead leadRecord : leadRecordsWithOpp){
            Database.leadConvert con = new Database.leadConvert();
            con.setLeadId(leadRecord.id);
            con.setDoNotCreateOpportunity(false);
            con.convertedStatus = 'Closed - Converted';
            con.ownerId = userInfo.getuserid();
            convertedlistWithOpp.add(con);
        }
        Database.leadConvertResult[] resWithOpp = Database.convertLead(convertedlistWithOpp);
        
        List<String> resultstring = new List<String>();

        for(Database.leadConvertResult d : resWithOpp){
            if(d.isSuccess()){
				resultstring.add(d.getLeadID());
            }
        }
        
        List<Database.leadConvert> convertedlistWithoutOpp = new List<Database.leadConvert>();
        for(Lead leadRecord : leadRecordsWithoutOpp){
            Database.leadConvert con = new Database.leadConvert();
            con.setLeadId(leadRecord.id);
            con.setDoNotCreateOpportunity(TRUE);
            con.convertedStatus = 'Closed - Converted';
            con.ownerId = userInfo.getuserid();
            convertedlistWithoutOpp.add(con);
        }
        Database.leadConvertResult[] resWithoutOpp = Database.convertLead(convertedlistWithoutOpp);
        
        for(Database.leadConvertResult d : resWithoutOpp){
            if(d.isSuccess()){
				resultstring.add(d.getLeadID());
            }
        }
        return 'These leads are converted: '+JSON.serialize(resultstring);
    }
}