trigger ContactTrigger on Contact (after update, after delete) {
    if(Trigger.isAfter) {
        // Find account which need count total contact
        Set<Id> accountIds = new Set<Id>();

        // When contact update
        if(Trigger.isUpdate) {
            for(Contact newContact : Trigger.New) {
                Contact oldContact = Trigger.oldMap.get(newContact.Id);
                if(newContact.AccountId != null && oldContact.IsActive__c != newContact.IsActive__c) {
                    accountIds.add(newContact.AccountId);
                }
            }
        }

        //when contact delete
        if(Trigger.isDelete) {
            for(Contact oldContact : Trigger.old) {
                if(oldContact.AccountId != null && oldContact.IsActive__c) {
                    accountIds.add(oldContact.AccountId);
                }
            }
        }

        // Update account
        if(!accountIds.isEmpty()) {
            List<Account> listUpdateAccount = [
                SELECT Id, Total_Contact__c, (SELECT Id FROM Account.Contacts WHERE IsActive__c = TRUE) 
                FROM Account WHERE Id IN :accountIds
            ];

            if (!listUpdateAccount.isEmpty()) {
                for(Account account : listUpdateAccount) {
                    account.Total_Contact__c = account.Contacts.size();
                }
                update listUpdateAccount;
            }
        }
    }
}