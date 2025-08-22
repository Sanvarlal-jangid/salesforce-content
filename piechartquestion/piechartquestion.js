import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/Chart';
import { loadScript } from 'lightning/platformResourceLoader';

import { createRecord } from 'lightning/uiRecordApi';
import { getRecordInput } from 'lightning/uiRecordApi'; 

export default class SipCalculator extends LightningElement {
    
  
    @track lumpSumAmount = 10000;  
    @track lumpSumDuration = 5;        
    @track lumpSumRate = 8;       
    @track lumpSumInvestedAmount = 0; 
    @track lumpSumEstimatedReturns = 0; 
    @track lumpSumTotalValue = 0;     


    @track sipMonthlyAmount = 1000;    
    @track sipDuration = 5;               
    @track sipRate = 8;                
    @track sipInvestedAmount = 0; 
    @track sipEstimatedReturns = 0;      
    @track sipTotalValue = 0;         

  
    lumpSumChart;         // Holds the Chart.js instance for the lump sum chart
    sipChart;             // Holds the Chart.js instance for the SIP chart
    chartJsInitialized = false; // Flag to ensure Chart.js is loaded only once

    activeTab = 'lumpSum'; // Tracks the currently active tab (for saving purposes)

    connectedCallback() {
        this.initializeChartJs();      // Load Chart.js library
        this.calculateLumpSum();       // Perform initial lump sum calculation
        this.calculateMonthlySIP();    // Perform initial monthly SIP calculation
    }

   
    renderedCallback() {
        if (this.chartJsInitialized) {
            this.updateCharts(); // Update charts only if Chart.js is ready
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

        // --- Lump Sum Chart Update ---
        const lumpSumCanvas = this.template.querySelector('.lumpSumChart');
        if (lumpSumCanvas) { // Check if the canvas element exists in the DOM
            const lumpSumCtx = lumpSumCanvas.getContext('2d'); // Get 2D rendering context
            if (this.lumpSumChart) {
                this.lumpSumChart.destroy(); // Destroy existing chart to prevent redraw issues and memory leaks
            }
            // Create a new Doughnut chart for Lump Sum investment
            this.lumpSumChart = new Chart(lumpSumCtx, {
                type: 'doughnut', // Specify chart type
                data: {
                    labels: ['Invested Amount', 'Estimated Returns'], // Labels for chart segments
                    datasets: [{
                        data: [this.lumpSumInvestedAmount, this.lumpSumEstimatedReturns], // Data values for segments
                        backgroundColor: ['#4BC0C0', '#FFCD56'], // Colors for segments
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
                            text: 'Lump Sum Investment Breakdown' // Chart title text
                        }
                    }
                }
            });
        }

        // --- Monthly SIP Chart Update ---
        const sipCanvas = this.template.querySelector('.sipChart');
        if (sipCanvas) { // Check if the canvas element exists
            const sipCtx = sipCanvas.getContext('2d');
            if (this.sipChart) {
                this.sipChart.destroy(); // Destroy existing chart
            }
            // Create a new Doughnut chart for Monthly SIP investment
            this.sipChart = new Chart(sipCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Invested Amount', 'Estimated Returns'],
                    datasets: [{
                        data: [this.sipInvestedAmount, this.sipEstimatedReturns],
                        backgroundColor: ['#36A2EB', '#FF6384'],
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                        },
                        title: {
                            display: true,
                            text: 'Monthly SIP Investment Breakdown'
                        }
                    }
                }
            });
        }
    }


    handleLumpSumAmountChange(event) {
        this.lumpSumAmount = parseFloat(event.detail.value);
        this.calculateLumpSum(); 
    }

    handleLumpSumDurationChange(event) {
        this.lumpSumDuration = parseFloat(event.detail.value); 
        this.calculateLumpSum();
    }

    handleLumpSumRateChange(event) {
        this.lumpSumRate = parseFloat(event.detail.value); 
        this.calculateLumpSum();
    }

    /**
     * Calculates the future value of a lump sum investment.
     * Formula: FV = P * (1 + r)^t
     * Where:
     * P = Principal (lumpSumAmount)
     * r = Annual interest rate (lumpSumRate / 100)
     * t = Time period in years (lumpSumDuration)
     */
    calculateLumpSum() {
        const rate = this.lumpSumRate / 100; // Convert percentage to decimal
        const totalValue = this.lumpSumAmount * Math.pow((1 + rate), this.lumpSumDuration);

        this.lumpSumTotalValue = totalValue.toFixed(2); // Format to 2 decimal places
        this.lumpSumInvestedAmount = this.lumpSumAmount.toFixed(2);
        this.lumpSumEstimatedReturns = (totalValue - this.lumpSumAmount).toFixed(2);
        this.updateCharts(); 
    }

  
    handleSipMonthlyAmountChange(event) {
        this.sipMonthlyAmount = parseFloat(event.detail.value);
        this.calculateMonthlySIP();
    }

    handleSipDurationChange(event) {
        this.sipDuration = parseFloat(event.detail.value);
        this.calculateMonthlySIP();
    }

    handleSipRateChange(event) {
        this.sipRate = parseFloat(event.detail.value);
        this.calculateMonthlySIP();
    }

    /**
     * Calculates the future value of a Systematic Investment Plan (SIP).
     * Formula: FV = P * [ (1 + r)^n - 1 ] / r * (1+r)
     * (Simplified for monthly contributions where:
     * P = Monthly Investment Amount
     * r = Monthly rate (Annual Rate / 100 / 12)
     * n = Number of months (Duration in Years * 12)
     * Note: The (1+r) at the end of the formula is for beginning-of-period payments, commonly used for SIP.
     * For simplicity and common SIP calculations, we'll use the ending-of-period formula, which doesn't have the final (1+r) multiplier.
     * The formula used here: FV = P * [((1 + r)^n - 1) / r]
     * This is suitable for general SIP return calculation.
     */
    calculateMonthlySIP() {
        const monthlyRate = this.sipRate / 100 / 12; // Convert annual percentage rate to monthly decimal rate
        const numberOfMonths = this.sipDuration * 12; // Total number of monthly payments

        let totalValue;
        if (monthlyRate === 0) {
            totalValue = this.sipMonthlyAmount * numberOfMonths;
        } else {
            // SIP future value formula
            totalValue = this.sipMonthlyAmount * (Math.pow((1 + monthlyRate), numberOfMonths) - 1) / monthlyRate;
        }

        this.sipTotalValue = totalValue.toFixed(2);
        this.sipInvestedAmount = (this.sipMonthlyAmount * numberOfMonths).toFixed(2);
        this.sipEstimatedReturns = (this.sipTotalValue - this.sipInvestedAmount).toFixed(2);
        this.updateCharts(); 
    }

   
    handleSaveInvestment() {
        const fields = {};


    
        if (this.activeTab === 'lumpSum') {
            fields.Name = 'Lump Sum';
            fields.Investment_Amount__c = this.lumpSumAmount;
            fields.Investment_Duration__c = this.lumpSumDuration;
            fields.Expected_Return_Rate__c = this.lumpSumRate;
            fields.Total_Invested_Amount__c = parseFloat(this.lumpSumInvestedAmount);
            fields.Estimated_Returns__c = parseFloat(this.lumpSumEstimatedReturns);
            fields.Total_Value__c = parseFloat(this.lumpSumTotalValue);
        } else if (this.activeTab === 'monthlySIP') {
            fields.Name = 'SIP';
            fields.Investment_Amount__c = this.sipMonthlyAmount;
            fields.Investment_Duration__c = this.sipDuration;
            fields.Expected_Return_Rate__c = this.sipRate;
            fields.Total_Invested_Amount__c = parseFloat(this.sipInvestedAmount);
            fields.Estimated_Returns__c = parseFloat(this.sipEstimatedReturns);
            fields.Total_Value__c = parseFloat(this.sipTotalValue);
        }

      
        const recordInput = {apiName:'Investment__c', fields };

      
        createRecord(recordInput)
            .then(investment => {
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Investment record created: ' + investment.id,
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
              
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message, 
                        variant: 'error',
                    }),
                );
            });
    }

    handleTabChange(event) {
        this.activeTab = event.target.value; 
        this.updateCharts();
    }
}