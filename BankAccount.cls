Global class BankAccount {
    Global String accountHolderName;
    Protected String accountType;
    private decimal startingBalance;
    
    public BankAccount(String accountHolderName,String accountType,Decimal startingBalance){
        This.accountHolderName=accountHolderName;
        This.accountType=accountType;
        This.startingBalance=startingBalance;
    }
        
        public void getStartingBalance(){
            system.debug(startingBalance);
        }
        
    }
/*
 anonymous window code
 BankAccount obj = new BankAccount('John Doe', 'Savings', 5000);
obj.getStartingBalance();
*/