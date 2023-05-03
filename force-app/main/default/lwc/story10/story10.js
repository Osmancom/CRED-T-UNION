import { LightningElement, wire,api, track } from 'lwc';
import fetchCusTypeLocal from '@salesforce/apex/Story10.fetchCusType'
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi'
import FdDetailLocal from '@salesforce/schema/FD_Details__c'
import depTypeLocal from '@salesforce/schema/FD_Details__c.Deposit_Type__c'
import payFreqLocal from '@salesforce/schema/FD_Details__c.Payout_Frequency__c'
import interestSchFetch from '@salesforce/apex/Story10.interestSchFetch'
import updateFD from '@salesforce/apex/Story10.updateFD'
import {ShowToastEvent} from 'lightning/platformShowToastEvent'

export default class Story10 extends LightningElement {
@api recordId
customerOptions=[]
selectedCusType=''
@track depTypeOptions=[]
selectedDepType=''
payFreqData// bütün payout frequency datasını tutan property
@track payFreqOptions=[]
tenorInMonth=''
tenorInDay=''
FdAmount=0
listScheme=[]
selectedIntRate
selectedIntSchmId
//Customer Type Combobox icin olan kodlar, picklist icinde secilmis degeri getiricez
@wire(fetchCusTypeLocal,{
    fdId:'$recordId'
})wiredData({error, data}){
    if(data){
        
        let option = [];
        option.push({label:data.Customer_Type__c, value:data.Customer_Type__c})//databasedeki secilmis degerler push edildi
        this.customerOptions=option;
        console.log('Option is ' + JSON.stringify(this.customerOptions))
    }
    else if(error){
        console.error('Error is ' + JSON.stringify(error))
    }


}

cusTypeChange(event){
    console.log('Selected Customer Type is ' + event.detail.value)//console da kontrol icin yazdık 
    this.selectedCusType=event.detail.value
}
//Deposit Type ve Payout Frequency icin öncelikle objectin datalarini aliyoruz, Combobox:picklist içindeki değerleri secmesine izin vericez.
@wire(getObjectInfo, {objectApiName:FdDetailLocal})//Önce object dataları cekildi.
    fdObjectInfo///Burada import edilen FD Detail deki dataları propertye aktardık

//Deposit Type ın picklistlarini alicaz 
@wire( getPicklistValues, { recordTypeId: '$fdObjectInfo.data.defaultRecordTypeId', fieldApiName: depTypeLocal } )
wiredDataDep( { error, data } ) {        
    if (data) {             
        let options = [];            
        data.values.forEach(element => {   // forEach(function)(element){}}
            options.push({label: element.label ,value: element.value} );//picklist degerlerini görüyoruz
        });
        this.depTypeOptions = options;      
        console.log( 'Options are ' + JSON.stringify( this.depTypeOptions ) );
    }else if( error ) {
        console.error( JSON.stringify(error) );
    }
}
//Payout Frequency icin
@wire( getPicklistValues, { recordTypeId: '$fdObjectInfo.data.defaultRecordTypeId', fieldApiName: payFreqLocal } )
    wiredDataPay( { error, data } ){      
        if (data)       
            this.payFreqData=data//bütün payout frequency datasını aldık
    
        if( error ) {
            console.error( JSON.stringify(error) );
        }
    }

    depTypeChange(event){
        console.log('Selected Deposit Type is ' + event.detail.value)//Control icin
        this.selectedDepType=event.detail.value
        //Dependency olduğu için controller fieldın onchange kısmında bu islemleri yapıyoruz.
        
        //Field Dependency icin
        let key = this.payFreqData.controllerValues[event.detail.value];
        this.payFreqOptions = this.payFreqData.values.filter(opt => opt.validFor.includes(key)) //filter(function)(opt){}
    }

    payoutFreqChange(event){
        console.log('Selected Payout Freq is ' + event.detail.value)
        this.selectedPayFreq=event.detail.value

    }
//Tenor In Months componenti icin
    get tenorMonthOptions(){
        let options =[]
        for(var i=0;i<85;i++){
            options.push({label:i.toString(), value:i.toString()})
    }
        return options

    }

