import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import updateRecordViaEditModal from '@salesforce/apex/getRecordsDapPaper.updateRecordViaEditModal';

export default class ModalForEditDapPaper extends LightningModal {
    @api content;
    fileds = [ 
        { 
            name: 'Task_Name__c'
        },{ 
            name: 'Status__c'
        }
    ]

    cancelClick() {
        this.close('cancel');
    }
    onclicksave(event){
        let value = this.template.querySelector('.taskname').value;
        let status = this.template.querySelector('.status').value;
        let assigendto = this.template.querySelector('.assigendto').value;
        let duedate = this.template.querySelector('.duedate').value;
        let priority = this.template.querySelector('.priority').value;
        let project = this.template.querySelector('.project').value;
        if(value == null || value == ''){
            event.preventDefault();
        }else if(status == null || status == ''){
            event.preventDefault();
        }else if(assigendto == null || assigendto == ''){
            event.preventDefault();
        }else if(duedate == null || duedate == ''){
            event.preventDefault();
        }else if(priority == null || priority == ''){
            event.preventDefault();
        }else if(project == null || project == ''){
            event.preventDefault();
        }else{
            event.preventDefault();
            updateRecordViaEditModal({
                recordId: this.content,
                taskname: value,
                status: status,
                assigendto: assigendto,
                duedate: duedate,
                priority: priority,
                project: project
            }).then(res=>{
                if(res){
                    this.close('success');
                }else {
                    this.close('failure');
                }
            }).catch(error=>{
                this.close('failure');
            })
        }
    }
}