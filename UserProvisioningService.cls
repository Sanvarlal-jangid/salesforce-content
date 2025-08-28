@RestResource(urlMapping='/users/*')
global class UserProvisioningService {
    
    global class WrapperUser {
        public String firstName;
        public String lastName;
        public String email;
        public String username;
        public String profileName;
        public String accountName;
    }
    
    @HttpPost
    global static void provisionUsers() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        System.debug('Received request body: ' + requestBody);
        
        
        List<WrapperUser>  userRequests = (List<WrapperUser>) JSON.deserialize(requestBody, List<WrapperUser>.class);
        System.debug('Deserialized user requests: ' + userRequests);
        
        
        List<User> usersToCreate = new List<User>();
        Set<String> profileNames = new Set<String>();
        
        for (WrapperUser item : userRequests) {
            if (String.isNotBlank(item.profileName)) {
                profileNames.add(item.profileName);
            }
        }
        System.debug('Collected profile names for initial user creation: ' + profileNames);
        
        Map<String, Profile> profileNameMap = new Map<String, Profile>();
        Map<Id, Profile> profileIdMap = new Map<Id, Profile>();
        
        for (Profile p : [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name IN :profileNames]) {
            profileNameMap.put(p.Name, p);
            profileIdMap.put(p.Id, p); 
        }
        System.debug('Fetched profile name map (Name -> Profile): ' + profileNameMap);
        System.debug('Fetched profile ID map (Id -> Profile): ' + profileIdMap);
        
        
        Map<Id, UserLicense> licenseMap = new Map<Id, UserLicense>([SELECT Id,name, TotalLicenses, UsedLicenses FROM UserLicense]);
        System.debug('Fetched license map: ' + licenseMap);
        
        Map<Id, Integer> newUserCountByProfile = new Map<Id, Integer>();
        
        for (WrapperUser r : userRequests) {
            if (profileNameMap.containsKey(r.profileName)) {
                Profile p = profileNameMap.get(r.profileName);
                
                User newUser = new User(
                    FirstName = r.firstName,
                    LastName = r.lastName,
                    Email = r.email,
                    Username = r.username,
                    ProfileId = p.Id,
                    IsActive = true,
                    Alias = r.firstName.substring(0, 3) + r.lastName.substring(0, 3),
                    CommunityNickname = r.username,
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LanguageLocaleKey = 'en_US'
                );
                System.debug('User going to insert in list ='+ newUser);
                usersToCreate.add(newUser);
                System.debug('Prepared new user for initial insert: ' + newUser);
                
                Integer count = newUserCountByProfile.get(p.Id);
                newUserCountByProfile.put(p.Id, (count == null ? 1 : count + 1));
            } else {
                System.debug('Profile not found for: ' + r.profileName + '. User ' + r.username + ' will not be created.');
            }
        }
        
        List<User> usersToDeactivate = new List<User>();
        
        for (Id profileId : newUserCountByProfile.keySet()) {
            Profile p = profileIdMap.get(profileId); 
            System.debug('Profile for deactivation check: ' + p + ' and this is profileId: ' + profileId);
            
            if (p != null && p.UserLicenseId != null && licenseMap.containsKey(p.UserLicenseId)) {
                UserLicense license = licenseMap.get(p.UserLicenseId);
                Integer available = license.TotalLicenses - license.UsedLicenses;
                Integer requested = newUserCountByProfile.get(profileId);
                System.debug('License check for profile ' + p.Name + ': available=' + available + ', requested=' + requested);
                
                if (requested > available) {
                    Integer l = requested - available;
                    List<User> users = [SELECT Id, IsActive, LastLoginDate FROM User WHERE IsActive = true AND ProfileId = :profileId AND UserRoleId != null // Query by ProfileId
                                        ORDER BY CreatedDate ASC
                                        LIMIT :l
                                       ];
                    for (User u : users) {
                        u.IsActive = false;
                        usersToDeactivate.add(u);
                    }
                    System.debug('Users marked for deactivation for profile ' + p.Name + ': ' + users.size());
                }
            }
        }
        
        Integer usersDeactivatedCount = 0;
        if (!usersToDeactivate.isEmpty()) {
            try {
                update usersToDeactivate;
                usersDeactivatedCount = usersToDeactivate.size();
                System.debug('Deactivated users: ' + usersDeactivatedCount);
            } catch (DMLException e) {
                System.debug('Error deactivating users: ' + e.getMessage());
            }
        }
        
        Integer usersSuccessfullyInserted = 0;
        Map<String, WrapperUser> usernameToWrapperUserMap = new Map<String, WrapperUser>();
        for (WrapperUser wr : userRequests) {
            usernameToWrapperUserMap.put(wr.username, wr);
        }
        
        if (!usersToCreate.isEmpty()) {
            try {
                insert usersToCreate;
                usersSuccessfullyInserted = usersToCreate.size();
                System.debug('Inserted users: ' + usersSuccessfullyInserted);
                /*
                
                Map<Id, String> userIdToAccountNameMap = new Map<Id, String>();
                for(User u : usersToCreate) {
                    if (u.Id != null && usernameToWrapperUserMap.containsKey(u.Username) &&
                        String.isNotBlank(usernameToWrapperUserMap.get(u.Username).accountName)) {
                            userIdToAccountNameMap.put(u.Id, usernameToWrapperUserMap.get(u.Username).accountName);
                        }
                }
                
                if (!userIdToAccountNameMap.isEmpty()) {
                    UserProvisioningService.processAccountAndUserRelationAsync(JSON.serialize(userIdToAccountNameMap));
                }
                */
            } catch (DMLException e) {
                System.debug('Error inserting users: ' + e.getMessage());
                
            }
        } 
    }
    
    @future
    private static void processAccountAndUserRelationAsync(String userIdToAccountNameMapJson) {
        Map<Id, String> userIdToAccountNameMap;
        try {
            userIdToAccountNameMap = (Map<Id, String>) JSON.deserialize(userIdToAccountNameMapJson, Map<Id, String>.class);
            System.debug('Deserialized userIdToAccountNameMap in future method: ' + userIdToAccountNameMap);
        } catch (Exception e) {
            System.debug('Error deserializing userIdToAccountNameMap in future method: ' + e.getMessage());
            return;
        }
        
        if (userIdToAccountNameMap.isEmpty()) {
            System.debug('No users or account names to process in async method.');
            sendSummaryEmail(0, 0, 0); // Send email even if nothing processed
            return;
        }
        
        List<Account> accountsToInsert = new List<Account>();
        Set<String> uniqueAccountNames = new Set<String>(userIdToAccountNameMap.values());
        Map<String, Id> accountNameToDesiredOwnerId = new Map<String, Id>();
        
        // Map each unique account name to the first user encountered that requested it
        // This implicitly handles the case where multiple users might request the same account
        // by picking one as the owner.
        for (Id userId : userIdToAccountNameMap.keySet()) {
            String accountName = userIdToAccountNameMap.get(userId);
            if (String.isNotBlank(accountName) && !accountNameToDesiredOwnerId.containsKey(accountName)) {
                accountNameToDesiredOwnerId.put(accountName, userId);
            }
        }
        System.debug('Account to Desired Owner ID map for new accounts: ' + accountNameToDesiredOwnerId);
        
        Set<String> existingAccountNames = new Set<String>();
        for(Account acc : [SELECT Name FROM Account WHERE Name IN :uniqueAccountNames]) {
            existingAccountNames.add(acc.Name);
        }
        System.debug('Existing account names found (will be skipped for creation): ' + existingAccountNames);
        
        for (String accName : uniqueAccountNames) {
            if (!existingAccountNames.contains(accName)) { 
                Id desiredOwnerId = accountNameToDesiredOwnerId.get(accName);
                
                Account newAcc = new Account(Name = accName);
                if (desiredOwnerId != null) {
                    newAcc.OwnerId = desiredOwnerId;
                }
                accountsToInsert.add(newAcc);
            } else {
                System.debug('Account ' + accName + ' already exists. Skipping creation.');
            }
        }
        
        Integer accountsSuccessfullyInserted = 0;
        if (!accountsToInsert.isEmpty()) {
            try {
                insert accountsToInsert;
                accountsSuccessfullyInserted = accountsToInsert.size();
                System.debug('Successfully inserted accounts with owners: ' + accountsSuccessfullyInserted);
            } catch (DMLException e) {
                System.debug('Error inserting accounts in async context: ' + e.getMessage());
            }
        }
        
        
        sendSummaryEmail(accountsSuccessfullyInserted, 0, userIdToAccountNameMap.size());
    }
    
    private static void sendSummaryEmail(Integer accountsInserted, Integer accountsUpdated, Integer usersProcessedInAsync) {
        List<User> admins = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        if (admins.isEmpty()) {
            System.debug('No active System Administrator found to send email.');
            return;
        }
        
        String adminEmail = admins[0].Email;
        String subject = 'User & Account Provisioning Summary (Async Process)';
        String body = 'User and Account provisioning process has completed asynchronously.\n\n';
        body += 'Users initially processed (inserted/deactivated): ' + usersProcessedInAsync + '\n';
        body += 'Accounts newly inserted: ' + accountsInserted + '\n';
        body += 'Accounts with owner updated: ' + accountsUpdated + ' (Note: Only new accounts are inserted in this process)\n';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{adminEmail});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Summary email sent to ' + adminEmail);
        } catch (EmailException e) {
            System.debug('Error sending summary email: ' + e.getMessage());
        }
    }
    
    
    
    
}