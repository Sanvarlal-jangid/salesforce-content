public class ApexBasicsAssignment {
     
    public static Boolean isPalindrome(String str){
        if(str==null || String.isEmpty(str)){
            return false;
        }
        Integer length=str.length()-1;
        Integer index=0;
        while(index<length){
            if(str.charAt(index)!=str.charAt(length)){
                return false;
            }
            length--;
            index++;
            
        }
        return true;
    }
    /*Boolean result=ApexBasicsAssignment.isPalindrome('abcba');
      System.debug( result);
     */
    
    public static Integer sumOfDigits(Integer num){
        if(num==null){
            return 0;
        }
        String str=String.valueOf(num);
        List<String> listStr = str.split('');
        integer sum = 0;
        for(String s : listStr){
            Integer digit = Integer.valueOf(s);
            sum += digit;
        }
        return sum;
        
    }
    
    public static List<Integer> reverseList(List<Integer> inputList){
        if(inputList == null || inputList.isEmpty()){
            return new List<Integer>();
        }
        List<Integer>reverselist=new List<Integer>();
        for(Integer i=inputList.size()-1;i>=0;i--){
            reverselist.add(inputList[i]);
        }
        return reverselist;
    }
    /*
 List<Integer> numbers = new List<Integer>{1, 2, 3, 4};
 List<Integer> reversedNumbers = ApexBasicsAssignment.reverseList(numbers);
System.debug(reversedNumbers);
*/
    public static Map<Integer, List<Integer>> map2DList(List<List<Integer>> inputList){
        Map<Integer,List<Integer>>mp=new Map<Integer,List<Integer>>();
        for(Integer i=0;i<inputList.size();i++){
            Set<Integer>st=new Set<Integer>(inputList.get(i));
            List<Integer>lst=new List<Integer>(st);
            mp.put(i,lst);
        }
        return mp;
    }
    /*
     * List<List<Integer>>lst=new List<List<Integer>>();
lst.add(new List<Integer>{11,22});
lst.add(new List<Integer>{111, 222, 222, 200});
Map<Integer,List<Integer>>mpp=ApexBasicsAssignment.map2DList(lst);
system.debug(mpp);
*/
    public static List<List<String>> removeDuplicatesAndSort(List<List<String>> inputList){
        List<List<String>>result=new List<List<String>>();
        for(List<String> innerlist :inputList){
               List<string>sorted=new List<String>();
                 for(String str: innerlist){
                 Set<string>unique=new Set<String>(str.split(';'));
                 List<String>sortlst=new List<String>(unique);
                 sortlst.sort();
                 String joined=String.join(sortlst,';');
                 sorted.add(joined);
                
            }
            result.add(sorted);
        }
        return result;
    }
    
  public static List<Integer> rotateClockwise(List<Integer> inputList, Integer positions) {
    Integer n = inputList.size();
         positions =  positions - (positions / n) * n;
    List<Integer> result = new List<Integer>();

    for (Integer i = n - positions; i < n; i++) {
        result.add(inputList[i]);
    }
    
    for (Integer i = 0; i < n - positions; i++) {
        result.add(inputList[i]);
    }

    return result;
}

public static List<Integer> rotateAntiClockwise(List<Integer> inputList, Integer positions) {
    Integer n = inputList.size();
    positions = positions - (positions / n) * n; 
    List<Integer> result = new List<Integer>();

    for (Integer i = positions; i < n; i++) {
        result.add(inputList[i]);
    }

    for (Integer i = 0; i < positions; i++) {
        result.add(inputList[i]);
    }

    return result;
}

    public static List<Integer> findLeaders(List<Integer> inputList) {
    List<Integer> leaders = new List<Integer>();
    Integer maxFromRight = 0;

    for (Integer i = inputList.size() - 1; i >= 0; i--) {
        if (inputList[i] > maxFromRight) {
            leaders.add(inputList[i]);
            maxFromRight = inputList[i];
        }
    }

    return leaders;
}

}