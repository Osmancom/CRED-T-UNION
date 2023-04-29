public class FixedDepositTriggerHandlerClass {
    
    public static void beforeInsertTrigger(List<FD_Details__c> listNew){
       
        Set<String> branchNames = new Set<String>();
        for(FD_Details__c newRecord:listNew){
            if(String.isNotBlank(newRecord.Branch__c)){
                branchNames.add(newRecord.Branch__c);
                
            }
        }
        List<Branch_Relationship_Officer__c> broList = new List<Branch_Relationship_Officer__c>();
        if(branchNames.size()>0){
            broList=[SELECT Id, Branch_Name__c, Relationship_Officer__c FROM Branch_Relationship_Officer__c 
                     WHERE Branch_Name__c=:branchNames];
        }
        Map<String,String> branchOfficers = new Map<String, String>();
        for(Branch_Relationship_Officer__c coupleRecords:broList){
            if(broList.size()>0){
            branchOfficers.put(coupleRecords.Branch_Name__c, coupleRecords.Relationship_Officer__c);
          }  
        }
        for(FD_Details__c newRecord:listNew){
            if(String.isNotBlank(newRecord.Branch__c) && branchOfficers.containsKey(newRecord.Branch__c)){
                newRecord.Relationship_Officer__c = branchOfficers.get(newRecord.Branch__c);
            }
        }
    }

}