public class ContactSearch {
	public static List<Contact> searchForContacts(String name, String code){
		List<Contact> con = new List<Contact>();
        con = [SELECT Id,Name, FirstName, LastName FROM Contact WHERE LastName =:name AND MailingPostalCode=:code];
        return con;
    }
}