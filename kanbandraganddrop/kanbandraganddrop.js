import { LightningElement, track, wire } from 'lwc';
//import updateTaskStatus from '@salesforce/apex/DragAndDropComponentHandler.updateTaskStatus';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllopportunity from '@salesforce/apex/kanbandraganddrop.getAllopportunity';
import updateoppStatus from '@salesforce/apex/kanbandraganddrop.updateoppStatus';


export default class kanbandraganddrop extends NavigationMixin(LightningElement) {
    @track prospectingList = [];
    @track QualificationList = [];
    @track proposalList = [];
    @track ClosedwonList = [];
    @track ClosedLostList = [];

    @track AllprospectingList = [];
    @track AllQualificationList = [];
    @track AllproposalList = [];
    @track AllClosedwonList = [];
    @track AllClosedLostList = [];
    @track dropTaskId;
    accountsResult;

    BATCH_SIZE = 5;

    @track offsets = {
        Prospecting: 0,
        Qualification: 0,
        Proposal: 0,
        ClosedWon: 0,
        ClosedLost: 0
    };

    @track allDone = {
        ToDo: false,
        InProgress: false,
        Completed: false,
        Testing: false
    };
    connectedCallback() {
        // this.loadopp('Prospecting');
        // this.loadopp('Qualification');
        // this.loadopp('Proposal/Price Quote');
        // this.loadopp('Closed Won');
        // this.loadopp('Closed Lost');

    }

    //      loadTasks(status) {
    //     if (this.allDone[this.mapStatusToKey(status)]) return;

    //     getPaginatedTasks({ status: status, offsetVal: this.offsets[this.mapStatusToKey(status)],limitSize:BATCH_SIZE
    //     })
    //     .then(result => {
    //         if (!result || result.length === 0) {
    //             this.allDone[this.mapStatusToKey(status)] = true;
    //             return;
    //         }

    //         const tasks = result.map(task => ({
    //             Id: task.Id,
    //             Name: task.Name,
    //             Assigned_To: task.Assigned_To__r && task.Assigned_To__r.Name ? task.Assigned_To__r.Name : '',
    //             Project: task.Project__r && task.Project__r.Name ? task.Project__r.Name : '',
    //             Due_Date__c: task.Due_Date__c,
    //             Priority__c: task.Priority__c,
    //             Status: task.Status__c,
    //             PriorityClass: this.getPriorityClass(task.Priority__c)
    //         }));

    //         this.offsets[this.mapStatusToKey(status)] += result.length;

    //         if (status === 'To Do') {
    //             this.tasktodoList = [...this.tasktodoList, ...tasks];
    //         } else if (status === 'In Progress') {
    //             this.taskInProgressList = [...this.taskInProgressList, ...tasks];
    //         } else if (status === 'Completed') {
    //             this.taskCompletedList = [...this.taskCompletedList, ...tasks];
    //         } else if (status === 'Testing') {
    //             this.taskintestingList = [...this.taskintestingList, ...tasks];
    //         }
    //     })
    //     .catch(error => {
    //         this.showToast('Error', 'Failed to load tasks: ' + error.body.message, 'error');
    //     });
    // }
    @wire(getAllopportunity)
    opp(result) {
        this.accountsResult = result;
        if (result.data) {
            this.getopportunity(result.data);
        } else if (result.error) {
            console.log('error', result.error);
        }

    }

    getopportunity(result) {

        console.log('result', result);
        let prospectingData = [];
        let qualificationData = [];
        let proposalData = [];
        let ClosedwonData = [];
        let ClosedLostData = [];
        for (let i = 0; i < result.length; i++) {
            let opp = new Object();
            opp.Id = result[i].Id;
            opp.Name = result[i].Name;
            opp.StageName = result[i].StageName;
            opp.Amount = result[i].Amount;


            if (opp.StageName === 'Prospecting') {
                prospectingData.push(opp);
            } else if (opp.StageName === 'Qualification') {
                qualificationData.push(opp);
            } else if (opp.StageName === 'Proposal/Price Quote') {
                proposalData.push(opp);
            } else if (opp.StageName === 'Closed Won') {
                ClosedwonData.push(opp);
            }
            else if (opp.StageName === 'Closed Lost') {
                ClosedLostData.push(opp);
            }

        }

        this.AllprospectingList = prospectingData;
        this.AllQualificationList = qualificationData;
        this.AllproposalList = proposalData;
        this.AllClosedwonList = ClosedwonData;
        this.AllClosedLostList = ClosedLostData;

        this.prospectingList = this.AllprospectingList.slice(0, 5);
        this.QualificationList = this.AllQualificationList.slice(0, 5);
        this.proposalList = this.AllproposalList.slice(0, 5);
        this.ClosedwonList = this.AllClosedwonList.slice(0, 5);
        this.ClosedLostList = this.AllClosedLostList.slice(0, 5);

    }

