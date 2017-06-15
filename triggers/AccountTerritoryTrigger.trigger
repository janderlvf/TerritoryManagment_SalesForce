/**
 * Created by new on 06.06.2017.
 */

trigger AccountTerritoryTrigger on Account (after insert, after update, before delete) {

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            AccountTerritoryHandler.onAfterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            AccountTerritoryHandler.onAfterUpdate(Trigger.new);
        }

    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            AccountTerritoryHandler.onBeforeDelete(Trigger.old);
        }
    }

}