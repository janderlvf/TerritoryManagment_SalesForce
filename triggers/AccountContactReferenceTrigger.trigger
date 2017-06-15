/**
 * Created by new on 08.06.2017.
 */

trigger AccountContactReferenceTrigger on Reference__c (after insert, after delete) {

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            AccountContactReferenceHandler.onAfterInsert(Trigger.new);
        }

        if (Trigger.isDelete) {
            AccountContactReferenceHandler.onAfterDelete(Trigger.old);
        }

    }

}