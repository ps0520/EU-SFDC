public with sharing class TPS_ContactController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [
            SELECT Id, FirstName, LastName, Title, Phone, Email
            FROM Contact Where Email != null            
            LIMIT 20
        ];
    }
}