    taskDragStart(event) {
        const taskId = event.target.dataset.id;
        event.dataTransfer.setData('text/plain', taskId);
        // const taskId = event.target.id.substr(0, 18);
        // //window.alert(taskId);
        // this.dropTaskId = taskId;
        // let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        // draggableElement.classList.add('drag');
        // this.handleTaskDrag(taskId);
    }

    taskDragEnd(event) {
        // const taskId = event.target.id.substr(0, 18);
        // //window.alert(taskId);
        // let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        // draggableElement.classList.remove('drag');
    }

    handleDrop(event) {
        this.cancel(event);

        const taskId = event.dataTransfer.getData('text/plain');
        const columnUsed = event.currentTarget.dataset.id;

        // Find current status of dragged task
        const allopps = [
            ...this.prospectingList,
            ...this.QualificationList,
            ...this.proposalList,
            ...this.ClosedwonList,
            this.ClosedLostList,
        ];
        const draggedopp = allopps.find(task => task.Id === taskId);
        const currentStatus = draggedopp?.StageName;

        let taskNewStatus;
        if (columnUsed.includes('Prospecting')) {
            console.log('Prospecting or not');
            taskNewStatus = 'Prospecting';
        } else if (columnUsed.includes('Qualification')) {
            console.log('Qualification or not');
            taskNewStatus = 'Qualification';
        } else if (columnUsed.includes('Proposal')) {
            taskNewStatus = 'Proposal/Price Quote';
        } else if (columnUsed.includes('ClosedWon')) {
            taskNewStatus = 'Closed Won';
        }
        else if (columnUsed.includes('ClosedLost')) {
            taskNewStatus = 'Closed Lost';
        }
        //window.alert(columnUsed + ' & '+ taskNewStatus);
        updateoppStatus({ taskId, taskNewStatus })
            .then(data => {
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                return refreshApex(this.accountsResult);

            })
            .catch(error => {
                console.error(error);
            });



        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.remove('over');
    }

    handleDragEnter(event) {
        this.cancel(event);
    }

    handleDragOver(event) {
        this.cancel(event);
        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.add('over');
    }

    handleDragLeave(event) {
        this.cancel(event);
        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.remove('over');
    }

    handleTaskDrag(taskId) {
        console.log('$$$TEst: ' + taskId);
    }

    //    async updteTaskStatus(taskId, taskNewStatus){
    //         console.log('update krna h ',taskId,taskNewStatus);

    //          const result = await updateTaskStatus({ taskId: taskId, newStatus: taskNewStatus });
    //                     if (result === 'Success') {
    //                         this.getTaskData();
    //                         refreshApex(this.accountsResult);
    //                     }else{
    //                         console.log('error aa gyil babu');
    //                     }
    //     }

    cancel(event) {
        if (event.stopPropagation) event.stopPropagation();
        if (event.preventDefault) event.preventDefault();
        return false;
    };
    handleEditClick(event) {
        let recordId = event.currentTarget.dataset.id;
        console.log('record id', recordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Opportunity',
                actionName: 'edit'
            }
        });


    }

    handledeleteClick(event) {
        let selectedid = event.currentTarget.dataset.id;
        console.log('delete krna h ', selectedid);


        deleteRecord(selectedid)
            .then(() => {
                // Show success toast
                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);

                // Refresh the data displayed in the component
                return refreshApex(this.accountsResult);
            })
            .catch(error => {
                // Show error toast
                const toastEvent = new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            });
    }






    mapStatusToKey(status) {
        return status.replace(/\s/g, '');
    }

    mapKeyToStatus(key) {
        if (key === 'ToDo') return 'To Do';
        if (key === 'InProgress') return 'In Progress';
        return key;
    }
    resetAll() {
        this.tasktodoList = [];
        this.taskInProgressList = [];
        this.taskCompletedList = [];
        this.taskintestingList = [];
        this.offsets = { ToDo: 0, InProgress: 0, Completed: 0, Testing: 0 };
        this.allDone = { ToDo: false, InProgress: false, Completed: false, Testing: false };
        this.connectedCallback();
    }

    handleScroll(event) {
        try{
            console.log('handlescroll run');
            const columnKey = event.currentTarget.dataset.id;
            const el = event.target;
                 if (el.scrollTop + el.clientHeight >= el.scrollHeight - 10) {
                        console.log('inside if confion');
                        console.log('convert into string',columnKey);
                       this.loaddata(columnKey);
                       console.log('load data called');
                  }
        }catch (e){
            console.log('error',e.message);
        }
       
    }

