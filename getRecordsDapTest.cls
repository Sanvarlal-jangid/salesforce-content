public class getRecordsDapTest {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContacts(){
	    String q = 'Select ';
	    List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Contact');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        Map<String,String> ma = new Map<String,String>();
        boolean flag = true;
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            ma.put(String.valueOf(field),String.valueOf(F.getLabel()));
            if(flag){
                q = q +  String.valueOf(field); 
                flag = false;
            }else {
                q = q + ' , ' + String.valueOf(field); 
            }
	    }
	    q = q + ' From Contact';
	    return Database.query(q);
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getFields(){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Contact');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        Map<String,String> ma = new Map<String,String>();
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            ma.put(String.valueOf(field),String.valueOf(F.getLabel()));
	    }
        return ma;
    }
}