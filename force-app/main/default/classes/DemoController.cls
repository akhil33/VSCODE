public with sharing class DemoController {
    public Account[] getContacts() {
        return [
                select Id, Name
                from Account
                order by Name
                ];
    }
}