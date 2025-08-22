import { LightningElement } from 'lwc';

export default class Ecommerce extends LightningElement {
    jsn = {
        "categories": [
            {
                "id": 1,
                "name": "Electronics",
                "products": [
                    {
                        "id": 101,
                        "name": "Smartphone",
                        "description": "Latest model smartphone with a 6.5-inch display.",
                        "price": 699,
                        "stockStatus": "In Stock",
                        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTm5hHANz6aT-5NcugwT6goIfCECJFzLUW4pQ&s",
                        "rating": 5,
                        "reviews": [
                            {
                                "user": "Rahul Sharma",
                                "rating": 5,
                                "comment": "Amazing phone, great value for money!"
                            }
                        ]
                    },
                    {
                        "id": 102,
                        "name": "Laptop",
                        "description": "A high-performance laptop with Intel i7 processor.",
                        "price": 999,
                        "stockStatus": "Out of Stock",
                        "image": "https://www.techtarget.com/rms/onlineimages/hp_elitebook_mobile.jpg",
                        "rating": 3,
                        "reviews": [
                            {
                                "user": "Priya Verma",
                                "rating": 3,
                                "comment": "Decent laptop but a bit overpriced."
                            }
                        ]
                    }
                ]
            },
            {
                "id": 2,
                "name": "Clothing",
                "products": [
                    {
                        "id": 201,
                        "name": "T-shirt",
                        "description": "Comfortable cotton t-shirt available in various colors.",
                        "price": 25,
                        "stockStatus": "In Stock",
                        "image": "https://t3.ftcdn.net/jpg/03/34/79/68/360_F_334796865_VVTjg49nbLgQPG6rgKDjVqSb5XUhBVsW.jpg",
                        "rating": 3,
                        "reviews": [
                            {
                                "user": "Ankit Mehra",
                                "rating": 3,
                                "comment": "Good fit, but color faded after one wash."
                            }
                        ]
                    }
                ]
            },
            {
                "id": 3,
                "name": "Home Appliances",
                "products": [
                    {
                        "id": 301,
                        "name": "Air Conditioner",
                        "description": "Energy-efficient AC with smart controls.",
                        "price": 499,
                        "stockStatus": "In Stock",
                        "image": "https://static-assets.business.amazon.com/assets/in/24th-jan/705_Website_Blog_Appliances_1450x664.jpg.transform/1450x664/image.jpg",
                        "rating": 4,
                        "reviews": [
                            {
                                "user": "Sneha Iyer",
                                "rating": 4,
                                "comment": "Cools the room quickly and operates quietly."
                            }
                        ]
                    }
                ]
            }
        ]
    }

    arr = [];

    get options() {
        this.arr.push({ label: 'All', value: 'All' });
        this.jsn.categories.forEach(element => {
            console.log('name of category', element.name);
            console.log('category value', element.name);
            this.arr.push({ label: element.name, value: element.name });
        });
        return this.arr;
    }
    get Option() {
        console.log('chlra h dusra vala');

        return [{ label: 'All', value: 'All' },
        { label: 'Low To High', value: 'Low To High' },
        { label: 'High To Low', value: 'High To Low' }
        ];

    }
    Productarr = [];
    connectedCallback() {
        console.log('callback chala ');

        this.jsn.categories.forEach(element => {

            element.products.forEach(ele => {
                console.log('elementtt', ele);
                this.Productarr.push(ele);

            });
        });
        console.log('loop k bahar call back k under');
        console.log(this.Productarr);

    }
    category;
    Rating;
    Price;
    handleCategory(event) {
        console.log('event detail vaule', event.detail.value);

        this.category = event.detail.value;
    }
    handlePrice(event) {
        console.log('event detail vaule', event.detail.value);

        this.Price = event.detail.value;
    }
    handleRating(event) {
        console.log('event detail vaule', event.detail.value);

        this.Rating = event.detail.value;
    }

    applyFilters() {
        console.log('apply filter chla');

        let result = [];
        if (this.category != "All") {
            this.jsn.categories.forEach(element => {
                if(element.name == this.category){
                    element.products.forEach(pro =>{
                    result.push(pro)
                   })
                }
            
            });
        }else {
            console.log("elese");
            this.jsn.categories.forEach(element => {
                element.products.forEach(pro =>{
                    result.push(pro)
                })
            
            });
        }
        console.log(result);
         
       if ( this.Price !== 'All') {
            if (this.Price === 'Low To High') {
                result.sort((a, b) => a.price - b.price);
            } else if (this.Price === 'High To Low') {
                result.sort((a, b) => b.price - a.price);
            }
        }
         if(this.Rating != 'All'){
            console.log('inside the rating if not all')
            if (this.Rating === 'Low To High') {
                console.log('sort all low to high')
                result.sort((a, b) => a.rating - b.rating);
            } else if (this.Rating === 'High To Low') {
                 console.log('sort all high to low')
                result.sort((a, b) => b.rating - a.rating);
            }
         }
    

        this.Productarr = result;
    }




    showModal = false;
    selectedProduct = [];
    handleViewDetail(event) {
        let temp = event.target.value;
        console.log('json parsed and stringified', JSON.parse(JSON.stringify(temp)));

        this.selectedProduct = JSON.parse(JSON.stringify(temp));

        console.log('selected product', this.selectedProduct);
        this.showModal = true;
    }


    handleCloseModal() {
        this.showModal = false;
    }
}