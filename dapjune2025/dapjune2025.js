import { LightningElement, track, wire } from 'lwc'; // Added 'wire'
import getAllTasks from '@salesforce/apex/DragAndDropComponentHandler.getAllTasks';
import updateTaskStatus from '@salesforce/apex/DragAndDropComponentHandler.updateTaskStatus';
import saveTask from '@salesforce/apex/DragAndDropComponentHandler.saveTask';
import getTaskDetailsFieldSetFields from '@salesforce/apex/DragAndDropComponentHandler.getTaskDetailsFieldSetFields'; // New import
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KanbanBoard extends LightningElement {
    @track tasks = {
        todo: [],
        inProgress: [],
        testing: [],
        completed: []
    };

    @track selectedTask = {};
    @track isModalOpen = false;
    @track clientValidationError = '';
    @track isSaving = false;
    @track fieldSetFields = []; 

    @wire(getTaskDetailsFieldSetFields)
    wiredFieldSetFields({ error, data }) {
        if (data) {
            // Map the field names to objects with fieldName property for lightning-input-field
            // You can add 'required: true' if a field is explicitly mandatory in the field set or on the object.
            this.fieldSetFields = data.map(fieldName => ({ fieldName: fieldName, required: false }));
            // Optionally, set 'required: true' for specific known fields like Task_Name__c
            this.fieldSetFields = this.fieldSetFields.map(field => {
                if (field.fieldName === 'Task_Name__c') {
                    return { ...field, required: true };
                }
                return field;
            });
        } else if (error) {
            this.showNotification('Error', 'Error loading field set fields: ' + error.body.message, 'error');
            console.error('Error loading field set fields:', error);
        }
    }

    connectedCallback() {
        this.loadAllTasks();
    }

    // Helper to show Lightning Toast Notifications
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    // Loads all tasks at once and categorizes them by status
    async loadAllTasks() {
        try {
            const result = await getAllTasks();
            let todoData = [];
            let inProgressData = [];
            let testingData = [];
            let completedData = [];

            result.forEach(task => {
                const processedTask = { ...task };
                processedTask.formattedDueDate = this.getFormattedDueDate(processedTask.Due_Date__c);
                processedTask.priorityClass = this.getPriorityClass(processedTask.Priority__c);

                switch (processedTask.Status__c) {
                    case 'To Do':
                        todoData.push(processedTask);
                        break;
                    case 'In Progress':
                        inProgressData.push(processedTask);
                        break;
                    case 'Testing':
                        testingData.push(processedTask);
                        break;
                    case 'Completed':
                        completedData.push(processedTask);
                        break;
                    default:
                        // Handle unassigned status or log it
                        break;
                }
            });

            this.tasks.todo = this.sortTasksByDueDate(todoData);
            this.tasks.inProgress = this.sortTasksByDueDate(inProgressData);
            this.tasks.testing = this.sortTasksByDueDate(testingData);
            this.tasks.completed = this.sortTasksByDueDate(completedData);

        } catch (error) {
            this.showNotification('Error', 'Error fetching tasks: ' + error.body.message, 'error');
            console.error('Error fetching tasks:', error);
        }
    }

    // Sort tasks by Due Date (ascending)
    sortTasksByDueDate(tasksArray) {
        return [...tasksArray].sort((a, b) => {
            const dateA = new Date(a.Due_Date__c);
            const dateB = new Date(b.Due_Date__c);
            return dateA - dateB;
        });
    }

    // Helper to format date for display on the card
    getFormattedDueDate(dateString) {
        if (dateString) {
            const date = new Date(dateString);
            return new Intl.DateTimeFormat('en-US', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(date);
        }
        return '';
    }

    // Helper to get priority CSS class for the card
    getPriorityClass(priority) {
        if (priority) {
            switch (priority) {
                case 'High':
                    return 'priority-badge priority-high';
                case 'Medium':
                    return 'priority-badge priority-medium';
                case 'Low':
                    return 'priority-badge priority-low';
                default:
                    return 'priority-badge';
            }
        }
        return 'priority-badge';
    }


    // Drag and Drop Handlers
    handleDragStart(event) {
        const taskId = event.currentTarget.dataset.id;
        const taskStatus = event.currentTarget.dataset.status;
        event.dataTransfer.setData('taskid', taskId);
        event.dataTransfer.setData('originalstatus', taskStatus);
        event.currentTarget.classList.add('dragging');
    }

    handleDragOver(event) {
        event.preventDefault();
        const column = event.currentTarget;
        column.classList.add('over');
    }

    handleDragEnter(event) {
        event.preventDefault();
    }

    handleDragLeave(event) {
        const column = event.currentTarget;
        column.classList.remove('over');
    }

    async handleDrop(event) {
        event.preventDefault();
        const taskId = event.dataTransfer.getData('taskid');
        const originalStatus = event.dataTransfer.getData('originalstatus');
        const newStatus = event.currentTarget.dataset.status;

       console.log(event.dataTransfer.getData('taskid'));
       console.log(event.dataTransfer.getData('originalstatus'));
       console.log(event.currentTarget.dataset.status);
        if (!taskId || originalStatus === newStatus) {
            return;
        }

        // Client-side validation for status transitions (can be expanded)
        if (!this.isValidTransition(originalStatus, newStatus)) {
            this.showNotification('Invalid Transition', `Cannot move task directly from '${originalStatus}' to '${newStatus}'.`, 'error');
            return;
        }

        try {
            const result = await updateTaskStatus({ taskId: taskId, newStatus: newStatus });
            if (result === 'Success') {
                this.showNotification('Success', 'Task status updated successfully!', 'success');
                this.loadAllTasks(); // Reload all tasks after successful update
            } else {
                this.showNotification('Error', 'Failed to update task status: ' + result, 'error');
            }
        } catch (error) {
            this.showNotification('Error', 'Error updating task status: ' + error.body.message, 'error');
            console.error('Error updating task status:', error);
        }
    }

    // Basic client-side validation logic for status transitions
    isValidTransition(oldStatus, newStatus) {
        if (oldStatus === 'To Do' && newStatus === 'Completed') {
            return false; // Prevent direct 'To Do' to 'Completed'
        }
        return true;
    }


    // Modal Handlers
    handleCardClick(event) {
        const taskId = event.currentTarget.dataset.id;
        const taskStatus = event.currentTarget.dataset.status;
        const statusKey = taskStatus.toLowerCase().replace(/\s/g, '');
        const task = this.tasks[statusKey].find(t => t.Id === taskId);

        if (task) {
            this.selectedTask = { ...task };
            this.isModalOpen = true;
            this.clientValidationError = '';
        }
    }

    handleEditIconClick(event) {
        event.stopPropagation(); // Prevent parent card click
        const taskId = event.currentTarget.dataset.id;
        let foundTask = null;
        for (const key in this.tasks) {
            if (this.tasks.hasOwnProperty(key)) {
                foundTask = this.tasks[key].find(t => t.Id === taskId);
                if (foundTask) break;
            }
        }

        if (foundTask) {
            this.selectedTask = { ...foundTask };
            this.isModalOpen = true;
            this.clientValidationError = '';
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedTask = {};
        this.clientValidationError = '';
        this.isSaving = false;
    }

    // Handles changes in modal input fields (now dynamically from fieldSetFields)
    handleFieldChange(event) {
        const fieldName = event.target.dataset.field; // Using data-field attribute
        let value = event.target.value;

        // Special handling for Lookup fields (lightning-input-field returns array of IDs)
        if (event.target.type === 'lookup' && Array.isArray(value)) {
            value = value.length > 0 ? value[0] : null;
        }

        this.selectedTask = { ...this.selectedTask, [fieldName]: value };

        // Client-side validation for Task Name (adjust as needed based on fieldSetFields)
        if (fieldName === 'Task_Name__c' && (value === null || value.trim() === '')) {
            this.clientValidationError = 'Task Name cannot be empty.';
        } else {
            this.clientValidationError = '';
        }
    }

    async handleModalSave() {
        if (this.clientValidationError) {
            return;
        }
        if (!this.selectedTask.Task_Name__c || this.selectedTask.Task_Name__c.trim() === '') {
            this.clientValidationError = 'Task Name cannot be empty.';
            return;
        }

        this.isSaving = true;
        try {
            const result = await saveTask({ taskToSave: this.selectedTask });
            if (result === 'Success') {
                this.showNotification('Success', 'Task saved successfully!', 'success');
                this.closeModal();
                this.loadAllTasks(); // Reload all tasks after save
            } else {
                this.showNotification('Error', 'Failed to save task: ' + result, 'error');
                this.clientValidationError = result;
            }
        } catch (error) {
            this.showNotification('Error', 'Error saving task: ' + error.body.message, 'error');
            this.clientValidationError = error.body.message;
            console.error('Error saving task:', error);
        } finally {
            this.isSaving = false;
        }
    }
}