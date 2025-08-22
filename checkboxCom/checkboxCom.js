import { LightningElement , api} from 'lwc';

export default class CheckboxCom extends LightningElement {
    @api recordid;
    handleCheckboxChange(event){
        console.log(event);
        console.log(this.recordid);
        const photoClickEvent = new CustomEvent("selectedvalue", {
        composed: true,
        bubbles: true,
        cancelable: true,
        detail: {
          recordId: this.recordid
        },
    });
    this.dispatchEvent(photoClickEvent);

    }
}