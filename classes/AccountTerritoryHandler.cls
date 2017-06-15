/**
 * Created by new on 06.06.2017.
 */

public with sharing class AccountTerritoryHandler {

    public static void onAfterInsert(List<Account> accounts) {
        List<AccountShare> accountSharesList = new List<AccountShare>();
        Map<Id, List<Id>> accountTerritoryIds = new Map<Id, List<Id>>();

        for (Account acc : accounts) {
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
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = accountId;
                accountShare.UserOrGroupId = territoryUser.User__c;
                accountShare.AccountAccessLevel = 'Read';
                accountShare.ContactAccessLevel = 'None';
                accountShare.CaseAccessLevel = 'None';
                accountShare.OpportunityAccessLevel = 'None';
                accountSharesList.add(accountShare);
            }
        }

        insert accountSharesList;
    }

    public static void onAfterUpdate(List<Account> accounts) {
        List<AccountShare> accountSharesList = new List<AccountShare>();
        List<AccountShare> deleteAccountShares = new List<AccountShare>();
        List<ContactShare> deleteContactShares = new List<ContactShare>();
        List<ContactShare> contactSharesList = new List<ContactShare>();
        Map<Id, List<Id>> accountWithContacts = new Map<Id, List<Id>>();
        Map<Id, List<Id>> accountTerritoryIds = new Map<Id, List<Id>>();
        Set<Id> contactIds = new Set<Id>();

        for (Account acc : accounts) {
            accountTerritoryIds.put(acc.Id, new List<Id>{
                    acc.Territory__c
            });
        }

        for (List<Id> allTerrIds : accountTerritoryIds.values()) {
            if (!allTerrIds.isEmpty()) {
                allTerrIds.addAll(SecondProjectTerritoryHelper.growUpOnHierarchy(allTerrIds.get(0)));
            }
        }

        deleteAccountShares.addAll(SecondProjectTerritoryHelper.getAccountSharesById(accountTerritoryIds.keySet()));
        delete deleteAccountShares;

        for (Reference__c reference : SecondProjectTerritoryHelper.getReferencesByAccountId(accountTerritoryIds.keySet())) {
            if (accountWithContacts.get(reference.Account__c) == null) {
                accountWithContacts.put(reference.Account__c, new List<Id>{
                        reference.Contact__c
                });
            } else {
                accountWithContacts.get(reference.Account__c).add(reference.Contact__c);
            }
        }

        for (Id accountId : accountWithContacts.keySet()) {
            for (Id contactId : accountWithContacts.get(accountId)) {
                contactIds.add(contactId);
            }
        }

        deleteContactShares.addAll(SecondProjectTerritoryHelper.getContactSharesById(contactIds));
        delete deleteContactShares;

        for (Id accountId : accountTerritoryIds.keySet()) {

            for (Territory_User__c territoryUser : SecondProjectTerritoryHelper.getTerritoryUsersById(accountTerritoryIds.get(accountId))) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = accountId;
                accountShare.UserOrGroupId = territoryUser.User__c;
                accountShare.AccountAccessLevel = 'Read';
                accountShare.ContactAccessLevel = 'None';
                accountShare.CaseAccessLevel = 'None';
                accountShare.OpportunityAccessLevel = 'None';
                accountSharesList.add(accountShare);

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
        insert accountSharesList;
    }

    public static void onBeforeDelete(List<Account> accounts) {
        List<Reference__c> deleteReferences = new List<Reference__c>();
        List<Id> accountReference = new List<Id>();
        for (Account acc : accounts) {
            accountReference.add(acc.Id);
        }
        List<Reference__c> allReferences = [
                SELECT Id,
                        Contact__c,
                        Account__c
                FROM Reference__c
        ];


        for (Id accId : accountReference) {
            for (Reference__c ref : allReferences) {
                if (ref.Account__c == accId) {
                    deleteReferences.add(ref);
                }
            }
        }

        delete deleteReferences;
    }

}