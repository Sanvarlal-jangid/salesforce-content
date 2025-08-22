import { LightningElement, wire, track } from 'lwc';
import getorder from '@salesforce/apex/datefilterintable.getorders'
import { loadStyle } from 'lightning/platformResourceLoader';
import COLORS from '@salesforce/resourceUrl/myCustomStyles'

export default class Filterdatedatatable extends LightningElement {
    columns = [
        { label: 'Order Id', fieldName: 'OrderNumber',sortable: "true" },
        { label: 'Order Date', fieldName: 'EffectiveDate',sortable: "true" },
        { label: 'Amount', fieldName: 'TotalAmount' },
        { label: 'Account Name', fieldName: 'AccountName' ,sortable: "true"},
        {
            label: 'Status', fieldName: 'Status__c', cellAttributes: {
                class: { fieldName: 'statusClass' }
            }
        }
    ];
    showdatemodal = false;
    toggleDropdown(event){
        this.showdatemodal = true;
    }
    
    dateRangeOptions = [
        { label: 'Today', value: 'today' },
        { label: 'Last 7 days', value: 'last7Days' },
        { label: 'Last 30 days', value: 'last30Days' },
        { label: 'Last 90 days', value: 'last90Days' },
        { label: 'Custom date', value: 'customDate' }
    ];

    @track selectedDateRange = '';
    @track fromDate = '';
    @track toDate = ''; 
    @track showCustomDateInputs = false;
    @track currentFilterFromDate = null;
    @track currentFilterToDate = null;

handleDateRangeChange(event) {
        this.selectedDateRange = event.detail.value;
        this.showCustomDateInputs = (this.selectedDateRange === 'customDate');
        this.updateApplyButtonState();
    }

    handleCustomDateChange(event) {
        const field = event.target.name;
        const value = event.target.value;

        if (field === 'fromDate') {
            this.fromDate = value;
        } else if (field === 'toDate') {
            this.toDate = value;
        }
        this.updateApplyButtonState();
    }

   get isApplyDisabled() {
        if (this.selectedDateRange === 'customDate') {
            return !this.fromDate || !this.toDate;
        }
        return false;
    }
      updateApplyButtonState() { /* Reactive getter handles this */ }

    @track allorders;

    @track paginatedData = [];
    currentPage = 1;
    pageSize = 5;
    totalPages = 0;
    searchKey=''
       @track sortBy;
    @track sortDirection;

    @wire(getorder)
    wiredata({ data, error }) {
        if (data) {
            console.log('orders is coming', data);
            this.allorders = data.map(record => {

                  let statusColor;

                if (record.Status__c === 'Order Picked up') {
                    statusColor = 'slds-text-color_success';
                } else if (record.Status__c === 'Cancelled') { 
                    statusColor = 'slds-text-color_error';
                } else if (record.Status__c === 'Order placed') {
                    statusColor = 'datatable-blue';
                } else if (record.Status__c === 'Delivered') {
                    statusColor = 'slds-text-color_success';
                }
                    else if (record.Status__c === 'In Transit') {
                    statusColor = 'datatable-orange';
                } else {
                    statusColor = '';   
                }

                return {
                    ...record,
                    AccountName: record.Account?.Name || '',
                    statusClass:statusColor
                }
            });

            this.totalPages = Math.ceil(data.length / this.pageSize);
            this.updatePaginatedData();
        } else if (error) {
            console.log('error while getting records', error);
        }
    }

    updatePaginatedData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.paginatedData = this.allorders.slice(start, end);
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePaginatedData();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePaginatedData();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }


     handleSearchChange(event) {
     
        this.searchKey = event.target.value.toLowerCase();
        console.log('search kay is',this.searchKey);
       
         this.paginatedData = this.allorders.filter(order =>{
            console.log('entered into the filter');
            console.log('accountname',order.AccountName && order.AccountName.toLowerCase().includes(this.searchKey));
          return (  order.OrderNumber.toLowerCase().includes(this.searchKey) ||
            (order.AccountName && order.AccountName.toLowerCase().includes(this.searchKey)));
          
     });
     this.paginatedData = this.paginatedData.slice(0,5);
    

    }

       doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.paginatedData));
    
        let keyValue = (a) => {
            return a[fieldname];
        };
     
        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
          
            return isReverse * ((x > y) - (y > x));
        });
        this.paginatedData = parseData;
    } 




        renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

}