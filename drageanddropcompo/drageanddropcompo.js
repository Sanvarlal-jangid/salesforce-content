import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPaginatedTasks from '@salesforce/apex/DragAndDropComponentHandler.getPaginatedTasks';
import updateTaskStatus from '@salesforce/apex/DragAndDropComponentHandler.updateTaskStatus';

const BATCH_SIZE = 3;

export default class DragAndDropComponent extends LightningElement {
    @track tasktodoList = [];
    @track taskInProgressList = [];
    @track taskCompletedList = [];
    @track taskintestingList = [];

    @track offsets = {
        ToDo: 0,
        InProgress: 0,
        Completed: 0,
        Testing: 0
    };

    @track allDone = {
        ToDo: false,
        InProgress: false,
        Completed: false,
        Testing: false
    };

    showModal = false;
    selectedRecordId;

    connectedCallback() {
        this.loadTasks('To Do');
        this.loadTasks('In Progress');
        this.loadTasks('Completed');
        this.loadTasks('Testing');
    }

   loadTasks(status) {
    if (this.allDone[this.mapStatusToKey(status)]) return;

    getPaginatedTasks({
        status: status,
        offsetVal: this.offsets[this.mapStatusToKey(status)],
        limitSize: BATCH_SIZE
    })
    .then(result => {
        if (!result || result.length === 0) {
            this.allDone[this.mapStatusToKey(status)] = true;
            return;
        }

        const tasks = result.map(task => ({
            Id: task.Id,
            Name: task.Name,
            Assigned_To: task.Assigned_To__r && task.Assigned_To__r.Name ? task.Assigned_To__r.Name : '',
            Project: task.Project__r && task.Project__r.Name ? task.Project__r.Name : '',
            Due_Date__c: task.Due_Date__c,
            Priority__c: task.Priority__c,
            Status: task.Status__c,
            PriorityClass: this.getPriorityClass(task.Priority__c)
        }));

        this.offsets[this.mapStatusToKey(status)] += result.length;

        if (status === 'To Do') {
            this.tasktodoList = [...this.tasktodoList, ...tasks];
        } else if (status === 'In Progress') {
            this.taskInProgressList = [...this.taskInProgressList, ...tasks];
        } else if (status === 'Completed') {
            this.taskCompletedList = [...this.taskCompletedList, ...tasks];
        } else if (status === 'Testing') {
            this.taskintestingList = [...this.taskintestingList, ...tasks];
        }
    })
    .catch(error => {
        this.showToast('Error', 'Failed to load tasks: ' + error.body.message, 'error');
    });
}


    handleScroll(event) {
        const columnKey = event.currentTarget.dataset.id;
        const el = event.target;
        if (el.scrollTop + el.clientHeight >= el.scrollHeight - 10) {
            const status = this.mapKeyToStatus(columnKey);
            this.loadTasks(status);
        }
    }

    taskDragStart(event) {
        event.dataTransfer.setData('text/plain', event.target.dataset.id);
    }

    taskDragEnd(event) {
        // Optional cleanup
    }

    handleDrop(event) {
        this.cancel(event);

        const taskId = event.dataTransfer.getData('text/plain');
        const columnKey = event.currentTarget.dataset.id;
        const newStatus = this.mapKeyToStatus(columnKey);

        const allTasks = [...this.tasktodoList, ...this.taskInProgressList, ...this.taskCompletedList, ...this.taskintestingList];
        const draggedTask = allTasks.find(task => task.Id === taskId);
        const oldStatus = draggedTask?.Status;

        if (oldStatus === 'To Do' && newStatus === 'Completed') {
            this.showToast('Invalid Move', 'Cannot move directly from To Do to Completed', 'error');
            return;
        }

        updateTaskStatus({ taskId, newStatus })
            .then(result => {
                if (result === 'Success') {
                    this.resetAll();
                    this.showToast('Success', 'Task status updated', 'success');
                } else {
                    this.showToast('Error', result, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
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

    cancel(event) {
        event.preventDefault();
        event.stopPropagation();
    }

    handleEditClick(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleSaveSuccess() {
        this.showToast('Success', 'Task updated successfully', 'success');
        this.showModal = false;
        this.resetAll();
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

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    mapStatusToKey(status) {
        return status.replace(/\s/g, '');
    }

    mapKeyToStatus(key) {
        if (key === 'ToDo') return 'To Do';
        if (key === 'InProgress') return 'In Progress';
        return key;
    }

    getPriorityClass(priority) {
        if (priority === 'High') return 'priority-high';
        if (priority === 'Medium') return 'priority-medium';
        if (priority === 'Low') return 'priority-low';
        return '';
    }
}