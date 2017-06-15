/**
 * Created by new on 06.06.2017.
 */

public with sharing class SecondProjectUniqueTerritoryHandler {

    public static void onBeforeInsertUpdate(List<Territory__c> territoryList) {
        List<Territory__c> newTerritories = new List<Territory__c>();
        List<Id> newParentIds = new List<Id>();
        for (Territory__c territory : territoryList) {
            newTerritories.add(territory);
            newParentIds.add(territory.Parent__c);
        }

        List<Territory__c> allTerritories = [
                SELECT Id,
                        Name,
                        Parent__c
                FROM Territory__c
                WHERE Parent__c IN :newParentIds
        ];

        for (Territory__c territoryNew : newTerritories) {
            for (Territory__c territory : allTerritories) {
                if (territoryNew.Parent__c == territory.Parent__c) {
                    if (territoryNew.Name == territory.Name) {
                        territoryNew.addError(SecondProjectMessages.UNIQUE_MESSAGE);
                    }
                }
            }
        }
    }

    public static void onBeforeDelete(List<Territory__c> territories) {
        List<Territory_User__c> deleteTerritoryUsers = new List<Territory_User__c>();
        List<Id> territoryIds = new List<Id>();
        for (Territory__c terr : territories) {
            territoryIds.add(terr.Id);
        }
        List<Territory_User__c> allTerritoryUsers = [
                SELECT Id,
                        Territory__c,
                        User__c
                FROM Territory_User__c
        ];


        for (Id terrId : territoryIds) {
            for (Territory_User__c terrUser : allTerritoryUsers) {
                if (terrUser.Territory__c == terrId) {
                    deleteTerritoryUsers.add(terrUser);
                }
            }
        }

        delete deleteTerritoryUsers;
    }
}