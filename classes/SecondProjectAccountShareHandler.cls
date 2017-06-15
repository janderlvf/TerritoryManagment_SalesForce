/**
 * Created by new on 06.06.2017.
 */

public with sharing class SecondProjectAccountShareHandler {

    public static void onAfterInsert(List<Territory_User__c> territoryUsers) {
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<ContactShare> contactSharesList = new List<ContactShare>();

        Map<Id, List<Id>> userTerritoriesIds = new Map<Id, List<Id>>();

        for (Territory_User__c territoryUser : territoryUsers) {
            userTerritoriesIds.put(territoryUser.User__c, new List<Id>{
                    territoryUser.Territory__c
            });
        }

        for (List<Id> allTerrIds : userTerritoriesIds.values()) {
            allTerrIds.addAll(SecondProjectAccountShareHelper.diveIntoTerritoryHierarchy(allTerrIds));
        }

        for (Id userId : userTerritoriesIds.keySet()) {
            List<Id> accountsIds = new List<Id>();
            for (Account a : SecondProjectAccountShareHelper.getAccountsByTerritory(userTerritoriesIds.get(userId))) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = a.Id;
                accountShare.UserOrGroupId = userId;
                accountShare.AccountAccessLevel = 'Read';
                accountShare.ContactAccessLevel = 'None';
                accountShare.CaseAccessLevel = 'None';
                accountShare.OpportunityAccessLevel = 'None';
                accountShareList.add(accountShare);
                accountsIds.add(a.Id);
            }

            for (Reference__c ref : SecondProjectAccountShareHelper.getReferencesByAccountId(accountsIds)) {
                ContactShare contactShare = new ContactShare();
                contactShare.ContactAccessLevel = 'Read';
                contactShare.ContactId = ref.Contact__c;
                contactShare.UserOrGroupId = userId;
                contactSharesList.add(contactShare);
            }
        }
        insert accountShareList;
        insert contactSharesList;
    }

    public static void onAfterDelete(List<Territory_User__c> territoryUsers) {
        List<AccountShare> accountSharesList = new List<AccountShare>();
        List<ContactShare> contactSharesList = new List<ContactShare>();

        Map<Id, List<Id>> userTerritoriesIds = new Map<Id, List<Id>>();

        for (Territory_User__c territoryUser : territoryUsers) {
            userTerritoriesIds.put(territoryUser.User__c, new List<Id>{
                    territoryUser.Territory__c
            });
        }

        for (List<Id> allTerrIds : userTerritoriesIds.values()) {
            allTerrIds.addAll(SecondProjectAccountShareHelper.diveIntoTerritoryHierarchy(allTerrIds));
        }

        for (Id userId : userTerritoriesIds.keySet()) {
            List<Id> accountsId = new List<Id>();

            for (Account a : SecondProjectAccountShareHelper.getAccountsByTerritory(userTerritoriesIds.get(userId))) {
                accountsId.add(a.Id);
            }

            List<AccountShare> listShare = [
                    SELECT Id
                    FROM AccountShare
                    WHERE UserOrGroupId = :userId
                    AND AccountId IN :accountsId
                    AND RowCause = 'Manual'
            ];
            accountSharesList.addAll(listShare);

            List<Id> contactsIds = new List<Id>();
            for (Reference__c ref : SecondProjectAccountShareHelper.getReferencesByAccountId(accountsId)) {
                contactsIds.add(ref.Contact__c);
            }

            List<ContactShare> contactShares = [
                    SELECT Id
                    FROM ContactShare
                    WHERE UserOrGroupId = :userId
                    AND ContactId IN :contactsIds
                    AND RowCause = 'Manual'
            ];
            contactSharesList.addAll(contactShares);
        }

        delete contactSharesList;
        delete accountSharesList;
    }

}