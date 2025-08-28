public class CustomerUtils{
    public static void mapCustomerToAccount() {
        Map<String, String> customerAccountMap = new Map<String, String>{
            'Alice' => 'ACC123',
            'Bob' => 'ACC456',
            'Charlie' => 'ACC789',
            'Diana' => 'ACC012',
            'Evan' => 'ACC345'
        };
       system.debug(customerAccountMap.get('Alice'));
        system.debug(customerAccountMap.keySet());
        system.debug(customerAccountMap.values());
}
}