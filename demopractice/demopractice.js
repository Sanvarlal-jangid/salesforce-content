import { LightningElement,track,api } from 'lwc';

export default class Demopractice extends LightningElement {
          @api recordId;
          @track message = "this is message from javascript";

          handleevent(event){
          //  console.log(recordId);
            this.message = event.target.value;
          }
}