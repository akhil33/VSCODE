global class SubscriptionUpdate_BatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select Id, Sripe_Subscription_Id__c, Amount__c,Status__c, Account__r.Stripe_Customer_Id__c,Account__c,Card__c from Subscription__c where Status__c != \'Canceled\' and Status__c != \'Unpaid\'');
    } 
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        stripecall callStripe = new stripecall();
        list<Subscription__c> newSubList = new list<Subscription__c>();
        list<Transaction_History__c> lst_trans = new list<Transaction_History__c>();
        for(Subscription__c sub : (list<Subscription__c>)scope){
            if(String.isNotBlank(sub.Account__r.Stripe_Customer_Id__c) && String.isNotBlank(sub.Sripe_Subscription_Id__c)){
                String EndPoint = 'https://api.stripe.com/v1/customers/'+sub.Account__r.Stripe_Customer_Id__c+'/subscriptions/'+sub.Sripe_Subscription_Id__c;
                String Method = 'GET';
                String JSONdata = '';
                
                httpResponse res_sub = callStripe.call(EndPoint,Method,JSONdata);
                
                if(res_sub.getStatusCode() == 200){
                    map<String,Object> responseMap_sub = (map<String,Object>)JSON.deserializeUntyped(res_sub.getBody());
                    String status = (String)responseMap_sub.get('status');
                    if(sub.Status__c != status){
                        sub.Status__c = status;   
                        newSubList.add(sub);
                    }
                }
                
                String EndPoint_charg = 'https://api.stripe.com/v1/charges?customer='+sub.Account__r.Stripe_Customer_Id__c;
                String Method_charg = 'GET';
                String JSONdata_charg = '';
                httpResponse res_charg = callStripe.call(EndPoint_charg ,Method_charg,JSONdata_charg);
                
                if(res_charg.getStatusCode() == 200){
                    map<String,Object> responseMap_charglst = (map<String,Object>)JSON.deserializeUntyped(res_charg.getBody());
                    
                    for(Object obj : (list<Object>)responseMap_charglst.get('data')){
                        Transaction_History__c trans = new Transaction_History__c();
                        
                        map<String,Object> responseMap_charg = (map<String,Object>)obj;
                    
                        Integer amount_tr = (Integer)responseMap_charg.get('amount');
                        String des_tr = (String)responseMap_charg.get('description');
                        String flrCode = (String)responseMap_charg.get('failure_code');
                        String flrmsg = (String)responseMap_charg.get('failure_message');
                        boolean paid = (boolean)responseMap_charg.get('paid');
                        String email = (String)responseMap_charg.get('receipt_email');
                        boolean refunded = (boolean)responseMap_charg.get('refunded');
                        String currency1 = (String)responseMap_charg.get('currency');
                        String charge_Id = (String)responseMap_charg.get('id');
                        Integer tr_date = (Integer)responseMap_charg.get('created');
                    
                        trans.Account__c = sub.Account__c;
                        trans.Card__c = sub.Card__c;
                        trans.Subscription__c = sub.Id;
                        
                        trans.Amount__c = amount_tr/100;
                        trans.Description__c = des_tr;
                        trans.Failure_Code__c = flrCode;
                        trans.failure_message__c = flrmsg;
                        trans.Paid__c = paid;
                        trans.Receipt_Email__c = email;
                        trans.Refunded__c = refunded;
                        trans.Stripe_Charge_Id__c = charge_Id;
                        trans.Subscription__c = sub.Id;
                        trans.Currency__c = currency1;
                        if(tr_date != null && tr_date >0){
                            trans.Transaction_Date__c = Datetime.newInstance(tr_date);
                        }
                        lst_trans.add(trans);
                    }
                }    
                
            }
        }
        upsert lst_trans Stripe_Charge_Id__c;
        list<donation__c> lst_don = new list<Donation__c>();
        for(Transaction_History__c trans : lst_trans ){
            Donation__c don = new Donation__c();
            
            don.Account__c = trans.Account__c;
            don.Card__c = trans.Card__c;
            don.Subscription__c = trans.Subscription__c;
            don.Transaction__c = trans.Id;
            don.Stripe_Charge_Id__c = trans.Stripe_Charge_Id__c;
            lst_don.add(don);
        }
        upsert lst_don Stripe_Charge_Id__c;
        update newSubList;
    }
    global void finish(Database.BatchableContext BC){
    }
}