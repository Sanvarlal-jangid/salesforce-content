import LightningDatatable from 'lightning/datatable';
import customButtonTemplate from './custombuttoncell.html';

export default class Custombuttoncell extends LightningDatatable {
    static customTypes = {
        contactSelector: {
            template: customButtonTemplate,
            standardCellLayout: true,

            typeAttributes: ['disabled', 'selected','Id']
        }
    };
    handleCheckboxChange(event){
        console.log(event);
    }
}