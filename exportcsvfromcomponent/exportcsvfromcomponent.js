import { LightningElement, wire, track } from 'lwc';
import getData from '@salesforce/apex/ExportCsvFromComponent.getData';
import { loadStyle } from 'lightning/platformResourceLoader';
import DATATABLE_STYLES from '@salesforce/resourceUrl/myCustomStyles';
import createrecord from '@salesforce/apex/ExportCsvFromComponent.createrecord';
import updateMyData from '@salesforce/apex/ExportCsvFromComponent.updateMyData';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import EndDate from '@salesforce/schema/Contract.EndDate';
export default class Exportcsvfromcomponent extends NavigationMixin(LightningElement) {
    opportunityLineItems = [];
    @track incomingData;
    @track orginaldata;
    @track filtereddata

    selectedDateend
    selectedDatestart

    wiredDataResult






    @wire(getData)
    wiredata(result) {
        this.wiredDataResult = result;
        if (result.data) {
            console.log('data is coming from the apex', result.data);
            const ans = [];
            this.incomingData = result.data;
            this.incomingData.forEach(account => {
                const accountName = account.Name;
                const contactName = account.Contacts[0] ? account.Contacts[0].LastName : 'N/A';

                account.Orders.forEach(order => {
                    let setclass = '';
                    if (order.Status === 'Draft') {
                        setclass = 'orange'
                    } else if (order.Status === 'Activated') {
                        setclass = 'red';
                    }
                    ans.push({
                        blue: 'blue',
                        setclass: setclass,
                        OrderId: order.Id,
                        Orderby: 'DAP 106',
                        Status: order.Status,
                        EndDate: order.EndDate,
                        TotalAmount: order.TotalAmount,
                        EffectiveDate: order.EffectiveDate,
                        AccountName: accountName,
                        ContactName: contactName
                    });
                });
            });
            this.orginaldata = ans;
            this.filtereddata = this.orginaldata;
            console.log('Flattened Orders:', this.orginaldata);

        } else if (result.error) {
            console.log('we got the error', result.error);
        }


    }
    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([
                loadStyle(this, DATATABLE_STYLES)
            ]).then(() => {
                this.stylesLoaded = true;
            }).catch(error => {
                console.error('Error loading styles:', error);
            });
        }
    }



    handleDateChange(event) {

        this.selectedDatestart = event.target.value;
        console.log('Selected Date:', this.selectedDatestart);
    }
    handleEndDateChange(event) {

        this.selectedDateend = event.target.value;
        console.log('Selected Date:', this.selectedDateend);
    }
    handleClick() {
        console.log('apply filer clicked ');
        if (this.selectedDatestart) {
            const targetDate = new Date(this.selectedDatestart);
            // Set to start of the day to compare only date part
            targetDate.setUTCHours(0, 0, 0, 0);

            const filterrecord = this.orginaldata.filter(record => {
                // Convert record's start date string to a Date object
                const recordStartDate = new Date(record.EffectiveDate);
                // Set to start of the day to compare only date part
                recordStartDate.setUTCHours(0, 0, 0, 0);

                // Compare the time values (milliseconds since epoch)
                return recordStartDate.getTime() === targetDate.getTime();
            });
            console.log('filtered data', filterrecord);
            this.filtereddata = filterrecord;


        }
        if (this.selectedDateend) {
            const targetDate = new Date(this.selectedDateend);
            // Set to start of the day to compare only date part
            targetDate.setUTCHours(0, 0, 0, 0);

            const filterrecord = this.orginaldata.filter(record => {
                // Convert record's start date string to a Date object
                const recordStartDate = new Date(record.EndDate);
                // Set to start of the day to compare only date part
                recordStartDate.setUTCHours(0, 0, 0, 0);

                // Compare the time values (milliseconds since epoch)
                return recordStartDate.getTime() === targetDate.getTime();
            });
            console.log('filtered data', filterrecord);
            this.filtereddata = filterrecord;


        }
     
        if (this.selectedDateend && this.selectedDatestart) {
            const startDate = new Date(this.selectedDatestart);
            startDate.setUTCHours(0, 0, 0, 0);

            const endDate = new Date(this.selectedDateend);
            endDate.setUTCHours(0, 0, 0, 0);

            const filterrecord = this.orginaldata.filter(record => {
                const recordStartDate = new Date(record.EffectiveDate);
                recordStartDate.setUTCHours(0, 0, 0, 0);

                const recordEndDate = new Date(record.EndDate);
                recordEndDate.setUTCHours(0, 0, 0, 0);

                return (
                    recordStartDate.getTime() === startDate.getTime() &&
                    recordEndDate.getTime() === endDate.getTime()
                );
            });

            console.log('filtered data', filterrecord);
            this.filtereddata = filterrecord;
        }



    }
    handlecreatClick(event) {
        const recordid = event.currentTarget.dataset.id;
        console.log('Data ID:', recordid);

        createrecord({ recordId: recordid })
            .then(result => {
                console.log('record created');
            })
            .catch(error => {
                console.error('Error in createing record:', error);
                this.greetingMessage = 'Error: ' + error.body.message;
            });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order', // Specify the API name of the Order object
                actionName: 'list' // Indicate that you want to navigate to a list view
            },
            state: {
                // Optional: Specify a particular list view by its API name or 18-character ID
                // For example, to navigate to the 'AllOrders' list view:
                // filterName: 'AllOrders' 
            }
        });
    }

    downloadCSV() {
        const csvContent = this.convertToCSV(this.filtereddata);
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);

        const link = document.createElement('a');
        link.setAttribute('href', url);
        link.setAttribute('download', 'datatable_data.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    convertToCSV(data) {
        if (!data || !data.length) return '';

        const columnHeaders = Object.keys(data[0]);
        const csvRows = data.map(row =>
            columnHeaders.map(field => `"${row[field]}"`).join(',')
        );

        return [columnHeaders.join(','), ...csvRows].join('\n');
    }


    columnHeader = ['OrderId', 'Orderby', 'Status', 'TotalAmount', 'EffectiveDate', 'AccountName'];
    exportContactData() {
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        // Add the data rows
        this.orginaldata.forEach(record => {
            doc += '<tr>';
            doc += '<th>' + record.OrderId + '</th>';
            doc += '<th>' + record.Orderby + '</th>';
            doc += '<th>' + record.Status + '</th>';
            doc += '<th>' + record.TotalAmount + '</th>';
            doc += '<th>' + record.EffectiveDate + '</th>';
            doc += '<th>' + record.AccountName + '</th>';
            doc += '</tr>';
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Contact Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    // handlerefresh() {
    //     updateMyData()
    //         .then(() => {
    //             console.log('return from update method');
    //             this.selectedDateend = '';
    //             this.selectedDatestart = '';
    //             return refreshApex(this.wiredDataResult);
    //         })
    //         .catch(error => {

    //         });
    // }

    handlerefresh() {
        refreshApex(this.wiredDataResult)
            .then(() => {
                console.log('Data refreshed successfully');
                this.filtereddata = this.orginaldata;
                this.selectedDateend = '';
                this.selectedDatestart = '';
            })
            .catch(error => {
                console.error('Error refreshing data:', error);
            });
    }

}
