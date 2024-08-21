import { LightningElement,wire,api,track } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import LAST_VISIT_DATE from "@salesforce/schema/Account.Last_Location_Visit_Date__c"; 
const fields = [LAST_VISIT_DATE];
export default class Toast_AccountHealth extends LightningElement {
  @api recordId;
  @track label;
 @track classList;
 @track description;
 @track lastVisitedDate;
  @wire(getRecord, { recordId: "$recordId", fields: fields })
  account({data,error}){
    if(data){
       this.lastVisitedDate = data.fields.Last_Location_Visit_Date__c.value;
       var today = new Date();
       var last_visitedDate = new Date(this.lastVisitedDate);
       var timeinmilisec =  today.getTime()-last_visitedDate.getTime();
       var numberOfDays = Math.floor(timeinmilisec / (1000 * 60 * 60 * 24));
       if(numberOfDays<30){
         this.label = 'Green';
         this.classList ='slds-badge slds-theme_success';
         this.description = 'Last Location Visit Date is less than 30 days ago';
       }else if(numberOfDays>=30 && numberOfDays<60){
        this.label = 'Yellow';
         this.classList ='slds-badge slds-theme_warning';
         this.description = 'Last Location Visit Date is greater than 30 days ago but less than 60 days ago';
       }else{
        this.label = 'Red';
        this.classList ='slds-badge slds-theme_error';
        this.description = 'Last Location Visit Date is greater than 60 days';
       }
    }
    if(error){

    }
  }

}