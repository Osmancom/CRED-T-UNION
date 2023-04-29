trigger FD_DetailTrigger on FD_Details__c (before insert,before update,after insert,after update) {
if(Trigger.isBefore&&Trigger.isInsert){
      FD_DetailTriggerHandler.relationshipOff(Trigger.new);  
    }
   if(Trigger.isBefore&&Trigger.isUpdate){
      FD_DetailTriggerHandler.relationshipOff(Trigger.new);  
    }     
     if(Trigger.isAfter&&Trigger.isInsert){
      FD_DetailTriggerHandler.onAfterInsert(Trigger.new);  
    }     
     if(Trigger.isAfter&&Trigger.isUpdate){
      FD_DetailTriggerHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);  
    }     

}