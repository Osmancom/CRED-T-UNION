public class FD_DetailTriggerHandler {
public static void relationshipOff(List<FD_Details__c> listNew){
       
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

public static void onAfterInsert(List<FD_Details__c> fdList){
        List<FD_Details__Share> fdShare = new List<FD_Details__Share>();
        // Yeni oluşturulan record'lar için teker teker share kaydı oluşturulur ve shareObj listesine eklenir
        for(FD_Details__c fd : fdList){
            if(String.isNotBlank(fd.Relationship_Officer__c) && fd.OwnerId != fd.Relationship_Officer__c){
      /* FD_Details__Share fds = new FD_Details__Share();
        fds.ParentId = parentId;//fd.Id;
        fds.UserOrGroupId = userGroupId;//fd.Relationship_Officer__c;
        fds.AccessLevel = 'Read';
        fds.RowCause = 'Manual';
        fdShare.add(fds);  Bu kisimdaki kod tekrar edeceginden aynı class icinde private bir method icinde olusturulubilir. */
                fdShare.add(createShareIns(fd.Id, fd.Relationship_Officer__c));  
            }
           if(String.isNotBlank(fd.Sales_Representative__c) && fd.OwnerId != fd.Sales_Representative__c){
      
                fdShare.add(createShareIns(fd.Id, fd.Sales_Representative__c));  
            } 
        }
        // Döngü bittikten sonra share objecti insert edilir
        Database.insert(fdShare,false);// insert fdShare;
        
    }

 public static void onAfterUpdate(List<FD_Details__c> fdList, Map<Id,FD_Details__c> fdOldMap){
        List<FD_Details__Share> fdShare = new List<FD_Details__Share>();
        List<FD_Details__Share> fdOldDelete = new List<FD_Details__Share>();
        
        // Yeni oluşturulan record'lar için teker teker share kaydı oluşturulur ve shareObj listesine eklenir
        for(FD_Details__c fd : fdList){
            
            // Owner'ın zaten yetkisi olduğundan Relationship Owner ise çalışmamalı, update işleminde Relationship Officer bilgisi güncellendiyse çalışmalı 
            if(String.isNotBlank(fd.Relationship_Officer__c) && fd.OwnerId != fd.Relationship_Officer__c && 
               fd.Relationship_Officer__c != fdOldMap.get(fd.Id).Relationship_Officer__c){
                   
                // Share objectine eklenecek yeni instance oluşturuyoruz.
                fdShare.add(createShareIns(fd.Id, fd.Relationship_Officer__c)); 
            }
                 // Eski Relationship Officer'ın yetkisini kaldırıyoruz
                List<FD_Details__Share> fdsOld = [SELECT Id, RowCause FROM FD_Details__Share WHERE ParentId =: fd.Id AND 
                                            UserOrGroupId = :fdOldMap.get(fd.Id).Relationship_Officer__c AND RowCause = 'Manual' ]; 
                   if(fdsOld.size()>0 &&fdOldMap.get(fd.Id).Relationship_Officer__c != fd.Relationship_Officer__c&&
                      fdOldMap.get(fd.Id).Relationship_Officer__c != fd.Sales_Representative__c){
                       fdOldDelete.addAll(fdsOld);
                   } 
            if(String.isNotBlank(fd.Sales_Representative__c) && fd.OwnerId != fd.Sales_Representative__c && 
               fd.Sales_Representative__c != fdOldMap.get(fd.Id).Sales_Representative__c){
                   
                // Share objectine eklenecek yeni instance oluşturuyoruz.
                fdShare.add(createShareIns(fd.Id, fd.Sales_Representative__c)); 
                      
            }
            
                // Eski Sales Representative'in yetkisini kaldırıyoruz   
                List<FD_Details__Share> fdsSROld = [SELECT Id, RowCause FROM FD_Details__Share WHERE ParentId =: fd.Id AND 
                                            UserOrGroupId = :fdOldMap.get(fd.Id).Sales_Representative__c AND RowCause = 'Manual']; 
                   if(fdsSROld.size()>0 && fdOldMap.get(fd.Id).Sales_Representative__c != fd.Relationship_Officer__c && 
                     fdOldMap.get(fd.Id).Sales_Representative__c != fd.Sales_Representative__c){
                       fdOldDelete.addAll(fdsSROld);
                   }
            
            
        }
                 
        
        // Döngü bittikten sonra share objecti insert edilir
        Database.insert(fdShare,false);
        Database.delete(fdOldDelete,false);
    }   

    
    
    // Share Object Instance
        private static FD_Details__Share createShareIns(String parentId, String userGroupId){
        FD_Details__Share fds = new FD_Details__Share();
        fds.ParentId = parentId;
        fds.UserOrGroupId = userGroupId;
        fds.AccessLevel = 'Read';
        fds.RowCause = 'Manual';
        
        return fds;
    }
}