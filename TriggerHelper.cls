public class TriggerHelper {
    
    public static void  AccounttriggerAfterupdateinsert(List<Account>acclist){
      
    Set<Id> accountIds = new Set<Id>();
    
    for (Account acc : acclist) {
        accountIds.add(acc.Id);
    }

    Map<Id, Opportunity> existingOpportunities = new Map<Id, Opportunity>();
    for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds]) {
        existingOpportunities.put(opp.AccountId, opp);
    }

    List<Opportunity> newOpportunities = new List<Opportunity>();
    
    for (Account acc : acclist) {
        if (!existingOpportunities.containsKey(acc.Id)) {
            newOpportunities.add(new Opportunity(
                Name = 'First Opportunity - ' + acc.Name,
                StageName = 'Negotiation/Review',
                CloseDate = Date.today().addMonths(1),
                AccountId = acc.Id
            ));
        }
    }

    if (!newOpportunities.isEmpty()) {
        insert newOpportunities;
    }
    }

    public static void preventaccountdeletion(List<Account>deletelist){
        Set<id>acids=new Set<id>();
        for(account acc:deletelist){
            acids.add(acc.Id);
        } 
        List<opportunity>accountopp=[select Id,Accountid from opportunity where AccountId in:acids AND StageName='Prospecting'];
        map<Id,opportunity>accwithopp=new Map<Id,opportunity>();
        for(opportunity opp:accountopp){
            accwithopp.put(opp.Accountid,opp);
        }
        for(Account acc:deletelist){
            if(accwithopp.containskey(acc.Id)){
                acc.adderror('cannot delete this account it has open opportunity');
            }
        }
    }
    
   public static void convertlead(List<Lead>leadlist){
       Set<Id>leadstoconvert=new Set<Id>();
       
       for(Lead le: leadlist){
           if(le.LeadSource == 'Phone Inquiry' && !le.IsConverted){
               leadstoconvert.add(le.Id);
           }
       }
       List<Database.LeadConvert>leadconversions=new List<Database.LeadConvert>();
       for(ID lid : leadstoconvert){
           Database.LeadConvert lc = new Database.LeadConvert();
           lc.setLeadId(lid);
           lc.setConvertedStatus('Closed - Converted');
        
           Leadconversions.add(lc);
       }
       if(!leadconversions.isEmpty()){
           Database.LeadConvertResult[] result = Database.ConvertLead(Leadconversions);
       }
   }
    public static void updatebank(List<Bank_Account__c>Bclist){
        map<Id,Integer>bankwithaccount=new Map<Id,Integer>();
        for(AggregateResult re:[select Branch__r.Bank__c,count(Id)totalaccount from Bank_Account__c
                                                                 group by Branch__r.Bank__c]){
                system.debug(re);
                bankwithaccount.put((Id)re.get('Bank__c'),(Integer)re.get('totalaccount'));                    
            
        }
        List<Bank__c>banklist=[select id ,TotalBankAccounts__c from Bank__c where id in :bankwithaccount.keySet()];
        system.debug('banklist'+banklist);
        List<Bank__c>updatebank=new List<Bank__c>();
        for(Bank__c b:banklist){
            b.TotalBankAccounts__c=bankwithaccount.get(b.Id);
            updatebank.add(b);
        }
        if(!updatebank.isEmpty()){
            update updatebank;
        }        
        
    }
    
    public static void stopdeleteaccount(List<Bank_Account__c>accountlist){
         Set<Id> bankAccountIds = new Set<Id>();

    for (Bank_Account__c ba : accountlist) {
        bankAccountIds.add(ba.Id);
    }

    Map<Id, Integer> bankAccountWithTransactionCount = new Map<Id, Integer>();

    for (AggregateResult ar : [ SELECT Bank_Account__c bankAccId, COUNT(Id) txnCount FROM Transaction__c
                                  WHERE Bank_Account__c IN :bankAccountIds GROUP BY Bank_Account__c]) {
        bankAccountWithTransactionCount.put((Id)ar.get('bankAccId'), (Integer)ar.get('txnCount'));
    }

    for (Bank_Account__c ba : accountlist) {
        if (bankAccountWithTransactionCount.containsKey(ba.Id)) {
            ba.addError('Cannot delete this Bank Account because it has related Transaction records.');
        }
    }
    }
    
    public static void updatebankaccount(List<Branch__c>branches,Map<Id,Branch__c>Bmap){
         Set<Id> deactivatedBranchIds = new Set<Id>();

   
    for (Branch__c br : branches) {
        Branch__c oldBr = Bmap.get(br.Id);
        if (oldBr.IsActive__c == 'Active' && br.IsActive__c == 'Inactive') {
            deactivatedBranchIds.add(br.Id);
        }
    }

    

    List<Bank_Account__c> relatedAccounts = [SELECT Id, Status__c FROM Bank_Account__c
                                             WHERE Branch__c IN :deactivatedBranchIds];

    for (Bank_Account__c acc : relatedAccounts) {
        acc.Status__c = 'Inactive';
    }

    if (!relatedAccounts.isEmpty()) {
        update relatedAccounts;
    }
    }
    
    
    public static void checkownertotalcase(List<Case>caslist){
        Set<Id>userids=new Set<Id>();
        for(case c: caslist){
            userids.add(c.ownerId);
        }
        
        Map<Id,Integer>opencasecount=new Map<Id,Integer>();
        List<AggregateResult>results=[ SELECT OwnerId, COUNT(Id) totalCases FROM Case 
                                        WHERE Status != 'Closed' AND OwnerId IN :userIds   GROUP BY OwnerId];
         
        
        for(AggregateResult r: results){
            opencasecount.put((Id)r.get('OwnerId'),(Integer)r.get('totalcases'));
        }
        for(case s:caslist){
            Integer currentcount;
            if(opencasecount.containskey(s.OwnerId)){
                currentcount=opencasecount.get(s.OwnerId);
            }else{ currentcount = 0; }
            
            if(currentcount>=2){
                s.addError('you cannot create case you already have more than 2 open cases');
            }
        }
    }
    
    public static void duplicateopportunity(List<opportunity>opplist){
        Set<string>newopp=new Set<string>();
        set<string>oldopp=new Set<String>();
        for(opportunity opp: opplist){
            if(opp.Name!=null){
                newopp.add(opp.Name);
            }            
        }
        
        List<opportunity>oldlist=[select name , AccountId from opportunity where name in :newopp];
        for(opportunity opp:oldlist){
            if(opp.name!=null && opp.AccountId!=null){
                string key=opp.name+opp.AccountId;
                oldopp.add(key);
            }
            
        }
        for(opportunity opp:opplist){
            string key = opp.name+opp.AccountId;
            if(oldopp.contains(key)){
                opp.name=opp.name+'-duplicate opportunity';
            }
        }
        
        
        
        
   }
    
