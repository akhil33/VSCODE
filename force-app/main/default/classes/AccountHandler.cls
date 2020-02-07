//Added comment1
public class AccountHandler {
	public static Account insertNewAccount (String name){
        //initailizing new account
        //Test comment
        //Test again
        Account acc = new Account ();
       	acc.Name = name;
        try{
        	insert acc;

           }
        catch (DmlException e){
            return null;
        }
        return acc;
    }
}