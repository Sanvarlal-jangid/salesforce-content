import { LightningElement , wire , track} from 'lwc';
import getAllContacts from '@salesforce/apex/getRecordsDapTest.getAllContacts'
import getFields from '@salesforce/apex/getRecordsDapTest.getFields'

export default class DapTest extends LightningElement {
    colum = [ {
        label: "Created Date" , fieldName: "CreatedDate" , type: 'date' ,  sortable: "true"
    }] ;
    get columns() { 
        return this.colum;    
    }
    data ;
    filterData;
    @wire(getAllContacts) gettingAllData({data,error}){
        if(data){
            this.data = data;
            this.filterData = data;
        }else{
            console.log("Error " , error);
        }
    }
    value = ['CreatedDate'];
    fieldsOption ;
    @wire(getFields) getAllFields({data,error}){
        if(data){
            this.fieldsOption = [];
            Object.keys(data).forEach(ele=>{
                this.fieldsOption.push({
                    label: data[ele],
                    value: ele});
            })
        }
    };

    get options() {
        return this.fieldsOption;
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.colum = [];
        this.value.forEach(ele=>{
            if(ele == 'CreatedDate'){
                this.colum.push({
                    label: "Created Date" , fieldName: ele , type: 'date' ,  sortable: "true"
                })
            }else{
                this.colum.push({
                    label: ele,
                     fieldName: ele,
                     type: 'text'
                })
            }
        })
        this.colum.push({ type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } });
    }

    filter = [{Id: 1 , valuefield: '' , valueconjuction: ' ' , valueText: ''},
        {Id: 2 , valuefield: '' , valueconjuction: ' ' , valueText: ''},];

    get optionsConuction() {
        return [
            { label: 'equal', value: 'equal' },
            { label: 'not equal', value: 'not equal' },
        ];
    }

    handleChangeConujction(event) {
        try{
            let value = event.detail.value;
            let index = event.target.dataset.object;
            this.filter.forEach(ele =>{
            if(ele.Id == index){
                ele.valueconjuction = value;
            }
        });
        }catch(err){
            console.log(err)
        }
        
    }

    get getFieldForFilter(){
        let arr = [];
        if(this.colum){
            this.colum.forEach(ele =>{
                arr.push({
                    label: ele.label,
                    value: ele.label
                })
            })
            return arr;
        }
        else{
            return null;
        }
        
    }
    handleChangeFilter(event){
        let value = event.detail.value;
        let index = event.target.dataset.object;
        this.filter.forEach(ele =>{
            if(ele.Id == index){
                ele.valuefield = value;
            }
        })
    }
    index = 3;
    handleClickButton(){
        this.filter.push({Id: this.index , valuefield: '' , valueconjuction: '' , valueText: ''});
        this.index++;
        this.filter = [...this.filter];
    }
    filterApply(){
        let value = this.template.querySelector('.con').value;
        if("or" == value.toLowerCase()){
            this.filterData = [];
            this.data.forEach(ele =>{
                if(this.checkOr(ele)){
                    this.filterData.push(ele);
                }
            })
            this.filterData = [...this.filterData];
        }else if("and" == value.toLowerCase()){
            this.filterData = [];
            this.data.forEach(ele =>{
                if(this.checkAnd(ele)){
                    this.filterData.push(ele);
                }
            })
            this.filterData = [...this.filterData];
        }
    }
    changlVlue(event){
        let index = event.target.dataset.object;
        let value = this.template.querySelector(`[data-id="${index}"]`).value;
        this.filter.forEach(ele =>{
            if(ele.Id == index){
                ele.valueText = value;
            }
        })
    }
    checkOr(data){
        try{
            let flag = false;
        this.filter.forEach(ele =>{

            if(ele.valueconjuction == 'equal' && ele.valueText.toString() == data[ele.valuefield].toString()){
                flag = true;
                return true;
            }else if(ele.valueconjuction == 'not equal' && ele.valueText.toString() != data[ele.valuefield].toString()){
                flag = true;
                return true;
            }
        });
        return flag;

        }catch(Err){
            console.log(Err);
        }
        
    }
    checkAnd(data){
        try{
            let flag = false;
        this.filter.forEach(ele =>{
            if(ele.valueconjuction == 'equal' && ele.valueText.toString() == data[ele.valuefield].toString()){
                flag = true;
            }else if(ele.valueconjuction == 'not equal' && ele.valueText.toString() != data[ele.valuefield].toString()){
                flag = true;
            }else {
                return false;
            }
        });
        return flag;
        }catch(Err){
            console.log(Err)
        }
        
    }
    @track sortBy;
    @track sortDirection;
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        try{
            if(direction == "asc" && fieldname == "CreatedDate"){
                let orgi = [ ...this.filterData ];
                let data = orgi.sort((a, b) => {
                    let dateA = new Date(a[fieldname]);
                    let dateB = new Date(b[fieldname]);
                    return dateA - dateB;
                });
                this.filterData = [...data];
            }else if(direction == "desc" && fieldname == "CreatedDate"){
                let orgi = [ ...this.filterData ];
                let data = orgi.sort((a, b) => {
                    let dateA = new Date(a[fieldname]);
                    let dateB = new Date(b[fieldname]);
                    return -(dateA - dateB);
                });
                this.filterData = [...data];
            }
        }catch(err){
            console.log(err);
        }
        
       
    }   

}