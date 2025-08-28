public class sendmessagetostudent {
    
    @future(callout=true)
    public static void mymethod(String name , String phone , String email){
        
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/AC29a16034f30eb62723eafacf15ce1845/Messages.json');
        req.setMethod('POST');
        
      //authentication  
       /* Blob b = Blob.valueof('AC29a16034f30eb62723eafacf15ce1845:53c5656934d1ec039f7e10cc158b5a21');
        String str = EncodingUtil.base64Encode(b);    */
        
        req.setHeader('Authorization','Basic QUMyOWExNjAzNGYzMGViNjI3MjNlYWZhY2YxNWNlMTg0NTo1M2M1NjU2OTM0ZDFlYzAzOWY3ZTEwY2MxNThiNWEyMQ==');
        
      // request parameter
        String message = 'hellow'+name+'sir';
        String Body = 'From='+EncodingUtil.urlEncode('+15074282081','UTF-8')+'&To='+EncodingUtil.urlEncode(phone,'UTF-8')+'&Body='+message;
        
        req.setBody(body);
        system.debug(Body);
        
        HttpResponse res = new HttpResponse();
        
        Http obj = new Http();
        
        res = obj.send(req);
        system.debug(res);
        system.debug(res.getbody());
        
     
  }
}