/**
 * Created by new on 08.06.2017.
 */

public with sharing class AccountContactReferenceHandler {

    public static void onAfterInsert(List<Reference__c> references) {
        List<ContactShare> contactSharesList = new List<ContactShare>();
        Map<Id, List<Id>> accountWithContacts = new Map<Id, List<Id>>();
        Map<Id, List<Id>> accountTerritoryIds = new Map<Id, List<Id>>();

        for (Reference__c reference : references) {
            if (accountWithContacts.get(reference.Account__c) == null) {
                accountWithContacts.put(reference.Account__c, new List<Id>{
                        reference.Contact__c
                });
            } else {
                accountWithContacts.get(reference.Account__c).add(reference.Contact__c);
            }
        }

        for (Account acc : AccountContactReferenceHelper.getAccountsById(accountWithContacts.keySet())) {
            accountTerritoryIds.put(acc.Id, new List<Id>{
                    acc.Territory__c
            });
        }

        for (List<Id> allTerrIds : accountTerritoryIds.values()) {
            if (!allTerrIds.isEmpty()) {
                allTerrIds.addAll(SecondProjectTerritoryHelper.growUpOnHierarchy(allTerrIds.get(0)));
            }
        }

        for (Id accountId : accountTerritoryIds.keySet()) {

            for (Territory_User__c territoryUser : SecondProjectTerritoryHelper.getTerritoryUsersById(accountTerritoryIds.get(accountId))) {

                if (accountWithContacts.containsKey(accountId)) {
                    for (Id contactId : accountWithContacts.get(accountId)) {
                        ContactShare contactShare = new ContactShare();
                        contactShare.ContactAccessLevel = 'Read';
                        contactShare.ContactId = contactId;
                        contactShare.UserOrGroupId = territoryUser.User__c;
                        contactSharesList.add(contactShare);
                    }
                }

            }
        }

        insert contactSharesList;
    }


    public static void onAfterDelete(List<Reference__c> references) {
        Set<Id> allContactIds = new Set<Id>();
        Map<Id, Integer> contactIds = new Map<Id, Integer>();

        List<Reference__c> allReferences = [
                SELECT Id,
                        Contact__c,
                        Account__c
                FROM Reference__c
        ];

        for (Reference__c ref : allReferences) {
            if (contactIds.get(ref.Contact__c) == null) {
                contactIds.put(ref.Contact__c, 1);
            } else {
                contactIds.put(ref.Contact__c, contactIds.get(ref.Contact__c) + 1);
            }
        }

        for (Reference__c reference : references) {
            if (contactIds.get(reference.Contact__c) == null) {
                allContactIds.add(reference.Contact__c);
            } else {
                contactIds.put(reference.Contact__c, contactIds.get(reference.Contact__c) - 1);
            }
        }

        delete AccountContactReferenceHelper.getContactSharesById(allContactIds);
    }


}