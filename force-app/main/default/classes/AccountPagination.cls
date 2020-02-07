public class AccountPagination {
    private final Account acct;  
    public list<Contact> contactList {get;set;}
    // The constructor passes in the standard controller defined
    // in the markup below
    public AccountPagination(ApexPages.StandardController controller) {
        this.acct = (Account)controller.getRecord(); 
        contactList = getContacttPagination();
        system.debug('====>'+contactList);
    }    
    public List<Contact> getContacttPagination() {
        List<Account> tempAccList =  [SELECT Name, (select id, firstname, lastname from Contacts limit 20) FROM Account WHERE Id =: acct.Id ];
        List<Contact> ContactList = new List<Contact> ();
        for (Account acc: tempAccList){
            ContactList.add(acc.Contacts);
        }
        return ContactList;
    } 
}