loaddata(columnKey) {
    console.log('loaddata run');
    console.log('columnKey:', columnKey);

    let currentList = [];
    let allData = [];
    let newList = [];

    switch (columnKey) {
        case 'Prospecting':
            currentList = this.prospectingList || [];
            allData = this.AllprospectingList || [];
            break;
        case 'Qualification':
            currentList = this.QualificationList || [];
            allData = this.AllQualificationList || [];
            break;
        case 'Proposal':
            currentList = this.ProposalList || [];
            allData = this.AllproposalList || [];
            break;
        case 'ClosedWon':
            currentList = this.ClosedwonList || [];
            allData = this.AllClosedwonList || [];
            break;
        case 'ClosedLost':
            currentList = this.ClosedLostList || [];
            allData = this.AllClosedLostList || [];
            break;
        default:
            console.warn('Unknown columnKey:', columnKey);
            return;
    }

    console.log("Current list length:", currentList.length);
    console.log("All data length:", allData.length);


    if (currentList.length >= allData.length) {
        console.log('All data already loaded for', columnKey);
        return;
    }


    const startIndex = currentList.length;
    const endIndex = startIndex + 3;
    newList = allData.slice(startIndex, endIndex);

    console.log("New data to add:", newList);

   
    switch (columnKey) {
        case 'Prospecting':
            this.prospectingList = [...currentList, ...newList];
            console.log('Updated Prospecting List:', this.prospectingList);
            break;
        case 'Qualification':
            this.QualificationList = [...currentList, ...newList];
            console.log('Updated Qualification List:', this.QualificationList);
            break;
        case 'Proposal':
            this.ProposalList = [...currentList, ...newList];
            console.log('Updated Proposal List:', this.ProposalList);
            break;
        case 'ClosedWon':
            this.ClosedwonList = [...currentList, ...newList];
            console.log('Updated ClosedWon List:', this.ClosedwonList);
            break;
        case 'ClosedLost':
            this.ClosedLostList = [...currentList, ...newList];
            console.log('Updated ClosedLost List:', this.ClosedLostList);
            break;
    }
}


// loaddata(columnKey) {
//     console.log('loaddata run');
//     console.log('columnKey', columnKey === 'ClosedWon' , columnKey == 'ClosedLost');

//     let listToUpdate;
//     let currentList =[];
//     let newList;
//       let allData;
    
    
//     if (columnKey == 'Prospecting') {
//         currentList = this.prospectingList;
//          allData = this.AllprospectingList;
//     } else if (columnKey == 'Qualification') {
//         currentList = this.QualificationList;
//          allData = this.AllQualificationList;
//     } else if (columnKey == 'Proposal') {
//         allData = this.AllproposalList;
//         currentList = this.ProposalList;
//     } else if (columnKey === 'ClosedWon') {
//         console.log("here");
//         allData = this.AllClosedwonList;
//         currentList.push(this.ClosedwonList);
//         console.log(allData , this.ClosedwonList , val ,  allData);
//     } else if (columnKey == 'ClosedLost') {

//         allData = this.AllClosedLostList;
//         currentList = this.ClosedLostList;
//     } else {
//         return; 
//     }


//     console.log("current list",currentList ,  currentList.length ,  allData.length, currentList.length == allData.length);
//     if(currentList.length == allData.length){
//         return;
//     }

   
//     const startIndex = currentList.length;
//     const endIndex = startIndex + 3; 
    
 
    
//     newList = allData.slice(startIndex, endIndex);
//     console.log("new list ", newList)

   
//     if (columnKey == 'Prospecting') {
//         this.prospectingList = [...currentList, ...newList];
//         console.log('inside prospecting', this.prospectingList);
//     } else if (columnKey == 'Qualification') {
//         this.QualificationList = [...currentList, ...newList];
//         console.log('inside Qualification', this.QualificationList);
//     } else if (columnKey == 'Proposal') {
//         this.ProposalList = [...currentList, ...newList];
//         console.log('inside Proposal', this.ProposalList);
//     } else if (columnKey === 'ClosedWon') {
//         console.log("inssig")
//         //this.ClosedWonList = [...currentList, ...newList];
    
//         this.ClosedwonList.push(newList);
//         this.ClosedwonList = [...this.ClosedwonList];

//         console.log('inside ClosedWon', this.ClosedWonList);
        
//     } else if (columnKey == 'ClosedLost') {
//         this.ClosedLostList = [...currentList, ...newList];
//         console.log('inside ClosedLost', this.ClosedLostList);
//     }else {
//         return; 
//     } 
// }


}