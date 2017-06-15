/**
 * Created by new on 07.06.2017.
 */

public with sharing class SecondProjectTerritoryHelper {

    public static List<Territory_User__c> getTerritoryUsersById(List<Id> territories) {
        return [
                SELECT Id,
                        Territory__c,
                        User__c
                FROM Territory_User__c
                WHERE Territory__c IN :territories
        ];
    }

    public static List<AccountShare> getAccountSharesById(Set<Id> accountIds) {
        return [
                SELECT Id,
                        AccountId
                FROM AccountShare
                WHERE AccountId = :accountIds
                AND RowCause = 'Manual'
        ];
    }

    public static List<Reference__c> getReferencesByAccountId(Set<Id> accountIds) {
        return [
                SELECT Id,
                        Account__c,
                        Contact__c
                FROM Reference__c
                WHERE Account__c IN :accountIds
        ];
    }

    public static List<ContactShare> getContactSharesById(Set<Id> contactIds) {
        return [
                SELECT Id
                FROM ContactShare
                WHERE ContactId IN :contactIds
                AND RowCause = 'Manual'
        ];
    }

    public static List<Id> growUpOnHierarchy(Id currentTerritory) {
        Territory__c territory;
        List<Id> allTerritoriesId = new List<Id>();
        while (currentTerritory != null) {
            allTerritoriesId.add(currentTerritory);
            territory = [
                    SELECT Id,Parent__c
                    FROM Territory__c
                    WHERE Id = :currentTerritory
            ];
            currentTerritory = territory.Parent__c;

        }
        return allTerritoriesId;
    }

}