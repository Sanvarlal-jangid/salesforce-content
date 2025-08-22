import { LightningElement, wire, track } from 'lwc';
import updateRecord from '@salesforce/apex/getRecordsDapPaper.updateRecord';
import ModalForEditDapPaper from 'c/modalForEditDapPaper'
import getToDoRecords from '@salesforce/apex/getRecordsDapPaper.getToDoRecords';
import getInProgressRecords from '@salesforce/apex/getRecordsDapPaper.getInProgressRecords';
import getCompletedRecords from '@salesforce/apex/getRecordsDapPaper.getCompletedRecords';
import getTestingRecords from '@salesforce/apex/getRecordsDapPaper.getTestingRecords';
import getSingleRecords from '@salesforce/apex/getRecordsDapPaper.getSingleRecords';
import Toast from 'lightning/toast';

export default class DapPaperJune extends LightningElement {
    @track todoRecords;
    @track inProgressRecords;
    @track completedRecords;
    @track testingRecords;
    myMap = new Map();
    connectedCallback() {
        this.addTodo();
        this.addInProgress();
        this.addCompleted();
        this.addtesting()
    }

    taskDragStart(event) {
        const taskId = event.target.id.substr(0, 18);
        this.dropTaskId = taskId;
        let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        draggableElement.classList.add('drag');
        this.handleTaskDrag(taskId);
    }
    handleTaskDrag(taskId) {
        console.log('$$$TEst: ' + taskId);
    }

    handleDragEnter(event) {
        this.cancel(event);
    }
    cancel(event) {
        if (event.stopPropagation)
            event.stopPropagation();
        if (event.preventDefault)
            event.preventDefault();
        return false;
    };


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

    taskDragEnd(event) {
        const taskId = event.target.id.substr(0, 18);
        let draggableElement = this.template.querySelector('[data-id="' + taskId + '"]');
        draggableElement.classList.remove('drag');
    }

