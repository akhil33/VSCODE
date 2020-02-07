public class stripecall{
    public httpResponse call(String endPoint,String MethodName, String JSONdata){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndPoint(endPoint);
        
        String API_KEY = StripeAccount__c.getValues('reddytec88@gmail.com').Test_Secret_key__c;
        Blob headerValue = Blob.valueOf(API_KEY + ':');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization',authorizationHeader);
        req.setMethod(MethodName.toUpperCase());
        if(MethodName.toUpperCase() == 'POST'){
            req.setBody(JSONdata);
            system.debug('body=='+req.getBody());
        }
        HttpResponse res = h.send(req);
        system.debug(res.getStatusCode() +' '+res.getBody());
        return res;
    }    
}