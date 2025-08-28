
import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import csvFileRead from '@salesforce/apex/csvUploaderController.csvFileRead';
import chartjs from '@salesforce/resourceUrl/Chart';
import { loadScript } from 'lightning/platformResourceLoader';

export default class CSVuploader extends LightningElement {
    @track uploadedFiles;
       @track data;
       @track tableviewdata;
       activeTab = 'graphicview';
       red = 0;
       blue =0;
       orange = 0;
    chartJsInitialized = false;
       columns = [ 
             { label: 'Name', fieldName: 'Name__c'},
             { label: 'Pressure management', fieldName: 'Pressure_management__c' }, 
             { label: 'Attendance__c', fieldName: 'Attendance__c' },
             { label: 'Problem solving skills', fieldName: 'Problem_solving_skills__c'}, 
             { label: 'Productivity', fieldName: 'Productivity__c'}, 
  
];  
  columnsss = [ 
             { label: 'Name', fieldName: 'Name'},
             { label: 'Overall performance', fieldName: 'OP' },
  
];     
  connectedCallback() {
        this.initializeChartJs();      // Load Chart.js library
    }
    renderedCallback() {
    if (this.chartJsInitialized && this.activeTab === 'graphicview') {
        this.updateCharts();
    }
}
    initializeChartJs() {
        // Prevent re-initialization if Chart.js is already loaded
        if (this.chartJsInitialized) {
            return;
        }

        // Load the Chart.js static resource
        loadScript(this, chartjs)
            .then(() => {
                // Once loaded successfully, set the flag and update charts
                this.chartJsInitialized = true;
                this.updateCharts(); // Render initial charts after Chart.js is ready
            })
            .catch(error => {
                // Display an error toast if Chart.js fails to load
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading ChartJs',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }
updateCharts() {
        // Do not proceed if Chart.js has not been initialized yet
        if (!this.chartJsInitialized) {
            return;
        }

 
        const graphicalview = this.template.querySelector('.graphicalview');
        if (graphicalview) { // Check if the canvas element exists in the DOM
            const gviewCtx = graphicalview.getContext('2d'); // Get 2D rendering context
            if (this.graphicalview) {
                this.graphicalview.destroy(); // Destroy existing chart to prevent redraw issues and memory leaks
            }
            this.graphicalview = new Chart(gviewCtx, {
                type: 'pie', // Specify chart type
                data: {
                    labels: ['Red for rating 1 and 2', 'green for rating above 3.5','ornge for above rating 3 to 3.5'], // Labels for chart segments
                    datasets: [{
                        data: [this.red, this.blue,this.orange], // Data values for segments
                        backgroundColor: ['#f53666ff', '#a6d6ecff','#f58c46ff'], // Colors for segments
                        hoverOffset: 4 // Offset when hovering over segments
                    }]
                },
                options: {
                    responsive: true, // Chart will resize with its container
                    maintainAspectRatio: false, // Do not force fixed aspect ratio
                    plugins: {
                        legend: {
                            position: 'bottom', // Position legend at the bottom
                        },
                        title: {
                            display: true, // Display chart title
                            text: 'graphical view representation' // Chart title text
                        }
                    }
                }
            });
        }
    }
    uploadFileHandler(event) {
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;
        console.log('uploaded file content',uploadedFiles);
        console.log('uploaded file content',uploadedFiles[0].documentId);

        // calling apex class csvFileread method
        csvFileRead({contentDocumentId : uploadedFiles[0].documentId})
        .then(result => {
            console.log(result);
            console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'employee are created according to the CSV file upload!!!',
                    variant: 'Success',
                }),
            );
            this.tableviewdata = result.map(record => {
                let OP = ((record.Attendance__c * 0.2) + (record.Productivity__c * 0.2)+(record.Problem_solving_skills__c * 0.3) + (record.Pressure_management__c * 0.3)) * 1;
              if((OP > 0 && OP <= 2) ){
                 this.red++;
              }else if((OP > 2 && OP <= 3)){
                this.orange++;
              }else if((OP > 3 && OP <= 5)){
                this.blue++;
              }
                return { Name:record.Name__c , OP:OP};
            });
            console.log('table view data',this.tableviewdata);
             this.updateCharts();
            
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }
     handleTabChange(event) {
        this.activeTab = event.target.value; 
        this.updateCharts();
    }
}