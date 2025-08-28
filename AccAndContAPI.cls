/**
 * @author Sanvarlal Jangid
 * @description REST API to retrieve Account and related Contact information based on the Account Name Returns contact details and account info if found, else returns a 'not found' message.
 * @param JSON body: { "Name": "Account Name" }
 */
@RestResource(urlMapping='/getAccCont')
global class AccAndContAPI {

    global class Wrapperclass {
        public String Name;
    }

    @HttpPost
    global static String getAccounAndContact() {

        RestRequest req = RestContext.request;
        Wrapperclass input = (Wrapperclass) JSON.deserialize(req.requestBody.toString(), Wrapperclass.class);

        List<Account> accList = [select Name, NumberOfEmployees, (select Name from Contacts) from Account
                                 where Name = :input.Name LIMIT 1];

        if (accList.isEmpty()) {
            return 'No Account Exists with name ' + input.Name;
        }

        Account acc = accList[0];

        String response = '{“Contacts”:{';
        Integer i = 1;

        for(Contact con : acc.Contacts){
            response += '“Contact'+ i+'”={“Name”=”'+con.Name + '”},';
            i++;
        }

        if(acc.Contacts.size() > 0){
            response = response.removeEnd(',');
        }

        response += '},“Name”=”'+ acc.Name+'”,“NumberOfEmployees”='+ acc.NumberOfEmployees + '}';

        return response;
    }
}