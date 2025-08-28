public class WebhookNotifier {
   @future(callout=true)
    public static void sendContactChangeNotification(Id accountId, Integer contactCount, String changeType) {

        String endpoint = 'https://webhook.site/9006a940-8240-4794-a638-c854c207a1eb';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

       
        Map<String, Object> payload = new Map<String, Object>{
            'accountId' => String.valueOf(accountId),
            'contactCount' => contactCount,
            'changeType' => changeType,
            'timestamp' => String.valueOf(System.now()),
            'message' => 'Contact ' + changeType + ' event for Account ' + accountId
        };

        String jsonBody = JSON.serialize(payload);
        req.setBody(jsonBody);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Webhook response: ' + res.getBody());
            System.debug('Webhook request body: ' + jsonBody); 
        } catch (Exception e) {
            System.debug('Callout failed: ' + e.getMessage());
        }
    }
}