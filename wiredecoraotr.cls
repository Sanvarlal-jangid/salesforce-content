public class wiredecoraotr {
    @AuraEnabled(Cacheable=true)
    public static string showMessage(){
        system.debug('hi we are learning wire decorator');
        return 'hi coming from apex class';
    }
}