global class schedulerToSubscriptionBatch_Class implements schedulable{
    global void execute(SchedulableContext sc){
        SubscriptionUpdate_BatchClass subbatch = new SubscriptionUpdate_BatchClass();
        ID batchprocessid = Database.executeBatch(subbatch,20); 
    }
}