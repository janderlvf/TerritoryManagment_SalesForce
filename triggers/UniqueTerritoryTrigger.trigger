/**
 * Created by new on 06.06.2017.
 */

trigger UniqueTerritoryTrigger on Territory__c (before insert, before update, before delete) {

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            SecondProjectUniqueTerritoryHandler.onBeforeInsertUpdate(Trigger.new);
        }

        if (Trigger.isUpdate) {
            SecondProjectUniqueTerritoryHandler.onBeforeInsertUpdate(Trigger.new);
        }

        if (Trigger.isDelete) {
            SecondProjectUniqueTerritoryHandler.onBeforeDelete(Trigger.old);
        }
    }

}