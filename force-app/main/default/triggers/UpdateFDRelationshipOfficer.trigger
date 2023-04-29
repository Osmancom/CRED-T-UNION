trigger UpdateFDRelationshipOfficer on FD_Detail__c (before insert,before update,after insert,after update) {
    if(Trigger.isBefore&&Trigger.isInsert){
      UpdateFDRelationshipOffHandler.relationshipOff(Trigger.new);  
    }
   if(Trigger.isBefore&&Trigger.isUpdate){
      UpdateFDRelationshipOffHandler.relationshipOff(Trigger.new);  
    }     
     if(Trigger.isAfter&&Trigger.isInsert){
      UpdateFDRelationshipOffHandler.onAfterInsert(Trigger.new);  
    }     
     if(Trigger.isAfter&&Trigger.isUpdate){
      UpdateFDRelationshipOffHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);  
    }     

}