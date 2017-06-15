/**
 * Created by new on 07.06.2017.
 */

public with sharing class SecondProjectAccountShareHelper {

    public static List<Account> getAccountsByTerritory(List<Id> territoryIds) {
        return [
                SELECT Id,
                        Name,
                        Territory__c
                FROM Account
                WHERE Territory__c IN :territoryIds
        ];
    }

    public static List<Reference__c> getReferencesByAccountId(List<Id> accountIds) {
        return [
                SELECT Id,
                        Account__c,
                        Contact__c
                FROM Reference__c
                WHERE Account__c IN :accountIds
        ];
    }

    public static List<Id> diveIntoTerritoryHierarchy(List<Id> selectIds) {
        List<Territory__c> allTerritories;
        List<Id> allTerritoriesId = new List<Id>();
        allTerritoriesId.addAll(selectIds);
        do {
            allTerritories = [
                    SELECT Id
                    FROM Territory__c
                    WHERE Parent__c IN :selectIds
            ];
            selectIds.clear();
            for (Territory__c terr : allTerritories) {
                selectIds.add(terr.Id);
            }
            allTerritoriesId.addAll(selectIds);
        } while (!allTerritories.isEmpty());
        return allTerritoriesId;
    }

}