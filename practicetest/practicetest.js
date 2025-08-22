import { LightningElement,wire ,track,api} from 'lwc';
import getopportunity from '@salesforce/apex/practicetestclass.getopportunity';
import getPicklistValues from '@salesforce/apex/OpportunityControllerTest.getPicklistValues';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOpportunities from '@salesforce/apex/practicetestclass.updateOpportunities';
import { refreshApex } from '@salesforce/apex';
import leadSource from "@salesforce/schema/Opportunity.LeadSource";


import getFieldSetFields from '@salesforce/apex/practicetestclass.getFieldSetFields';
export default class OpportunityCreator extends NavigationMixin(LightningElement) {
 @api fieldSetName; 
 @api picklistFieldApiName;
  @track columns = [];
   @track picklistValues = [];
     @track filteredOpportunities = [];
      columns = [
        {
            label: 'Date',
            fieldName: 'CloseDate',
            editable: true, 
            sortable: true

        },
        {
            label: 'Referral Source',
            fieldName: 'ReferenceSource',
            sortable: true,
              editable: true,

        },
        {
            label: 'Type',
            fieldName: 'Type',
                editable: true,

              sortable: true

        },
        {
            label: 'Account Name',
            fieldName: 'AccountName',
                editable: true,

  
        },
           {
            label: 'Name',
            fieldName: 'Name',
                editable: true,

              sortable: true
  
        },
             {
            label: 'Quantity',
            fieldName: 'TotalOpportunityQuantity',
                editable: true,

  
        },
        
    ];

    // Wire method to get picklist values
    // @wire(getPicklistValues, { objectApiName: 'Opportunity', fieldApiName: '$picklistFieldApiName' })
    // wiredPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('picklistvalues',data);
    //         this.picklistValues = data;
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error.body.message;
    //         console.log('picklistvalueerror',this.error);
    //         this.picklistValues = [];
    //         this.showToast('Error', this.error, 'error');
    //     }
    // }

    // Wire method to get field set fields
    // @wire(getFieldSetFields, { objectApiName: 'Opportunity', fieldSetName: '$fieldSetName' })
    // wiredFieldSetFields({ error, data }) {
    //     if (data) {
    //         console.log('field is coming',data);
    //         this.columns = data.map(fieldName => {
    //             let column = {
    //                 label: this.getLabelFromFieldName(fieldName), 
    //                 fieldName: fieldName,
    //                 editable: true,
    //                 sortable: true
    //             };
    //             if (fieldName === 'Name') {
    //                 column.type = 'url';
    //                 column.typeAttributes = {
    //                     label: { fieldName: 'Name' },
    //                     target: '_blank',
    //                     tooltip: 'Click to view record'
    //                 };
    //                 column.fieldName = 'NameUrl'; 
    //             }
    //             return column;
    //         });
    //         // Add Id column if not present and ensure Name is present for navigation
    //         const idColumnExists = this.columns.some(col => col.fieldName === 'Id');
    //         if (!idColumnExists) {
    //              this.columns.unshift({ label: 'Id', fieldName: 'Id', type: 'text', editable: false, sortable: false });
    //         }
    //         const nameColumnExists = this.columns.some(col => col.fieldName === 'Name' || col.fieldName === 'NameUrl');
    //         if (!nameColumnExists) {
    //             this.columns.unshift({
    //                 label: 'Opportunity Name',
    //                 fieldName: 'NameUrl',
    //                 type: 'url',
    //                 typeAttributes: {
    //                     label: { fieldName: 'Name' },
    //                     target: '_blank',
    //                     tooltip: 'Click to view record'
    //                 },
    //                 editable: true,
    //                 sortable: true
    //             });
    //         }


    //         this.error = undefined;
    //      //   this.loadOpportunities();
    //     } else if (error) {
    //         this.error = error.body.message;
    //         this.columns = [];
    //         this.showToast('Error', this.error, 'error');
    //     }
    // }

 @wire(getPicklistValues, { objectApiName: 'Opportunity', fieldApiName: '$picklistFieldApiName' })
    wiredStageValues({ error, data }) {
        if (data) {
            this.picklistValues = data;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }
   createOpportunity() {
    console.log('create button clicked');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            }
        });
    }
