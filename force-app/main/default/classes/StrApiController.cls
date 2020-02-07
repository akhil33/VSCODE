public class StrApiController {
	 public String getTopic(){
		String result='';
        List<PushTopic> topics=[select id, Name from PushTopic where Name='InvoiceStatementUpdates'];
        if (0!=topics.size())
		{
			result='InvoiceStatementUpdates';
		}
		
		return result;
	}
    public void CreateTopic(){
        System.debug('### Creating the push topic');
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'InvoiceStatementUpdates';
        pushTopic.Query = 'SELECT Id, Name, Status__c, Description__c, CreatedBy, Owner FROM Invoice_Statement__c';
        pushTopic.ApiVersion = 35.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = true;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;
		System.debug('### Done creating the push topic - id = ' + pushTopic.Id);        
    }
}