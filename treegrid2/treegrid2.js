import { LightningElement, api, wire, track } from 'lwc';
import getOpportunities from '@salesforce/apex/treegrid.getOpportunities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class OpportunityTreeGrid extends LightningElement {
    @api recordId;
    @track gridData = [];
    @track selectedOppId;
    wiredResult;

    @track columns = [
        { label: 'Title', fieldName: 'name', type: 'text' },
        { label: 'Close Date', fieldName: 'closeDate', type: 'date' },
        { label: 'stage', fieldName: 'stage', type: 'text' },
        {   label: 'status',
            fieldName: '',
            cellAttributes: { iconName: { fieldName: 'statusIcon' } }
        },
        { 
            type: 'button-icon', 
            fieldName: 'actionButton',
            label: '',
            typeAttributes: {
                        iconName: 'utility:upload',
                        name: 'uploadDoc',
                        title: 'Upload Document' ,
                        variant: 'bare' 
            }
        }
        
    ];

    @wire(getOpportunities, { accountId: '$recordId' })
    wiredOpps(result) {
        this.wiredResult = result;
        if (result.data) {
        console.log(result.data);
            this.gridData = this.formatData(result.data);
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // formatData(opps) {
    //     let result = [];

    //     opps.forEach(opp => {
    //         let closeDate = new Date(opp.CloseDate);
    //         let year = closeDate.getFullYear();
    //         let month = closeDate.toLocaleString('default', { month: 'long' });

    //         let yearNode = result.find(y => y.name === year.toString());
    //         if (!yearNode) {
    //             yearNode = { name: year.toString(), _children: [] };
    //             result.push(yearNode);
    //         }

    //         let monthNode = yearNode._children.find(m => m.name === month);
    //         if (!monthNode) {
    //             monthNode = { name: month, _children: [] };
    //             yearNode._children.push(monthNode);
    //         }

    //         monthNode._children.push({
    //             name: opp.Name,
    //             closeDate: opp.CloseDate,
    //             stage: opp.StageName,
    //             oppId: opp.Id
    //         });
    //     });

    //     return result;
    // }

   formatData(opps) {
    let result = [];

    opps.forEach(opp => {
        let closeDate = new Date(opp.CloseDate);
        let year = closeDate.getFullYear();
        let month = closeDate.toLocaleString('default', { month: 'long' });

        let yearNode = result.find(y => y.name === year.toString());
        if (!yearNode) {
            yearNode = { name: year.toString(), _children: [] };
            result.push(yearNode);
        }

        let monthNode = yearNode._children.find(m => m.name === month);
        if (!monthNode) {
            monthNode = { name: month, _children: [] };
            yearNode._children.push(monthNode);
        }

        const hasDocs = ( opp.ContentDocumentLinks  && opp.ContentDocumentLinks.length > 0);

        monthNode._children.push({
            name: opp.Name,
            closeDate: opp.CloseDate,
            stage: opp.StageName,
            oppId: opp.Id,  
            statusIcon: hasDocs ? 'utility:check' : 'utility:close'
        });
    });

    return result;
}


    handleExpandAll() {
        this.template.querySelector('lightning-tree-grid').expandAll();
    }

    handleCollapseAll() {
        this.template.querySelector('lightning-tree-grid').collapseAll();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'uploadDoc') {
            console.log('rowaction chal upload m')
            this.selectedOppId = row.oppId;
        }
    }

   

    handleUploadFinished() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'File uploaded successfully!',
                variant: 'success'
            })
        );
        refreshApex(this.wiredResult);
        this.closeModal();
    }

    closeModal() {
        this.selectedOppId = null;
    }
}