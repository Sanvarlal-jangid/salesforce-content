import { LightningElement,track,wire } from 'lwc';
import MY_IMAGE from '@salesforce/resourceUrl/imageurl';
import getproducts from '@salesforce/apex/restaurent.getproducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saverecords from '@salesforce/apex/restaurent.saverecords';


export default class ShoppingApp extends LightningElement {
    @track products = [];
          imageUrl = MY_IMAGE;

@wire(getproducts)
    wiredAccounts({ error, data }) { 
        if (data) {
            console.log('product data',data);
          let uniqueIdCounter = 0; 
                  this.products = data.map(item => {
                       uniqueIdCounter++; 
                       return { 
                             ...item, 
                               id: 'product_' + uniqueIdCounter ,
                             price: this.getRandomPriceInThousands()

                         }; 
                       });
                       console.log('products ',this.products);

        } else if (error) {
            
            console.error('Error retrieving data:', error);
        }
    }
    @track cartItems = [];
    @track cartTotal = 0;

    addToCart(event) {
        const productId = event.target.dataset.itemId;
        const selectedProduct = this.products.find(product => product.id === productId);

        if (selectedProduct) {
            const existingItemIndex = this.cartItems.findIndex(item => item.id === productId);

            if (existingItemIndex !== -1) {
                // If item exists, update its quantity
                const updatedCartItems = [...this.cartItems];
                updatedCartItems[existingItemIndex].quantity += 1;
                updatedCartItems[existingItemIndex].isMinQuantity = updatedCartItems[existingItemIndex].quantity === 1;
                this.cartItems = updatedCartItems;
            } else {
                // If item doesn't exist, add it with quantity 1
                this.cartItems = [
                    ...this.cartItems,
                    { ...selectedProduct, quantity: 1, isMinQuantity: true } 
                ];
            }
            this.calculateCartTotal();
        }
    }

    removeFromCart(event) {
        const productId = event.target.dataset.itemId;
        this.cartItems = this.cartItems.filter(item => item.id !== productId);
        this.calculateCartTotal();
    }

    handleQuantityChange(event) {
        const productId = event.target.dataset.itemId;
        const action = event.target.dataset.action; // 'increase' or 'decrease'

        const itemIndex = this.cartItems.findIndex(item => item.id === productId);

        if (itemIndex !== -1) {
            const updatedCartItems = [...this.cartItems];
            if (action === 'increase') {
                updatedCartItems[itemIndex].quantity += 1;
            } else if (action === 'decrease') {
                if (updatedCartItems[itemIndex].quantity > 1) { 
                    updatedCartItems[itemIndex].quantity -= 1;
                } else {
                    this.removeFromCart(event); 
                    return; 
                }
            }
            updatedCartItems[itemIndex].isMinQuantity = updatedCartItems[itemIndex].quantity === 1;
            this.cartItems = updatedCartItems;
            this.calculateCartTotal();
        }
    }
     getRandomPriceInThousands = () => {
                const minThousands = 1; 
                const maxThousands = 10; 

                 const randomValue = Math.floor(Math.random() * (maxThousands - minThousands + 1)) + minThousands;

                    return randomValue * 10000;
                 };

    calculateCartTotal() {
        this.cartTotal = this.cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
    }
  
    handleCheckout() {
        console.log('Proceeding to checkout with items:', JSON.stringify(this.cartItems));
        console.log('Total:', this.cartTotal);
        this.cartItems = [];
        this.cartTotal = 0;

    }
    createrecord() {
        console.log('creterecord clicked');
        try{

    const itemsToSave = this.cartItems.map(item => ({
        product_name__c: item.name,
        price__c: item.price,
        quantity__c: item.quantity
    }));

    saverecords({ orderlist: itemsToSave })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Records created successfully!',
                variant: 'success'
            }));
            this.cartItems = [];
            this.cartTotal = 0;
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Unknown error occurred',
                variant: 'error'
            }));
            console.error('Apex error:', error);
        });
        }catch(error){
              console.log('error in creating record in trycatch method',error);
        }
}

    // createrecord(){
    //     try {
    //         const itemsToSave = this.cartItems.map(item => ({
    //             product_name__c: item.name,
    //             price__c: item.price,
    //             quantity__c: item.quantity
    //         }));

    //          saverecords({ cartItems: itemsToSave })
    //            .then(result => {
    //             const toastEvent = new ShowToastEvent({
    //                 title: 'Success',
    //                 message: 'Records created successfully!',
    //                 variant: 'success'
    //             });
    //             this.dispatchEvent(toastEvent);
    //             // Optionally handle the returned records (e.g., refresh data)
    //         }).catch(error => {
    //             const toastEvent = new ShowToastEvent({
    //                 title: 'Error',
    //                 message: error.body.message,
    //                 variant: 'error'
    //             });
    //             this.dispatchEvent(toastEvent);
    //         });
            
         
    //         // Clear the cart after successful record creation
    //         this.cartItems = []; 
    //         this.cartTotal = 0;

    //     } catch (error) {
    //         console.error('Error saving cart items via Apex:', error); //
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error Saving Items',
    //                 message: error.body.message || error.message || 'Unknown error', //
    //                 variant: 'error', //
    //             })
    //         );
    //     }
    // }
}