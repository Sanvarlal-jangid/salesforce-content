public class BankOperations {
      public static void printDetails() {
        BankUtilities obj = new BankUtilities(10000, 5.0);
        System.debug('Account Balance: ' + obj.getAccountBalance());
        System.debug('Global Interest Rate: ' +obj.getGlobalInterestRate());
    }
}