    handleDrop(event) {
        this.cancel(event);
        let columnUsed = event.currentTarget.id.split('-')[0];
        let taskNewStatus;
        if (columnUsed.includes('todo')) {
            taskNewStatus = 'To Do';
        } else if (columnUsed.includes('InProgress')) {
            taskNewStatus = 'In Progress';
        } else if (columnUsed.includes('Testing')) {
            taskNewStatus = 'Testing';
        } else if (columnUsed.includes('completed')) {
            taskNewStatus = 'Completed';
        }
        console.log('$$: ' + this.dropTaskId);
        console.log("task", taskNewStatus);
        updateRecord({ recordId: this.dropTaskId, Status: taskNewStatus }).then(res => {
            console.log("Result", res);
            if (res) {
                let obj = this.myMap.get(this.dropTaskId);
                this.handleFilter(obj).then(()=>{
                    obj.Status__c = taskNewStatus;
                    this.addSingleRecord(obj);
                    Toast.show({
                        label: 'Success Transaction',
                        message: 'Successfully changed',
                        mode: 'dismissible',
                        variant: 'success'
                    }, this);
                });
            } else {
                Toast.show({
                    label: 'Failed Transaction',
                    message: 'Failed Change',
                    mode: 'dismissible',
                    variant: 'error'
                }, this);
            }
        })

        let draggableElement = this.template.querySelector('[data-role="drop-target"]');
        draggableElement.classList.remove('over');
    }
    async onclickpencil(event) {
        let id = event.target.dataset.object;
        let status = event.target.dataset.status;
        console.log(status);
        const result = await ModalForEditDapPaper.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: id,
        });
        if (result == 'success') {
            getSingleRecords({ idd: id }).then(res => {
                res = res[0];
                if (res.Status__c == status) {
                    if (res.Status__c == 'Testing') {
                        try {
                            let data = this.testingRecords.map(ele => {
                                if (ele.Id == res.Id) {
                                    return res;
                                } else {
                                    return ele;
                                }
                            })
                            console.log(data);
                            this.testingRecords = data;
                            this.testingRecords = [...this.testingRecords];
                        } catch (err) {
                            console.log(err);
                        }

                    } else if (res.Status__c == 'To Do') {
                        try {
                            let data = this.todoRecords.map(ele => {
                                if (ele.Id == res.Id) {
                                    return res;
                                } else {
                                    return ele;
                                }
                            })
                            console.log(data);
                            this.todoRecords = data;
                            this.todoRecords = [...this.todoRecords];
                        } catch (err) {
                            console.log(err);
                        }
                    } else if (res.Status__c == 'In Progress') {
                        try {
                            let data = this.inProgressRecords.map(ele => {
                                if (ele.Id == res.Id) {
                                    return res;
                                } else {
                                    return ele;
                                }
                            })
                            console.log(data);
                            this.inProgressRecords = data;
                            this.inProgressRecords = [...this.inProgressRecords];
                        } catch (err) {
                            console.log(err);
                        }
                    } else if (res.Status__c == 'Completed') {
                        try {
                            let data = this.completedRecords.map(ele => {
                                if (ele.Id == res.Id) {
                                    return res;
                                } else {
                                    return ele;
                                }
                            })
                            console.log(data);
                            this.completedRecords = data;
                            this.completedRecords = [...this.completedRecords];
                        } catch (err) {
                            console.log(err);
                        }
                    }
                } else {
                    if (status == 'Testing') {
                        try {
                            let data = this.testingRecords.filter(ele => {
                                if (ele.Id != res.Id) {
                                    return true;
                                } else {
                                    return false;
                                }
                            })
                            this.testingRecords = data;
                            this.testingRecords = [...this.testingRecords];
                        } catch (err) {
                            console.log(err)
                        }
                    } else if (status == 'In Progress') {
                        try {
                            let data = this.inProgressRecords.filter(ele => {
                                if (ele.Id != res.Id) {
                                    return true;
                                } else {
                                    return false;
                                }
                            })
                            this.inProgressRecords = data;
                            this.inProgressRecords = [...this.inProgressRecords];
                        } catch (err) {
                            console.log(err)
                        }
                    } else if (status == 'Completed') {
                        try {
                            let data = this.completedRecords.filter(ele => {
                                if (ele.Id != res.Id) {
                                    return true;
                                } else {
                                    return false;
                                }
                            })
                            this.completedRecords = data;
                            this.completedRecords = [...this.completedRecords];
                        } catch (err) {
                            console.log(err)
                        }
                    } else if (status == 'To Do') {
                        try {
                            let data = this.todoRecords.filter(ele => {
                                if (ele.Id != res.Id) {
                                    return true;
                                } else {
                                    return false;
                                }
                            })
                            this.todoRecords = data;
                            this.todoRecords = [...this.todoRecords];
                        } catch (err) {
                            console.log(err)
                        }
                    }
                    this.addSingleRecord(res);
                }
            })
        }
    }

    loadMoreData(event) {
        const element = event.target;
        if (element.scrollHeight - element.scrollTop === element.clientHeight || element.scrollHeight - element.scrollTop - 0.5 === element.clientHeight) {
            if (event.target.dataset.object == 'todo') {
                this.addTodo();
            } else if (event.target.dataset.object == 'inprogress') {
                this.addInProgress();
            } else if ('completed' == event.target.dataset.object) {
                this.addCompleted();
            } else if ('testing' == event.target.dataset.object) {
                this.addtesting();
            }
        }
    }
    todooffest = 0;
    addTodo() {
        getToDoRecords({ offse: this.todooffest }).then(res => {
            let data = this.addBadge(res);
            if (this.todoRecords) {
                this.todoRecords = this.todoRecords.concat(data);
            } else {
                this.todoRecords = data;
            }
        }).catch(err => {
            console.log(err);
        })
        this.todooffest = this.todooffest + 3;
    }
    inprogressoffest = 0;
    addInProgress() {
        getInProgressRecords({ offse: this.inprogressoffest }).then(res => {
            let data = this.addBadge(res);
            if (this.inProgressRecords) {
                this.inProgressRecords = this.inProgressRecords.concat(data);
            } else {
                this.inProgressRecords = data;
            }
        }).catch(err => {
            console.log(err);
        })
        this.inprogressoffest = this.inprogressoffest + 3;
    }
    completedoffest = 0;
    addCompleted() {
        getCompletedRecords({ offse: this.completedoffest }).then(res => {
            let data = this.addBadge(res);
            if (this.completedRecords) {
                this.completedRecords = this.completedRecords.concat(data);
            } else {
                this.completedRecords = data;
            }
        }).catch(err => {
            console.log(err);
        })
        this.completedoffest = this.completedoffest + 3;
    }
    testingoffest = 0;
    addtesting() {
        getTestingRecords({ offse: this.testingoffest , lis: Array.from(this.myMap.keys())}).then(res => {
            let data = this.addBadge(res);
            if (this.testingRecords) {
                this.testingRecords = this.testingRecords.concat(data);
            } else {
                this.testingRecords = data;
            }
        }).catch(err => {
            console.log(err);
        })
        this.testingoffest = this.testingoffest + 3;
    }
    addBadge(data) {
        let copyData = JSON.parse(JSON.stringify(data));
        copyData.forEach(element => {
            if (element.Priority__c == 'Low') {
                element.isGreen = true;
            } else if (element.Priority__c == 'Medium') {
                element.isYellow = true;
            } else if (element.Priority__c == 'High') {
                element.isRed = true;
            }
            this.myMap.set(element.Id, element);
        })
        return copyData;
    }

    addSingleRecord(data) {
        try{
            if (data.Status__c == 'In Progress') {
                this.inProgressRecords.push(data);
            } else if (data.Status__c == 'To Do') {
                this.todoRecords.push(data);
            } else if (data.Status__c == 'Testing') {
                this.testingRecords.push(data);
            } else if (data.Status__c == 'Completed') {
                this.completedRecords.push(data);
            }
        }catch(err){
            console.log(err);
        }
        
    }

    async handleFilter(obj){
        if (obj.Status__c == 'Completed') {
            this.completedRecords = this.completedRecords.filter(ele => {
                if (ele.Id == obj.Id) {
                    return false;
                } else {
                    return true;
                }
            })
            this.completedRecords = [...this.completedRecords];
        } else if (obj.Status__c == 'To Do') {
            this.todoRecords = this.todoRecords.filter(ele => {
                if (ele.Id == obj.Id) {
                    return false;
                } else {
                    return true;
                }
            })
            this.todoRecords = [...this.todoRecords];
        } else if (obj.Status__c == 'In Progress') {
            this.inProgressRecords = this.inProgressRecords.filter(ele => {
                if (ele.Id == obj.Id) {
                    return false;
                } else {
                    return true;
                }
            })
            this.inProgressRecords = [...this.inProgressRecords];
        } else if (obj.Status__c == 'Testing') {
            this.testingRecords = this.testingRecords.filter(ele => {
                if (ele.Id == obj.Id) {
                    return false;
                } else {
                    return true;
                }
            })
            this.testingRecords = [...this.testingRecords];
        }
    }

}