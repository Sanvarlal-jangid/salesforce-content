import { LightningElement, wire, track } from 'lwc';
import getAccountsWithChildAccounts from '@salesforce/apex/treegrid.getAccountsWithChildAccounts'; // Correctly reference your Apex class and method
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountTreeGrid extends LightningElement { 

    @track gridData; // Holds the hierarchical data for the tree grid
    @track columns = [
        {
            type: 'text',
            fieldName: 'Name',
            label: 'Account Name',
            initialWidth: 250 
        },
        {
            type: 'number', // Use 'number' for numerical fields for correct formatting
            fieldName: 'NumberOfEmployees',
            label: 'No. of Employees',
            initialWidth: 150
        },
        {
            type: 'text',
            fieldName: 'AccountNumber',
            label: 'Account Number',
            initialWidth: 150
        }
    ];

    connectedCallback() {
        this.loadAccounts(); // Call the method to load and process data when component loads
    }

 
    loadAccounts() {
        getAccountsWithChildAccounts()
            .then(result => {
                console.log('Raw Apex result:', JSON.parse(JSON.stringify(result)));
                this.gridData = this.transformToTreeGridData(result);
                console.log('Final Tree Grid Data:', JSON.parse(JSON.stringify(this.gridData)));
            })
            .catch(error => {
                console.error('Error fetching accounts:', error);
                this.showToast('Error', 'Error loading accounts: ' + this.getErrorMessage(error), 'error');
            });
    }

    transformToTreeGridData(data) {
        let finalHierarchy = [];
        let itemMap = new Map(); // Maps ID to the item object for quick lookup

        // First pass: Populate map with all items and initialize _children for each
        data.forEach(item => {
            // Create a copy of the item and add an empty _children array.
            // This ensures every node can potentially be a parent.
            itemMap.set(item.Id, { ...item, _children: [] });
        });

        // Second pass: Build the tree structure
        itemMap.forEach(item => {
            if (item.ParentId) {
                // If the current item has a ParentId, find its parent in the map
                let parent = itemMap.get(item.ParentId);
                if (parent) {
                    // If the parent exists in our fetched data, add the current item to its _children array
                    parent._children.push(item);
                } else {
                    // If ParentId exists but the parent account is NOT in our fetched data (e.g., filtered out by Apex),
                    // treat this item as a top-level node for display purposes.
                    finalHierarchy.push(item);
                }
            } else {
                // If no ParentId, it's a top-level (root) account
                finalHierarchy.push(item);
            }
        });

        // Optional: Recursively remove the _children array from leaf nodes (nodes that have no actual children).
        // This prevents the expansion arrow from appearing next to accounts that have no children,
        // which improves the visual clarity of the tree grid.
        const cleanEmptyChildren = (nodes) => {
            nodes.forEach(node => {
                if (node._children && node._children.length === 0) {
                    delete node._children; // Remove the empty array property
                } else if (node._children && node._children.length > 0) {
                    cleanEmptyChildren(node._children); // Recurse for children
                }
            });
            return nodes;
        };

        // Apply the cleaning function to the final hierarchical data
        return cleanEmptyChildren(finalHierarchy);
    }

    getErrorMessage(error) {
        let message = 'An unexpected error occurred.';
        if (error) {
            if (error.body) {
                if (Array.isArray(error.body.output?.errors) && error.body.output.errors.length > 0) {
                    message = error.body.output.errors[0].message;
                } else if (error.body.message) {
                    message = error.body.message;
                } else if (typeof error.body === 'string') {
                    message = error.body;
                }
            } else if (error.message) {
                message = error.message;
            }
        }
        return message;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}




// import { LightningElement, wire, track } from 'lwc';
// import getAccountsWithContacts from '@salesforce/apex/treegrid.getAccountsWithChildAccounts';
// import getAccountsWithChildAccounts from '@salesforce/apex/treegrid.getAccountsWithChildAccounts'; // Correctly reference your Apex class and method

// export default class DapMarch2023 extends LightningElement {

//     @track gridData;
//     @track columns = [
//         {
//             type: 'text',
//             fieldName: 'Name',
//             label: 'Account Name'
//         },
//         {
//             type: 'text',
//             fieldName: 'NumberOfEmployees',
//             label: 'NumberOfEmployees'
//         },
//         {
//             type: 'text',
//             fieldName: 'AccountNumber',
//             label: 'AccountNumber'
//         }
//     ];

//     connectedCallback()
//     {
//         getAccountsWithContacts()
//             .then(result => {

//                 console.log('result ---> ' , result);
//                 const temp = JSON.parse(JSON.stringify(result));

//                 console.log('temp ---> ' , temp);
//                 for(var i= 0; i<temp.length;i++)
//                 {
//                     if(temp[i].ParentId != null)
//                     {
//                         let child = temp[i];
//                         console.log('Child object =>', child);

//                         temp.find(element => element.Id == child.ParentId)._children = [child];
                        
//                     }
//                 }
//                 this.gridData = temp;

//                 console.log('temp Final Data ---> ' , this.gridData);
//             })
//             .catch(error => {
//                 this.error = error;
//             });
//     }

// }