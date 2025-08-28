/**
 * @author Sanvarlal Jangid
 * @description Sends a Stripe payment link for an Opportunity via email based on its products.
 * @param opp The Id of the Opportunity to generate a payment link for.
 */
public class StripeService {
    @future(callout=true)
    public static void generatePaymentLink(Id opp){
        
        List<OpportunityLineItem> oliList = [SELECT Id, Name, Quantity, UnitPrice FROM OpportunityLineItem 
                                             WHERE OpportunityId = :opp];
        Opportunity op = [SELECT Id, Name, Email__c FROM Opportunity WHERE Id = :opp];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer sk_test_51RaMyIQtnBnE6xdFlxMB6eKdWX5IlBlBVZIvrKqET5gsay2dFQoFCmKD8XQ9GJQDm0arBLC3g275G0oaM4FFwFoK00G8JeVT7v');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String requestBody = 'payment_method_types[]=card'; 
        requestBody += '&mode=payment';
        requestBody += '&success_url=' + EncodingUtil.urlEncode('https://example.com/success', 'UTF-8');
        requestBody += '&cancel_url=' + EncodingUtil.urlEncode('https://example.com/cancel', 'UTF-8');
    
        Integer i = 0;
        for (OpportunityLineItem oli : oliList) {
            oli.UnitPrice = oli.UnitPrice * 100;
            requestBody += '&line_items[' + i + '][price_data][currency]=inr'; 
            requestBody += '&line_items[' + i + '][price_data][product_data][name]=' + EncodingUtil.urlEncode((String)oli.Name, 'UTF-8');
            requestBody += '&line_items[' + i + '][price_data][unit_amount]=' + String.valueOf(oli.UnitPrice.intValue());
            requestBody += '&line_items[' + i + '][quantity]=' + String.valueOf(oli.Quantity.intValue());
            i++;
        }

        req.setBody(requestBody);
        HttpResponse res = new HttpResponse();
        Http obj = new Http();
        res = obj.send(req);
        System.debug(res);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug(result);
            String paymentUrl = (String) result.get('url');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { op.Email__c });
            mail.setSubject('Your Payment Link for Order: ' + op.Name);
            mail.setPlainTextBody('Thank you for your order! Please complete your payment here: ' + paymentUrl);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } else {
            System.debug('Error creating Checkout Session: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }
}