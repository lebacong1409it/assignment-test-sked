public with sharing class SearchRecordController {
    public String searchKey {get;set;}
    public List<ResultWrapper> searchResults {get; set;}
    public String incrementId {get;set;}

    public SearchRecordController() {}

    /**
     * Search Accounts and Contacts by Name
     */
    public void searchByName(){
        this.searchResults = new List<ResultWrapper>();

        if (searchKey.length() < 2) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Search key must be at least two characters or more'));
            return;
        }

        List<List<SObject>> searchList = [
            FIND :searchKey IN NAME FIELDS 
            RETURNING Account(Id, Name, Counter__c), Contact(Id, Name, Counter__c)
        ];

        Account[] searchAccounts = (Account[]) searchList[0];
        Contact[] searchContacts = (Contact[]) searchList[1];

        
        for (Account account : searchAccounts) {
            this.searchResults.add(new ResultWrapper(account, SObjectType.Account.getLabel()));
        }

        for (Contact contact : searchContacts) {
            this.searchResults.add(new ResultWrapper(contact, SObjectType.Contact.getLabel()));
        }
    }

     /**
     * Increment counter record
     */
    @RemoteAction
    public static Decimal incrementCounterRecord(Id recordId) {
        Decimal result = 0;

        if(recordId == null) {
            return result;
        }

        String sObjName = recordId.getSObjectType().getDescribe().getName();
        
        if (sObjName == SObjectType.Account.getName()) {
            Account account = [Select Id, Counter__c from Account where Id = :recordId];
            Decimal counter = account.Counter__c == null ? 0 : account.Counter__c;
            account.Counter__c = counter + 1;
            
            UPDATE account;
            result = account.Counter__c;
        }

        if (sObjName == SObjectType.Contact.getName()) {
            Contact contact = [Select Id, Counter__c from Contact where Id = :recordId];
            Decimal counter = contact.Counter__c == null ? 0 : contact.Counter__c;
            contact.Counter__c = counter + 1;

            UPDATE contact;
            result = contact.Counter__c;
        }

        return result;
    }

    public class ResultWrapper {
        public String id {get; set;}
        public String name {get; set;}
        public String sobjectName {get; set;}
        public String link {get; set;}
        public Decimal counter {get; set;}
 
        public ResultWrapper(SObject record, String sobjectName) {
            this.id = (String) record.get('Id');
            this.name = (String) record.get('Name');
            this.sobjectName = sobjectName;
            this.link = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) record.get('Id');
            Decimal counter = (Decimal) record.get('Counter__c');
            this.counter = counter != null ? counter : 0;
        }
    }
}
