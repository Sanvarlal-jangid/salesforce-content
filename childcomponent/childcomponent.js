import { LightningElement ,api} from 'lwc';

export default class Childcomponent extends LightningElement {
    @api message = "im coming from child component";
    @api contactData;
    columnData = [
        {label : "Name" ,fieldName :"Name"},
         {label : "Phone" ,fieldName :"Phone"}
    ]
    handleClick(event){
        const callParent = new CustomEvent('showmessage',{detail:this.message,bubbles :true});
        this.dispatchEvent(callParent);
    }
}