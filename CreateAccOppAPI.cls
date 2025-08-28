/**
 * @author Sanvarlal Jangid
 * @description REST API to create Accounts and related Opportunities from input JSON.
 * @param JSON body format
 */
@RestResource(urlMapping='/CreateAccOpp')
global class CreateAccOppAPI {

    global class OpportunityWrapper {
        public String Name;
        public String Stage;
        public String closeDate;
    }

    global class AccountWrapper {
        public String AccountName;
        public List<OpportunityWrapper> Opportunities;
    }

    @HttpPost
    global static Map<String, String> accOpp() {

        Map<String, String> resultMap = new Map<String, String>();
        String body = RestContext.request.requestBody.toString();
        List<AccountWrapper> inputAccounts = (List<AccountWrapper>) JSON.deserialize(body, List<AccountWrapper>.class);

        Map<AccountWrapper, Account> validAccountMap = new Map<AccountWrapper, Account>();
        List<Account> accountsToInsert = new List<Account>();

        for (AccountWrapper aw : inputAccounts) {
            if (aw.AccountName!=null) {
                Account acc = new Account(Name = aw.AccountName);
                accountsToInsert.add(acc);
                validAccountMap.put(aw, acc);
            } else {
                resultMap.put(null, 'Account creation failed with related opportunity');
            }
        }

        insert accountsToInsert;

        Map<String, Id> accountNameToId = new Map<String, Id>();
        for (Account acc : accountsToInsert) {
            accountNameToId.put(acc.Name, acc.Id);
            resultMap.put(acc.Name, 'Account successfully created');
        }

        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();

        for (AccountWrapper aw : inputAccounts) {
            if (aw.AccountName!=null && accountNameToId.containsKey(aw.AccountName)) {
                Id accId = accountNameToId.get(aw.AccountName);

                if (aw.Opportunities != null) {
                    for (OpportunityWrapper ow : aw.Opportunities) {
                        if (ow.Stage!=null) {
                            Opportunity opp = new Opportunity(
                                Name = ow.Name,
                                StageName = ow.Stage,
                                CloseDate = Date.parse(ow.closeDate),
                                AccountId = accId
                            );
                            opportunitiesToInsert.add(opp);
                            
                        } else {
                            resultMap.put(ow.Name, 'Opportunity insertion failed');
                        }
                    }
                }
            }
        }

        if (!opportunitiesToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(opportunitiesToInsert, false);

            for (Integer i = 0; i < results.size(); i++) {
                Opportunity opp = opportunitiesToInsert[i];
                if (results[i].isSuccess()) {
                    resultMap.put(opp.Name, 'Opportunity inserted successfully');
                } else {
                    resultMap.put(opp.Name, 'Opportunity insertion failed');
                }
            }
        }

        return resultMap;
    }
}