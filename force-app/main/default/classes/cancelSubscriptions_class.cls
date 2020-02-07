public class cancelSubscriptions_class {
    list<Subscription__c> subscriptions;
    String paramId;
    public list<Subscription__c>  getsubscriptions(){
        subscriptions = new list<Subscription__c>();
        paramId = Apexpages.currentpage().getParameters().get('paramid');
        if(String.isNotBlank(paramId)){
            Id paramId_temp = paramId;
            if(paramId_temp.getSObjectType() == Account.sObjectType){
                subscriptions = [select Id,Name,PlanId__c,Account__c,Account__r.Stripe_Customer_Id__c, Amount__c,Start_DateTime__c,Status__c,Sripe_Subscription_Id__c from Subscription__c where Account__c =:paramId_temp and Status__c != 'Canceled' ];
            }else if(paramId_temp.getSObjectType() == Subscription__c.sObjectType){
                subscriptions = [select Id,Name,PlanId__c,Account__c,Amount__c,Start_DateTime__c,Status__c,Account__r.Stripe_Customer_Id__c ,Sripe_Subscription_Id__c from Subscription__c  where Id=:paramId_temp];
                if(subscriptions[0].Status__c == 'Canceled'){
                    disableButton = true;
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.INFO,'Selected subscription is already canceled'));
                }
            }else{
                disableButton = true;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR,'Please return back to previous page. No Id provied'));
            }
            if(subscriptions.size() == 0 ){
                disableButton = true;
                Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.INFO,'No Subscription to cancel'));
            }
            
        }
        return subscriptions;
    }
    public boolean disableButton{get;set;}
    public cancelSubscriptions_class(){
        //subscriptions2 = new list<Subscription__c>();
    
    }
    public void executeCancel(){
        stripecall callStripe = new stripecall();
        for(Subscription__c sub : subscriptions){
            if(String.isNotBlank(sub.Account__r.Stripe_Customer_Id__c) && String.isNotBlank(sub.Sripe_Subscription_Id__c)){
                String EndPoint_subCancel = 'https://api.stripe.com/v1/customers/'+sub.Account__r.Stripe_Customer_Id__c+'/subscriptions/'+sub.Sripe_Subscription_Id__c;
                String Method_subCancel = 'DELETE';
                String JSONdata_subCancel = '';
                httpResponse res_subCancel = callStripe.call(EndPoint_subCancel ,Method_subCancel ,JSONdata_subCancel );
                if(res_subCancel.getStatusCode() == 200){
                    map<String,Object> responseMap_subCancel = (map<String,Object>)JSON.deserializeUntyped(res_subCancel.getBody());
                    String Status = (String)responseMap_subCancel.get('status');
                    sub.Status__c = Status;
                }
            }
        }
        try{
            update subscriptions;
        }Catch(Exception ex){
            apexpages.addMessages(ex);
        }
    }
    public pagereference return1(){
        return new pagereference('/'+paramId).setRedirect(true);
    }


}