    tenorMonthChange(event){
        console.log('Selected Tenor In Month is ' + event.detail.value)
        this.tenorInMonth=event.detail.value

}
//Tenor In Days componenti icin
    get tenorDayOptions(){
        let options =[]
        for(var i=0;i<30;i++){
            options.push({label:i.toString(), value:i.toString()})
    }
        return options

}
    tenorDayChange(event){
        console.log('Selected Tenor In Day is ' + event.detail.value)
        this.tenorInDay=event.detail.value
}

    fdAmountChange(event){
        console.log('Selected FD Amount is ' + event.detail.value)
        this.FdAmount=event.detail.value
}
 // Scheme  change i
schmChange(event){
    var schemeRecId = event.detail.value
    for(var i=0;i<this.listScheme.length;i++){
        if(schemeRecId==this.listScheme[i].value){
            this.selectedIntRate=this.listScheme[i].interestRate
            this.selectedIntSchmId=schemeRecId
        }
}


}
//Fetch Scheme buttonu icin
fetchScheme(event){
    //Validate inputs
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.clsFrmFetchSchm');
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) { //Customer type,Deposite Type,Payout Frequency,Tenor Months,Tenor Day ve FD Amount inputlarının doluluklarını sorguladık.
            inputField.reportValidity();
            isValid = false;
        }             
    }); 
    if(isValid){
        // call apexImperativeMethod.js
        interestSchFetch({
            cusType:this.selectedCusType,
            depType:this.selectedDepType,
            tnrDay:this.tenorInDay,
            tnrMonth:this.tenorInMonth,
            fdAmnt:this.FdAmount,
            fdId:this.recordId
    }).then(result =>{
        var lstchm = [] //[{Label:'Interest Scheme 1', Interest_Rate:'5.4', Id:'2wedased324'},{Label:'Interest Scheme 1', Interest_Rate:'5.4', Id:'2wedased324'}]
        if(result){
            for(var i=0;i<result.length;i++){
                var tempObj = {}
                tempObj.label=result[i].Name
                tempObj.value=result[i].Id
                tempObj.interestRate=result[i].Interest_Rate__c
                lstchm.push(tempObj)
            }
    }
    this.listScheme=lstchm
    console.log('Scheme records: ' + JSON.stringify(result))
})
    .catch(error=>{

        console.log('Scheme records: ' + JSON.stringify(result))

})



}   
}

save(event){
     //Validate inputs
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.clsFrmFetchSchm');
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) {//İlk 6 Customer type,Deposite Type,Payout Frequency,Tenor Months,Tenor Day ve FD Amount inputlarının doluluklarını sorguladık.
            inputField.reportValidity();
            isValid = false;
        }             
    }); 
    //Validate inputs
    inputFields = this.template.querySelectorAll('.classForSaveButton');
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) {//Son 2 Scheme Options ve Interest rate inputlarının doluluklarını sorguladık.
            inputField.reportValidity();
            isValid = false;
        }             
    });
    if(isValid){
        // call apexImperativeMethod.js
        updateFD({
            payFreq:this.selectedPayFreq,
            depType:this.selectedDepType,
            tnrDay:this.tenorInDay,
            tnrMonth:this.tenorInMonth,
            fdAmnt:this.FdAmount,
            fdId:this.recordId,
            intRate:this.selectedIntRate,
            schmID:this.selectedIntSchmId
        }).then(result=>{
            console.log('Save Scheme details:: ' + JSON.stringify(result))
            const event = new ShowToastEvent({//ekranda Success mesajini user a  gösterme 
                title:'Success',
                message:'Record Updated',
                variant:'Success'
            })
            this.dispatchEvent(event)

        }).catch(error=>{
            console.log('Save Scheme details:: ' + JSON.stringify(error))
            const event = new ShowToastEvent({//ekranda error mesajini user a  gösterme 
                title:'Error',
                message:'Error Detected',
                variant:'Error'
            })
            this.dispatchEvent(event)

        })

    } 

}

    
}