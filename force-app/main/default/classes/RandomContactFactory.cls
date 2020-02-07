public class RandomContactFactory {
    public static List<Contact> generateRandomContacts(integer NumOfCon, String LN ){
  		List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i< NumOfCon; i++){
            Contact con = new Contact (FirstName = 'Test '+i, LastName = LN);
            contacts.add(con);
        }
        return contacts;
    }
}