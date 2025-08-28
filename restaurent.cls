public class restaurent {
	@AuraEnabled(cacheable=true)
	public static List<Product2> getproducts(){

		return [SELECT Id, image__c, ProductClass, Name, ProductCode FROM Product2];
	}




   @AuraEnabled
public static void saverecords(List<Orderitem2__c> orderlist) {
    try {
		order2__c temp = new order2__c();
	list<Orderitem2__c>insertlist =  new list<Orderitem2__c>();
		decimal total = 0;
		for(Orderitem2__c ol:orderlist){
            total+= (ol.price__c * ol.quantity__c);	
		}
		temp.Total_Amount__c = total;
		insert temp;
                for(Orderitem2__c ol:orderlist){
                      Orderitem2__c o = new Orderitem2__c();
					  o.order2__c = temp.ID;
					  o.quantity__c=ol.quantity__c;
					  o.price__c = ol.price__c * ol.quantity__c;
					  insertlist.add(o);
		            }
		       insert insertlist;           


	 } catch (Exception e) {
        throw new AuraHandledException('Failed to insert records: ' + e.getMessage());
    }
}

	public class CartItemWrapper {
        @AuraEnabled public String productId;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Integer quantity;
    }

    // @AuraEnabled
    // public static void saveCartItems(List<CartItemWrapper> cartItems) {
    //     List<SelectedItem__c> itemsToInsert = new List<SelectedItem__c>();

    //     for (CartItemWrapper item : cartItems) {
    //         SelectedItem__c selectedItem = new SelectedItem__c();
    //         selectedItem.Product_Name__c = item.name;
    //         selectedItem.Price__c = item.price;
    //         selectedItem.Quantity__c = item.quantity;
    //         itemsToInsert.add(selectedItem);
    //     }

    //     List<Id> insertedIds = new List<Id>();
    //     if (!itemsToInsert.isEmpty()) {
    //         try {
    //             insert itemsToInsert;
    //             for (SelectedItem__c insertedItem : itemsToInsert) {
    //                 insertedIds.add(insertedItem.Id);
    //             }
    //         } catch (DMLException e) {
    //             System.debug('Error inserting cart items: ' + e.getMessage());
    //             throw new AuraHandledException('Error saving cart items: ' + e.getMessage());
    //         }
    //     }
    //     return insertedIds;
    // }
}

// import { LightningElement, track } from 'lwc';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// // Import the Apex method
// import saveCartItems from '@salesforce/apex/ShoppingCartController.saveCartItems';


// export default class ShoppingApp extends LightningElement {
//     @track products = [
//         {
//             id: '1',
//             name: 'Laptop',
//             description: 'Powerful laptop for work and gaming',
//             price: 1200,
//             image: 'https://via.placeholder.com/150' 
//         },
//         {
//             id: '2',
//             name: 'Smartphone',
//             description: 'Latest model with advanced camera features',
//             price: 800,
//             image: 'https://via.placeholder.com/150'
//         },
//         {
//             id: '3',
//             name: 'Headphones',
//             description: 'Noise-canceling headphones for immersive audio',
//             price: 200,
//             image: 'https://via.placeholder.com/150'
//         }
//     ];

//     @track cartItems = [];
//     @track cartTotal = 0;

//     // ... (addToCart, removeFromCart, handleQuantityChange, calculateCartTotal methods remain the same) ...

//     addToCart(event) {
//         const productId = event.target.dataset.itemId;
//         const selectedProduct = this.products.find(product => product.id === productId);

//         if (selectedProduct) {
//             const existingItemIndex = this.cartItems.findIndex(item => item.id === productId);

//             if (existingItemIndex !== -1) {
//                 const updatedCartItems = [...this.cartItems];
//                 updatedCartItems[existingItemIndex].quantity += 1;
//                 updatedCartItems[existingItemIndex].isMinQuantity = updatedCartItems[existingItemIndex].quantity === 1;
//                 this.cartItems = updatedCartItems;
//             } else {
//                 this.cartItems = [
//                     ...this.cartItems,
//                     { ...selectedProduct, quantity: 1, isMinQuantity: true } 
//                 ];
//             }
//             this.calculateCartTotal();
//         }
//     }

//     removeFromCart(event) {
//         const productId = event.target.dataset.itemId;
//         this.cartItems = this.cartItems.filter(item => item.id !== productId);
//         this.calculateCartTotal();
//     }

//     handleQuantityChange(event) {
//         const productId = event.target.dataset.itemId;
//         const action = event.target.dataset.action; 

//         const itemIndex = this.cartItems.findIndex(item => item.id === productId);

//         if (itemIndex !== -1) {
//             const updatedCartItems = [...this.cartItems];
//             if (action === 'increase') {
//                 updatedCartItems[itemIndex].quantity += 1;
//             } else if (action === 'decrease') {
//                 if (updatedCartItems[itemIndex].quantity > 1) {
//                     updatedCartItems[itemIndex].quantity -= 1;
//                 } else {
//                     this.removeFromCart(event); 
//                     return; 
//                 }
//             }
//             updatedCartItems[itemIndex].isMinQuantity = updatedCartItems[itemIndex].quantity === 1;
//             this.cartItems = updatedCartItems;
//             this.calculateCartTotal();
//         }
//     }

//     calculateCartTotal() {
//         this.cartTotal = this.cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
//     }

//     async handleCheckout() {
//         if (this.cartItems.length === 0) {
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Cart Empty',
//                     message: 'Please add items to your cart before checking out.',
//                     variant: 'warning',
//                 })
//             );
//             return;
//         }

//         try {
//             const itemsToSave = this.cartItems.map(item => ({
//                 productId: item.id,
//                 name: item.name,
//                 price: item.price,
//                 quantity: item.quantity
//             }));

//             // Call the Apex method imperatively
//             const insertedIds = await saveCartItems({ cartItems: itemsToSave }); 
//             console.log('Records created in Apex with IDs:', insertedIds); //
            
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Success',
//                     message: `Cart items saved successfully! IDs: ${insertedIds.join(', ')}`, //
//                     variant: 'success', //
//                 })
//             );
            
//             // Clear the cart after successful record creation
//             this.cartItems = []; 
//             this.cartTotal = 0;

//         } catch (error) {
//             console.error('Error saving cart items via Apex:', error); //
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Error Saving Items',
//                     message: error.body.message || error.message || 'Unknown error', //
//                     variant: 'error', //
//                 })
//             );
//         }
//     }
// }