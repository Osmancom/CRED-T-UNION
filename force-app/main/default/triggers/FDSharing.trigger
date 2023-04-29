trigger FDSharing on FD_Detail__c (after insert) {
    List<FD_Detail__Share> shares = new List<FD_Detail__Share>();
    
    // Loop through all the new Custom_FD_Detail__c records
    for(FD_Detail__c fd : Trigger.new) {
        // Check if the Relationship Officer field is populated
        if(fd.Relationship_Officer__c != null) {
            // Create a new share record and set the sharing access level to 'Read Only'
            FD_Detail__Share share = new FD_Detail__Share();
            share.ParentId = fd.Id;
            share.UserOrGroupId = fd.Relationship_Officer__c;
            share.AccessLevel = 'Read';
            shares.add(share);
        }
    }
    
    // Insert the share records to apply the sharing rules
    insert shares;
}