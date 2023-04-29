public with sharing class Story10 {
    //User in girdigi Customer Type bilgisini org dan almak icin SOQL yaptik.
    @AuraEnabled(cacheable=true)//(cacheable=true) ifadesi SOQL işelmelerinde yazilir genelde.
    public static FD_Detail__c fetchCusType(String fdId){
        FD_Detail__c fdRec = [SELECT Id, Name, Customer_Type__c FROM FD_Detail__c WHERE Id=:fdId];
        return fdRec;
        // return[SELECT Id,Name,Customer_Type__c FROM FD_Detail__c WHERE Id=:fdId ];
    }
    //Fetch Scheme butonuna basılınca
    //User Customer Type,Deposit type,Payout frequency,Tenor Months,Tenor Days ve FD Amount fieldlarını doldurunca ona uygun Interest Scheme ve Interest Rate vereb SOQL yapildi
    @AuraEnabled(cacheable=true)
        public static List<Interest_Scheme__c> interestSchFetch(String cusType, String depType, Integer tnrDay, Integer tnrMonth, Integer fdAmnt, String fdId){
            system.debug('Deposit Type: ' + depType);
            system.debug('Customer Type: ' + cusType);
            system.debug('Fd Amount: ' + fdAmnt);
            system.debug('Tenor in Month: ' + tnrMonth);
            system.debug('Tenor in Day: ' + tnrDay);

            String customerTypeValue;
            String depositTypeValue;


            List<Interest_Scheme__c> listInt = [SELECT Id, Name, Customer_Type__c, Deposit_Type__c, From_Amount__c, 
             To_Amount__c, Tenor_From_Days__c, Tenor_To_Days__c, Tenor_From_Months__c, Tenor_To_Months__c, Interest_Rate__c FROM Interest_Scheme__c WHERE
             Customer_Type__c=:cusType AND Deposit_Type__c=:depType AND Tenor_To_Days__c>=:tnrDay AND Tenor_From_Days__c<=:tnrDay AND Tenor_To_Months__c>=:tnrMonth AND
             Tenor_From_Months__c<=:tnrMonth AND To_Amount__c>=:fdAmnt AND From_Amount__c<=:fdAmnt AND Active__c=true];

             return listInt;
    }
    //SAVE butonuna basilinca update islemini yaptik
    @AuraEnabled //DML işlemi yaptigimiz  icin (cacheable=true) yazmiyoruz.Cünkü (cacheable=true) DML desteklemiyor ApexImperativeMethod da 
    public static void updateFD(String depType, Integer tnrDay, Integer tnrMonth, Integer fdAmnt, String fdId, Decimal intRate, String schmID, String payFreq){

        system.debug('Deposit Type: ' + depType);
        system.debug('Payout Frequency: ' + payFreq);
        system.debug('Fd Amount: ' + fdAmnt);
        system.debug('Tenor in Month: ' + tnrMonth);
        system.debug('Tenor in Day: ' + tnrDay);
        system.debug('Interest Rate: ' + intRate);
        system.debug('FD Record Id: ' + fdId);

        FD_Detail__c recFd = new FD_Detail__c();
        recFd.Id=fdId;
        recFd.Deposit_Type__c=depType;
        recFd.Payout_Frequency__c=payFreq;
        recFd.Tenor_in_months__c=tnrMonth;
        recFd.Tenor_in_days__c=tnrDay;
        recFd.FD_Amount__c=fdAmnt;
        recFd.Interest_Rate__c=intRate;
        recFd.Interest_Scheme__c=schmID;

        update recFd;

    }
    
}