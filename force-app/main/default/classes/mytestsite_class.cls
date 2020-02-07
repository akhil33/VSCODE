public class mytestsite_class {


    public String cardnumber {get;set;}
    public String cvv {get;set;}
    public String STRIPE_API_KEY {get;set;}
    public Decimal Amount{get;set;}
    public Account acc{get;set;}
    public Card__c card{get;set;}
    public String cardToken{get;set;}
    public String PlanId{get;set;}
    
    public mytestsite_class(){
        card = new Card__c();
        acc = new Account();

        //custom setting to store values of stripe account related
        STRIPE_API_KEY = StripeAccount__c.getValues('reddytec88@gmail.com').Test_Publishable_key__c;
        
        
    }
    public void createDonation(){
        //Create Customer
        Amount = Amount*100;
        String EndPoint_Cus = 'https://api.stripe.com/v1/customers';
        String Method_Cus = 'POST';
        String JSONdata_Cus = 'description=customer for '+acc.Email__c;//+';card='+cardToken+';plan='+planid+';email='+acc.email__c;
        
        stripecall callStripe = new stripecall();
        
        httpResponse res_Cus = callStripe.call(EndPoint_Cus ,Method_Cus,JSONdata_Cus);
        
        if(res_Cus.getStatusCode() == 200){
            map<String,Object> responseMap_Cus = (map<String,Object>)JSON.deserializeUntyped(res_Cus.getBody());
            String customerId = (String)responseMap_Cus.get('id');
            Acc.Stripe_Customer_Id__c = customerId;
            Acc.Name = card.Name_on_Card__c;
            
            String EndPoint_card = 'https://api.stripe.com/v1/customers/'+customerId+'/cards';
            String Method_card = 'POST';
            String JSONdata_card = 'card='+cardToken;
            
            httpResponse res_card = callStripe.call(EndPoint_card ,Method_card,JSONdata_card);
            
            if(res_card.getStatusCode() == 200){
                map<String,Object> responseMap_card = (map<String,Object>)JSON.deserializeUntyped(res_card.getBody());
                
                String card_Id = (String)responseMap_card.get('id');
                String funding = (String)responseMap_card.get('funding');
                String brand = (String)responseMap_card.get('brand');
                Integer EM = (Integer)responseMap_card.get('exp_month');
                Integer EY = (Integer)responseMap_card.get('exp_Year');
                String last4 = (String)responseMap_card.get('last4');
                String name = (String)responseMap_card.get('name');
                
                card.Address__c = acc.BillingStreet+'\n'+Acc.BillingCity+'\n'+Acc.BillingState+'\n'+Acc.BillingPostalCode+'\n'+Acc.BillingCountry;
                card.Card_Funding_Type__c = funding;
                card.Card_Type__c = brand;
                card.Expiry_Month__c = EM;
                card.Expiry_Year__c = EY;
                card.Last_4__c = last4;
                card.Stripe_Card_Id__c = card_Id;
                card.Name_on_Card__c = name;
                
                
                String EndPoint_sub = 'https://api.stripe.com/v1/customers/'+customerId+'/subscriptions';
                String Method_sub = 'POST';
                String JSONdata_sub = 'plan='+PlanId;//+';card='+cardToken;
                
                httpResponse res_sub = callStripe.call(EndPoint_sub ,Method_sub,JSONdata_sub);
                
                if(res_sub.getStatusCode() == 200){
                    Subscription__c sub = new Subscription__c();
                    
                    map<String,Object> responseMap_sub = (map<String,Object>)JSON.deserializeUntyped(res_sub.getBody());
                    
                    String sub_Id = (String)responseMap_sub.get('id');
                    String status = (String)responseMap_sub.get('status');
                    Integer start = (Integer)responseMap_sub.get('start');
                    
                    sub.Status__c = status;
                    sub.Amount__c = Amount/100;
                    sub.PlanId__c = PlanId;
                    sub.E_mail__c = acc.Email__c;
                    sub.Sripe_Subscription_Id__c = sub_Id;
                    
                    if(start != null && start > 0){
                        sub.Start_DateTime__c = DateTime.newInstance(start);
                    }
                    
                    
                    String EndPoint_charg = 'https://api.stripe.com/v1/charges?customer='+customerId;
                    String Method_charg = 'GET';
                    String JSONdata_charg = '';//'amount='+amount+';currency=cad;description=charge for '+acc.Email__c+';customer='+customerId+';receipt_email='+acc.Email__c;
                    httpResponse res_charg = callStripe.call(EndPoint_charg ,Method_charg,JSONdata_charg);
                    
                    insert acc;
                    card.Account__c = acc.Id;
                    insert card;
                    
                    sub.Account__c = acc.Id;
                    sub.Card__c = card.id;
                    insert sub;
                    
                    if(res_charg.getStatusCode() == 200){
                        list<Transaction_History__c> lst_trans = new list<Transaction_History__c>();
                        
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
                        
                            trans.Account__c = acc.Id;
                            trans.Card__c = card.Id;
                            trans.Subscription__c = sub.Id;
                            
                            trans.Amount__c = amount_tr/100;
                            trans.Card__c = card.Id;
                            trans.Description__c = des_tr;
                            trans.Failure_Code__c = flrCode;
                            trans.failure_message__c = flrmsg;
                            trans.Paid__c = paid;
                            trans.Receipt_Email__c = email;
                            trans.Refunded__c = refunded;
                            trans.Stripe_Charge_Id__c = charge_Id;
                            trans.Subscription__c = sub.Id;
                            trans.Currency__c = currency1 ;
                            if(tr_date != null && tr_date >0){
                                trans.Transaction_Date__c = Datetime.newInstance(tr_date);
                            }
                            lst_trans.add(trans);
                        }
                        list<donation__c> lst_don = new list<Donation__c>();
                        
                        upsert lst_trans Stripe_Charge_Id__c;
                        for(Transaction_History__c trans : lst_trans ){
                            Donation__c don = new Donation__c();
                            
                            don.Account__c = acc.Id;
                            don.Card__c = card.Id;
                            don.Subscription__c = sub.Id;
                            don.Transaction__c = trans.Id;
                            don.Stripe_Charge_Id__c = trans.Stripe_Charge_Id__c;
                            lst_don.add(don);
                        }
                        insert lst_don;
                        
                        Amount = null;
                        cardnumber = null;
                        cvv = null;
                        acc = new Account();
                        card = new Card__c();
                        cardToken = null;
                        PlanId  = null;
                        Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.CONFIRM,'Donation done! Thank you.'));
                    }else{
                        Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR,'Could not fetch charge for subscription. Stripe Response Code:'+res_charg.getStatusCode()+' Message: '+res_charg.getBody()));
                    }
                                        
                }else{
                    Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR,'Subscription could not be created. Stripe Response Code:'+res_sub.getStatusCode()+' Message: '+res_sub.getBody()));
                }
                
            }else{
                Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR,'Card could not be created. Stripe Response Code:'+res_card.getStatusCode()+' Message: '+res_card.getBody()));
            }
        
        }else{
            Apexpages.addMessage(new Apexpages.message(Apexpages.SEVERITY.ERROR,'Customer could not be created. Stripe Response Code:'+res_Cus.getStatusCode()+' Message: '+res_Cus.getBody()));
        }
        
    }

}