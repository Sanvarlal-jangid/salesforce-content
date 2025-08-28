public class LoanUtils {
     String customername='jugnu';
     Double loanamount=500000;
     Date   loanstartdate=Date.today();
    Integer tenure=5;
    
    public static final double interestrate=0.075;
    
    public void calculateinterestamt(){
        Decimal intrestamt=loanamount * interestrate;
        System.debug(intrestamt.setscale(2));
    }
    
    public void enddateloan(){
        Date enddate=loanstartdate.addYears(tenure);
        system.debug(enddate);
    }
    public void calculateemi(){
        Integer totalmonth=tenure * 12;
        Decimal totalamount=loanamount+(loanamount * interestrate);
        Decimal emi = totalamount/totalmonth;
        system.debug(emi.setscale(2));
    } 
    
}