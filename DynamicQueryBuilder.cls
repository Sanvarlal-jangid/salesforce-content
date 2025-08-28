public class DynamicQueryBuilder {
    public static void runQuery() {
        List<String> fields = getFields(); 
        String conditionValue = getConditionValue();
         
        system.debug('before the condtion value escape'+conditionValue);
        String safeValue = String.escapeSingleQuotes(conditionValue);
          system.debug('After the condtion value escape'+safeValue);

        String condition = 'Industry = \'' + safeValue + '\'';

        String query = 'SELECT ' + String.join(fields, ', ') +
                       ' FROM Account WHERE ' + condition;
             system.debug('query print'+query);
        List<Account> accounts = Database.query(query);
        system.debug('print accounts'+accounts);

        for (Account acc : accounts) {
            System.debug('Account Name: ' + acc.Name + ', Industry: ' + acc.Industry);
        }
    }

    public static List<String> getFields() {
        return new List<String>{'Id', 'Name', 'Industry'};
    }

    public static String getConditionValue() {
        return 'Technology';
    }
}
/*
public class DynamicQueryBuilder {
    public static void runQuery() {
        // Get fields and condition value from methods
        List<String> fields = getFields(); // e.g., ['Id', 'Name', 'Industry']
        String conditionValue = getConditionValue(); // e.g., 'Technology'

        // Build full condition string manually
        String condition = 'Industry = \'' + conditionValue + '\'';

        // Build query string
        String query = 'SELECT ' + String.join(fields, ', ') +
                       ' FROM Account WHERE ' + condition;

        // Execute query
        List<Account> accounts = Database.query(query);

        // Debug output
        for (Account acc : accounts) {
            System.debug('Account Name: ' + acc.Name + ', Industry: ' + acc.Industry);
        }
    }

    public static List<String> getFields() {
        return new List<String>{'Id', 'Name', 'Industry'};
    }

    public static String getConditionValue() {
        return 'Technology'; // Make sure this value doesn't contain unescaped single quotes
    }
}
*/