trigger FDSharingUpdate on FD_Detail__c (after insert, after update) {
    List<FD_Detail__Share> sharesToDelete = new List<FD_Detail__Share>();
    List<FD_Detail__Share> sharesToInsert = new List<FD_Detail__Share>();
    
    // Collect the Ids of the Custom FD Detail records that have been updated
    Set<Id> cfdIds = new Set<Id>();
    for (FD_Detail__c cfd : Trigger.new) {
        if (Trigger.isUpdate && cfd.Relationship_Officer__c != Trigger.oldMap.get(cfd.Id).Relationship_Officer__c) {
            cfdIds.add(cfd.Id);
        }
        else if (Trigger.isInsert) {
            cfdIds.add(cfd.Id);
        }
    }
    
    // Query the existing share records for the updated Custom FD Detail records
    List<FD_Detail__Share> existingShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM FD_Detail__Share WHERE ParentId IN :cfdIds];
    
    // Create new share records and delete old share records as necessary
    for (FD_Detail__c cfd : Trigger.new) {
        // Check if the Relationship Officer field is set
        if (cfd.Relationship_Officer__c != null) {
            // Find the existing share record for the Relationship Officer (if any)
            FD_Detail__Share existingShare = null;
            for (FD_Detail__Share share : existingShares) {
                if (share.ParentId == cfd.Id && share.UserOrGroupId == cfd.Relationship_Officer__c) {
                    existingShare = share;
                    break;
                }
            }
            
            // Create a new share record if there isn't an existing one
            if (existingShare == null) {
                FD_Detail__Share share = new FD_Detail__Share();
                share.ParentId = cfd.Id;
                share.UserOrGroupId = cfd.Relationship_Officer__c;
                share.AccessLevel = 'Read';
                sharesToInsert.add(share);
            }
        }
    }
    
    // Delete old share records that are no longer needed
    for (FD_Detail__Share share : existingShares) {
        if (share.AccessLevel == 'Read' && !sharesToInsert.contains(share) && share.UserOrGroupId != Trigger.oldMap.get(share.ParentId).Relationship_Officer__c) {
            sharesToDelete.add(share);
        }
    }
    
    // Insert new share records
    if (!sharesToInsert.isEmpty()) {
        Database.SaveResult[] results = Database.insert(sharesToInsert, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                System.debug(result.getErrors());
            }
        }
    }
    
    // Delete old share records
    if (!sharesToDelete.isEmpty()) {
        Database.delete(sharesToDelete);
    }
}