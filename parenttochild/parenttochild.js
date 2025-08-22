import { LightningElement, api, wire } from 'lwc';
import parentchildhandler from '@salesforce/apex/parentchildhandler.getContacts';

export default class Parenttochild extends LightningElement {
    accountContactData = [];
    @api recordId;
    error; 
    comingmessage;
  
    //       connectedCallback(){
            
    //   console.log("current record id from callback",this.recordId);

    //       }   

    
    @wire(parentchildhandler, { accountId: '$recordId' })

    wireData({ error, data }) {
        console.log('current record id '+this.recordId);
          console.log('data from apex ',data);
        if (data) {
            this.accountContactData = data;
        } else if (error) {
            this.error = error;
        }
    }
    constructor(){
        super();
        this.template.addEventListener('showmessage', this.handleParent.bind(this));
        console.log('current record id '+this.recordId);
    }
    // connectedCallback(){
    //     console.log("current record id from callback",this.recordId);
    // }
  

    handleParent(event){
     this.comingmessage = event.detail;
    }
}