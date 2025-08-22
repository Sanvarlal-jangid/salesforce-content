import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllTasks from '@salesforce/apex/DragAndDropComponentHandler.getAllTasks';
import updateTaskStatus from '@salesforce/apex/DragAndDropComponentHandler.updateTaskStatus';

export default class DragAndDropComponent extends LightningElement {
    @track tasktodoList = [];
    @track taskInProgressList = [];
    @track taskCompletedList = [];
    @track taskintestingList = [];

    taskWireResult; // for refreshApex

    @wire(getAllTasks)
    wiredTasks(result) {
        this.taskWireResult = result;
        if (result.data) {
            console.log('whole result',result.data);
            this.splitTasks(result.data);
        } else if (result.error) {
            this.showToast('Error', 'Failed to load tasks', 'error');
        }
    }

    splitTasks(data) {
        let taskNewData = [];
        let taskInProgressData = [];
        let taskCompletedData = [];
        let tasktestingData = [];

        for (let i = 0; i < data.length; i++) {
            let task = {
                Id: data[i].Id,
                Name: data[i].Name,
                Status: data[i].Status__c,
                Due_Date__c: data[i].Due_Date__c,
                Priority__c: data[i].Priority__c
            };

            if (data[i].Assigned_To__c) {
                task.Assigned_To = data[i].Assigned_To__r.Name;
            }
            if (data[i].Project__c !== undefined) {
                task.Project = data[i].Project__r?.Name;
            }

            if (task.Priority__c === 'High') {
                task.PriorityClass = 'priority-high';
            } else if (task.Priority__c === 'Medium') {
                task.PriorityClass = 'priority-medium';
            } else if (task.Priority__c === 'Low') {
                task.PriorityClass = 'priority-low';
            }

            if (task.Status === 'To Do') {
                taskNewData.push(task);
            } else if (task.Status === 'In Progress') {
                taskInProgressData.push(task);
            } else if (task.Status === 'Completed') {
                taskCompletedData.push(task);
            } else if (task.Status === 'Testing') {
                tasktestingData.push(task);
            }
        }

        this.tasktodoList = taskNewData;
        console.log('taskNewData',JSON.stringify(this.tasktodoList));
        this.taskInProgressList = taskInProgressData;
        console.log('taskInProgressData',this.taskInProgressList);
        this.taskCompletedList = taskCompletedData;
        console.log('taskCompletedData',this.taskCompletedList);
        this.taskintestingList = tasktestingData;
        console.log('tasktestingData',this.taskintestingList);
    }

    taskDragStart(event) {
        const taskId = event.target.dataset.id;
        event.dataTransfer.setData('text/plain', taskId);
    }

    taskDragEnd(event) {
        // optional: cleanup visual if needed
    }

   handleDrop(event) {
    this.cancel(event);

    const taskId = event.dataTransfer.getData('text/plain');
    const columnUsed = event.currentTarget.dataset.id;

    // Find current status of dragged task
    const allTasks = [
        ...this.tasktodoList,
        ...this.taskInProgressList,
        ...this.taskCompletedList,
        ...this.taskintestingList
    ];
    const draggedTask = allTasks.find(task => task.Id === taskId);
    const currentStatus = draggedTask?.Status;

    let taskNewStatus;
    if (columnUsed === 'InProgress') {
        taskNewStatus = 'In Progress';
    } else if (columnUsed === 'ToDo') {
        taskNewStatus = 'To Do';
    } else if (columnUsed === 'Testing') {
        taskNewStatus = 'Testing';
    } else if (columnUsed === 'Completed') {
        taskNewStatus = 'Completed';
    }

    //  Validation: prevent To Do → Completed
    if (currentStatus === 'To Do' && taskNewStatus === 'Completed') {
        this.showToast('Invalid Move', 'You cannot move task directly from To Do to Completed.', 'error');
        event.currentTarget.classList.remove('over');
        return;
    }

    if (taskId && taskNewStatus) {
        this.updteTaskStatus(taskId, taskNewStatus);
    }

    event.currentTarget.classList.remove('over');
}


    handleDragEnter(event) {
        this.cancel(event);
    }

    handleDragOver(event) {
        this.cancel(event);
        event.currentTarget.classList.add('over');
    }

    handleDragLeave(event) {
        this.cancel(event);
        event.currentTarget.classList.remove('over');
    }

    async updteTaskStatus(taskId, taskNewStatus) {
        const result = await updateTaskStatus({ taskId: taskId, newStatus: taskNewStatus });
        if (result === 'Success') {
            await refreshApex(this.taskWireResult);
            this.showToast('Success', 'Task status updated successfully.', 'success');
        } else {
            this.showToast('Error', result, 'error');
        }
    }

    cancel(event) {
        event.preventDefault();
        event.stopPropagation();
    }

@track isModalOpen = false;
@track selectedTaskId;

handleEditClick(event) {
    const taskId = event.currentTarget.dataset.id;
    this.selectedTaskId = taskId;
    this.isModalOpen = true;
}

handleCancelModal() {
    this.isModalOpen = false;
}

handleModalSuccess() {
    this.showToast('Success', 'Task updated successfully', 'success');
    this.isModalOpen = false;
    refreshApex(this.taskWireResult);
}

handleModalError(event) {
    this.showToast('Error', event.detail.message, 'error');
}


    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}