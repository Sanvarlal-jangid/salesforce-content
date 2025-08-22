import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class NavigationButtons extends NavigationMixin(LightningElement) {


    @track isShowModal = false;
    selectedObject;

    showModalBox(event) {
        this.isShowModal = true;
        this.selectedObject = event.target.dataset.object;
    }

    hideModalBox() {
        this.isShowModal = false;
    }
    proceedToForm(event) {
        this.isShowModal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.selectedObject,
                actionName: 'new'
            }
        });
    }
}