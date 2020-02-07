public class AccountJSON
{    
    public String JSONtext {get;set;}
    public Account VISacct {get;set;}
    public String AccountSelected {get;set;} 
    public AccountJSON()   { } 
    public void parseJson() {
        String sAccName = 'Burlington Textiles Corp of America';
        if (AccountSelected == null) {
            AccountSelected = sAccName ;
        }        
        String soql = 'SELECT Name,AccountNumber,site,AccountSource, AnnualRevenue, BillingAddress, Fax,Phone, Website, TickerSymbol, NumberofEmployees, Ownership, SIC FROM Account WHERE name = :AccountSelected LIMIT 1';
        Account acct = Database.Query(soql);
        VISacct = acct ;
        JSONtext = JSON.serialize(acct); }    
    public List<SelectOption> getAccountList() {
        List<SelectOption> AllAccountNames = new List<SelectOption>();
        string tempaccount;
        List<Account> Accounts = [SELECT  Name FROM Account]; 
        For (Account ar : Accounts ) {
            tempaccount= (string) ar.get('Name');
            AllAccountNames.add(new SelectOption(tempaccount,tempaccount));
        }
        return AllAccountNames ; }    
}