@RestResource(urlMapping='/userss/*')
global class UserAccountHandler {

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

        List<WrapperUser> userRequests;
        try {
            userRequests = (List<WrapperUser>) JSON.deserialize(requestBody, List<WrapperUser>.class);
        } catch (Exception e) {
            throw new CalloutException('Invalid JSON format: ' + e.getMessage());
        }

        if (userRequests.isEmpty()) return;

        Set<String> profileNames = new Set<String>();
        for (WrapperUser item : userRequests) {
            if (String.isNotBlank(item.profileName)) {
                profileNames.add(item.profileName);
            }
        }

        Map<String, Profile> profileNameMap = new Map<String, Profile>();
        Map<Id, Profile> profileIdMap = new Map<Id, Profile>();
        for (Profile p : [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name IN :profileNames]) {
            profileNameMap.put(p.Name, p);
            profileIdMap.put(p.Id, p);
        }

        Map<Id, UserLicense> licenseMap = new Map<Id, UserLicense>(
            [SELECT Id, TotalLicenses, UsedLicenses FROM UserLicense]
        );

        List<User> usersToCreate = new List<User>();
        Map<Id, Integer> newUserCountByProfile = new Map<Id, Integer>();
        Map<String, WrapperUser> usernameToWrapperUserMap = new Map<String, WrapperUser>();

        for (WrapperUser r : userRequests) {
            if (String.isBlank(r.username) || !profileNameMap.containsKey(r.profileName)) continue;

            Profile p = profileNameMap.get(r.profileName);
            String alias = (r.firstName != null ? r.firstName.substring(0, Math.min(3, r.firstName.length())) : '') +
                           (r.lastName != null ? r.lastName.substring(0, Math.min(3, r.lastName.length())) : '');

            User newUser = new User(
                FirstName = r.firstName,
                LastName = r.lastName,
                Email = r.email,
                Username = r.username,
                ProfileId = p.Id,
                IsActive = true,
                Alias = alias,
                CommunityNickname = r.username,
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles',
                LanguageLocaleKey = 'en_US'
            );

            usersToCreate.add(newUser);
            usernameToWrapperUserMap.put(r.username, r);

            Integer count = newUserCountByProfile.get(p.Id);
            newUserCountByProfile.put(p.Id, (count == null ? 1 : count + 1));
        }

        // Bulk user deactivation logic
        List<User> usersToDeactivate = new List<User>();
        Set<Id> profileIds = newUserCountByProfile.keySet();

        Map<Id, List<User>> activeUsersByProfile = new Map<Id, List<User>>();
        List<User> activeUsers = [SELECT Id, ProfileId FROM User 
                                  WHERE IsActive = true AND ProfileId IN :profileIds AND UserRoleId != null 
                                  ORDER BY CreatedDate ASC];

        for (User u : activeUsers) {
            if (!activeUsersByProfile.containsKey(u.ProfileId)) {
                activeUsersByProfile.put(u.ProfileId, new List<User>());
            }
            activeUsersByProfile.get(u.ProfileId).add(u);
        }

        for (Id profileId : profileIds) {
            Profile p = profileIdMap.get(profileId);
            if (p == null || p.UserLicenseId == null || !licenseMap.containsKey(p.UserLicenseId)) continue;

            UserLicense license = licenseMap.get(p.UserLicenseId);
            Integer available = license.TotalLicenses - license.UsedLicenses;
            Integer requested = newUserCountByProfile.get(profileId);

            if (requested > available) {
                Integer toDeactivate = requested - available;
                List<User> candidates = activeUsersByProfile.get(profileId);
                if (candidates != null) {
                    for (Integer i = 0; i < Math.min(toDeactivate, candidates.size()); i++) {
                        candidates[i].IsActive = false;
                        usersToDeactivate.add(candidates[i]);
                    }
                }
            }
        }

        if (!usersToDeactivate.isEmpty()) {
            try {
                update usersToDeactivate;
            } catch (DMLException e) {
                System.debug('Error deactivating users: ' + e.getMessage());
            }
        }

        List<User> insertedUsers = new List<User>();
        if (!usersToCreate.isEmpty()) {
            try {
                insert usersToCreate;
                insertedUsers = usersToCreate;
            } catch (DMLException e) {
                System.debug('Error inserting users: ' + e.getMessage());
            }
        }

        // Prepare account provisioning
        Map<Id, String> userIdToAccountNameMap = new Map<Id, String>();
        for (User u : insertedUsers) {
            WrapperUser wr = usernameToWrapperUserMap.get(u.Username);
            if (wr != null && String.isNotBlank(wr.accountName)) {
                userIdToAccountNameMap.put(u.Id, wr.accountName);
            }
        }

        if (!userIdToAccountNameMap.isEmpty()) {
            processAccountAndUserRelationAsync(JSON.serialize(userIdToAccountNameMap), insertedUsers.size(), usersToDeactivate.size());
        } else {
            sendSummaryEmail(insertedUsers.size(), usersToDeactivate.size(), 0);
        }
    }

    @future
    private static void processAccountAndUserRelationAsync(String userIdToAccountNameMapJson, Integer usersInserted, Integer usersDeactivated) {
        Map<Id, String> userIdToAccountNameMap;
        try {
            userIdToAccountNameMap = (Map<Id, String>) JSON.deserialize(userIdToAccountNameMapJson, Map<Id, String>.class);
        } catch (Exception e) {
            System.debug('Error deserializing future payload: ' + e.getMessage());
            sendSummaryEmail(usersInserted, usersDeactivated, 0);
            return;
        }

        if (userIdToAccountNameMap.isEmpty()) {
            sendSummaryEmail(usersInserted, usersDeactivated, 0);
            return;
        }

        Set<String> uniqueAccountNames = new Set<String>(userIdToAccountNameMap.values());
        Map<String, Id> accountNameToOwnerId = new Map<String, Id>();

        for (Id userId : userIdToAccountNameMap.keySet()) {
            String accName = userIdToAccountNameMap.get(userId);
            if (String.isNotBlank(accName) && !accountNameToOwnerId.containsKey(accName)) {
                accountNameToOwnerId.put(accName, userId);
            }
        }

        Set<String> existingAccountNames = new Set<String>();
        for (Account acc : [SELECT Name FROM Account WHERE Name IN :uniqueAccountNames]) {
            existingAccountNames.add(acc.Name);
        }

        List<Account> accountsToInsert = new List<Account>();
        for (String accName : uniqueAccountNames) {
            if (!existingAccountNames.contains(accName)) {
                Account newAcc = new Account(Name = accName, OwnerId = accountNameToOwnerId.get(accName));
                accountsToInsert.add(newAcc);
            }
        }

        Integer accountsSuccessfullyInserted = 0;
        if (!accountsToInsert.isEmpty()) {
            try {
                insert accountsToInsert;
                accountsSuccessfullyInserted = accountsToInsert.size();
            } catch (DMLException e) {
                System.debug('Error inserting accounts: ' + e.getMessage());
            }
        }

        sendSummaryEmail(usersInserted, usersDeactivated, accountsSuccessfullyInserted);
    }

    private static void sendSummaryEmail(Integer usersInserted, Integer usersDeactivated, Integer accountsCreated) {
        String subject = 'User Provisioning Summary';
        String body = 'Provisioning completed:\n\n' +
                      '✅ Users Inserted: ' + usersInserted + '\n' +
                      '🛑 Users Deactivated: ' + usersDeactivated + '\n' +
                      '🏢 Accounts Created: ' + accountsCreated + '\n\n' +
                      'Timestamp: ' + String.valueOf(System.now());

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { 'admin@example.com' }); // Replace with actual recipient
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug('Error sending summary email: ' + e.getMessage());
        }
    }
}