public static void avgOfTransaction(List<Transaction__c> trlist) {
   
    Set<Id> txnIds = new Set<Id>();
    for (Transaction__c txn : trlist) {
        txnIds.add(txn.Id);
    }

    
    List<Transaction__c> transactionsWithBanks = [
        SELECT Id, Bank_Account__r.Branch__r.Bank__c
        FROM Transaction__c
        WHERE Id IN :txnIds
        ALL ROWS  
    ];

    
    Set<Id> affectedBankIds = new Set<Id>();
    for (Transaction__c txn : transactionsWithBanks) {
        Id bankId = txn.Bank_Account__r?.Branch__r?.Bank__c;
        if (bankId != null) {
            affectedBankIds.add(bankId);
        }
    }

    if (affectedBankIds.isEmpty()) {
        return; 
    }

    Map<Id, Decimal> avgMap = new Map<Id, Decimal>();
    for (AggregateResult ar : [
        SELECT Bank_Account__r.Branch__r.Bank__c bankId, AVG(Deposit_Amount__c) avgDeposit
        FROM Transaction__c
        WHERE Bank_Account__r.Branch__r.Bank__c IN :affectedBankIds
              AND IsDeleted = FALSE
        GROUP BY Bank_Account__r.Branch__r.Bank__c
    ]) {
        avgMap.put((Id)ar.get('bankId'), (Decimal)ar.get('avgDeposit'));
    }

    List<Bank__c> banksToUpdate = new List<Bank__c>();
    for (Id bankId : affectedBankIds) {
        Bank__c b = new Bank__c(
            Id = bankId,
            Average_Transaction_Amount__c = avgMap.containsKey(bankId) ? avgMap.get(bankId) : null
        );
        banksToUpdate.add(b);
    }

    if (!banksToUpdate.isEmpty()) {
        Database.update(banksToUpdate, false);
    }
}

    
    public static void backupmergedaccount(List<Account>acclist){
          
            List<Account_Backup__c> backups = new List<Account_Backup__c>();

    for (Account acc :acclist) {
        if (acc.MasterRecordId != null) {
            Account_Backup__c backup = new Account_Backup__c();
            backup.Name = acc.Name;
            backup.Phone__c = acc.Phone;
            backups.add(backup);
        }
    }

    if (!backups.isEmpty()) {
        insert backups;
    }
    }
        
    public static void RestrictStageChange(List<opportunity>acclist,Map<Id,opportunity>oldmap){
        Set<Id>oppids=new Set<Id>();
        
        for(opportunity opp:acclist){
            opportunity oldop=oldmap.get(opp.id);
            if(opp.StageName !=oldop.StageName){
                oppids.add(opp.id);
        }
    }
        if(!oppids.isEmpty()){
            Set<Id>oppwithtask=new Set<Id>();
        List<task>tasklist=[select whatId from task where WhatId in :oppids];
            for(task t:tasklist){
                oppwithtask.add(t.WhatId);
                
            }
            
            for(opportunity opp:acclist){
                if(oppids.contains(opp.Id) &&  !oppwithtask.contains(opp.id)){
                    opp.StageName.adderror('we cannot update stage until we have the related task to it');
                }
            }
        }    
    
}
    
   public static void updateproductdescription( List<OpportunityLineItem>olilist){
    for (OpportunityLineItem oli : olilist) {
        
        if (oli.UnitPrice <= 1000) {
            oli.addError('Unit price must be greater than 1000');
        }
    }

    // Update Description based on PricebookEntryId
    Set<Id> pbids = new Set<Id>();
    for (OpportunityLineItem oli : olilist) {
        if (oli.PricebookEntryId != null) {
            pbids.add(oli.PricebookEntryId);
        }
    }

    if (!pbids.isEmpty()) {
        Map<Id, String> pbeToProdDesc = new Map<Id, String>();
        for (PricebookEntry pbe : [SELECT Id, Product2.Description FROM PricebookEntry WHERE Id IN :pbids]) {
            pbeToProdDesc.put(pbe.Id, pbe.Product2.Description);
        }

        for (OpportunityLineItem oli : olilist) {
            system.debug('update vale loop me');
            String descri = pbeToProdDesc.get(oli.PricebookEntryId);
            if (descri != null) {
                oli.Description = descri;
            }
        }
    }
}
    
    
    
    
    
}