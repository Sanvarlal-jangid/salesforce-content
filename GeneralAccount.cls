public virtual class GeneralAccount {
   String accountHolderName;
    String accountType;
    decimal currentBalance;
    
    public GeneralAccount(){
        
    }
      public GeneralAccount(String accountHolderName, String accountType, Decimal currentBalance) {
        this.accountHolderName = accountHolderName;
        this.accountType = accountType;
        this.currentBalance = currentBalance;
    }
    
       public virtual Integer getDailyLimit() {
        return 0;
          }        
    }