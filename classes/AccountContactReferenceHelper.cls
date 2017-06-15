/**
 * Created by new on 08.06.2017.
 */

public with sharing class AccountContactReferenceHelper {

    public static List<Account> getAccountsById(Set<Id> accountIds) {
        return [
                SELECT Id,
                        Territory__c
                FROM Account
                WHERE Id IN :accountIds
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
}