public class BankUtilities {
    
    public static Decimal globalInterestRate;   
    public Decimal accountBalance;
                    public BankUtilities(Decimal accountBalance, Decimal accountInterestRate) {
                      this.accountBalance = accountBalance;
                      globalInterestRate = accountInterestRate;
                     }
                         
          public Decimal getAccountBalance() {
          return this.accountBalance;
    }
           public  Decimal getGlobalInterestRate() {
           return globalInterestRate;
    }
}