//  @wire(getPicklistValues, { objectApiName: 'Opportunity', fieldApiName: '$picklistFieldApiName' })
//     wiredPicklistValues({ error, data }) {
//         if (data) {
//             this.picklistValues = data;
//             this.error = undefined;
//         } else if (error) {
//             this.error = error.body.message;
//             this.picklistValues = [];
//             this.showToast('Error', this.error, 'error');
//         }
//     }

    // // Wire method to get field set fields
    // @wire(getFieldSetFields, { objectApiName: 'Opportunity', fieldSetName: '$fieldSetName' })
    // wiredFieldSetFields({ error, data }) {
    //     if (data) {
    //         this.columns = data.map(fieldName => {
    //             let column = {
    //                 label: this.getLabelFromFieldName(fieldName), // Helper to get a nice label
    //                 fieldName: fieldName,
    //                 type: this.getTypeFromFieldName(fieldName), // Helper to determine type
    //                 editable: true, // Assuming all fields in field set are editable
    //                 sortable: true
    //             };
    //             if (fieldName === 'Name') { // Make Name a hyperlink
    //                 column.type = 'url';
    //                 column.typeAttributes = {
    //                     label: { fieldName: 'Name' },
    //                     target: '_blank',
    //                     tooltip: 'Click to view record'
    //                 };
    //                 column.fieldName = 'NameUrl'; // A custom field for the URL
    //             }
    //             return column;
    //         });
    //         // Add Id column if not present and ensure Name is present for navigation
    //         const idColumnExists = this.columns.some(col => col.fieldName === 'Id');
    //         if (!idColumnExists) {
    //              this.columns.unshift({ label: 'Id', fieldName: 'Id', type: 'text', editable: false, sortable: false });
    //         }
    //         const nameColumnExists = this.columns.some(col => col.fieldName === 'Name' || col.fieldName === 'NameUrl');
    //         if (!nameColumnExists) {
    //             this.columns.unshift({
    //                 label: 'Opportunity Name',
    //                 fieldName: 'NameUrl',
    //                 type: 'url',
    //                 typeAttributes: {
    //                     label: { fieldName: 'Name' },
    //                     target: '_blank',
    //                     tooltip: 'Click to view record'
    //                 },
    //                 editable: true,
    //                 sortable: true
    //             });
    //         }


    //         this.error = undefined;
    //         this.loadOpportunities();
    //     } else if (error) {
    //         this.error = error.body.message;
    //         this.columns = [];
    //         this.showToast('Error', this.error, 'error');
    //     }
    // }
 


    @track Allopportunities;
    @wire(getopportunity)
       wireddata(result) {
        this.wiredResult = result;
        console.log('data is coming of opportunity',result.data);
        if (result.data) {
            this.Allopportunities = result.data.map(row => ({
                ...row,
                ReferenceSource: row.Campaign?.Name || '',
                AccountName: row.Account?.Name || ''

            }));


        } else if (result.error) {
            console.error('error for loadopportunity',result.error);
        }
    }
//  handleTabClick(event) {
//     const selected = event.target.dataset.value;
//     this.selectedStage = selected;

//     if (selected === 'All Opportunities') {
//         this.filteredOpportunities = [...this.Allopportunities];
//     } else {
//         this.filteredOpportunities = this.Allopportunities.filter(o => 
//             o.StageName && o.StageName.trim().toLowerCase() === selected.trim().toLowerCase()
//         );
//     }
// }
     handleRefresh() {
       console.log('refresh button ckicked');
       
            refreshApex(this.Allopportunities);
 
        this.showToast('Success', 'Opportunities refreshed!', 'success');
      
    }

       getLabelFromFieldName(fieldName) {
        // You'd ideally fetch field labels from schema, but for a quick example:
        return fieldName.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
    }

     showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

  doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.Allopportunities));
    let keyValue = (a) => a[fieldname] || '';
    let isReverse = direction === 'asc' ? 1 : -1;

    parseData.sort((x, y) => {
        x = keyValue(x);
        y = keyValue(y);
        return isReverse * ((x > y) - (y > x));
    });

    this.Allopportunities = parseData;
}

@track draftValues = [];

handleSave(event) {
    const fields = event.detail.draftValues;

    updateOpportunities({ opportunities: fields })
        .then(() => {
            this.showToast('Success', 'Opportunities updated successfully!', 'success');
            this.draftValues = [];
            return refreshApex(this.wiredResult); // if you're using refreshApex
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
}

}