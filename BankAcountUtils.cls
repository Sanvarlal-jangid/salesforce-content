public class BankAcountUtils {
    public string accountNumberFormatter(string accraw){
         String ans='';
        string  temp='';
       List<String> parts = new List<String>();
    while (accraw.length() > 0) {
        if (accraw.length() >= 4) {
            parts.add(accraw.substring(0, 4));
            accraw = accraw.substring(4); 
        } else {
            parts.add(accraw); 
            accraw = ''; 
        }
    }
    return String.join(parts, '-'); 
}
       public  Blob convertidtoblob(String transactionid) {
        return Blob.valueOf(transactionid);
    }
       public static void decodeBlob(Blob codedid) {
        String decoded = codedid.toString();
        System.debug(decoded);
    }
      public Integer validateAccountId(String accountId) {
        return accountId.length();
    }
    
}