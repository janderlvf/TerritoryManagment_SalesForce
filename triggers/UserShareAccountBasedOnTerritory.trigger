/**
 * Created by new on 02.06.2017.
 */

trigger UserShareAccountBasedOnTerritory on Territory_User__c (after insert, after update, after delete) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SecondProjectAccountShareHandler.onAfterInsert(Trigger.new);
        }

        if (Trigger.isDelete) {
            SecondProjectAccountShareHandler.onAfterDelete(Trigger.old);
        }

    }

}