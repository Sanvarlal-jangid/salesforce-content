import { LightningElement,track,wire } from 'lwc';
import methodName from '@salesforce/apex/paper2class.methodName';

export default class Practicepaper2 extends LightningElement {
      get options() {
        return [
      
            { label: 'Adhar card', value: 'Adhar card' },
            { label: 'pan card', value: 'pan card' },
            { label: 'voterid', value: 'voterid' },
            { label: 'RashanCard', value: 'RashanCard' },
            { label: 'Y Card', value: 'Y Card' },
            { label: 'Vo Card', value: 'Vo Card' },
        ];
    }

    @track yearlist;
       @wire(methodName)
       getdata(result){
          if(result.data){
            this.yearlist=result.data;
          } else if(result.error){
            console.log('error in year finding',result.error);
          }
       }
    get optionsofactive(){
      return [
           { label: 'true', value: 'true' },
            { label: 'false', value: 'false' },
      ]
    }
    handledocumenttype(event){
       console.log('handledocumrnttype',event.target.value);
    }

 handleisActive(event){
       console.log('handle is active',event.target.value);
    }
    bringrecord(){
        
    }

}