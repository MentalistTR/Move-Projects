module final::Final_Project {

use std::string::{Self,String};
use sui::transfer;
use sui::object::{Self,UID,ID};
use sui::url::{Self,Url};
use sui::coin::{Self,Coin};
use sui::sui::SUI;
use sui::object_table::{Self,ObjectTable};
use sui::event;
use sui::tx_context::{Self,TxContext};

const NOT_THE_OWNER: u64 = 0;
const INSUFFICIENT_FUNDS: u64 = 1;
const MIN_CAR_COST: u64 = 2;
const CAR_FOR_NOT_SALE: u64 = 3;
const INVALID_VALUE: u64 = 4;

struct Car has key,store {
    id:UID,
    name:String,
    owner:address,
    model: String,
    year: u64,
    price: u64,
    img_url: Url,
    color:String,
    distance: u64,
    for_sale : bool,
  
}

struct Gallery has key,store{
    id:UID,
    owner: address,
    counter: u64,
    cars: ObjectTable<u64,Car>,
}

struct CarCreated has copy,drop{
    id:ID,
    name: String,
    owner:address,
    model: String,
    color:String,
}

struct CarUpdated has copy,drop {
    owner:address,
    year: u64,
    distance: u64,
    for_sale: bool,
    price:u64
}

struct CarSold has copy, drop {
    car_id: ID,
    seller:address,
    buyer: address,
    price: u64
}

struct CarDeleted has copy,drop {
    car_id: ID,
    owner: address,
    name: String,
    model: String,
}

 fun init(ctx: &mut TxContext) {
    transfer::share_object(
        Gallery {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            counter: 0,
            cars: object_table::new(ctx),
        }
    )
}

public entry fun create_Car(
    name: vector<u8>,
    model: vector<u8>,
    img_url:vector<u8>,
    year: u64,
    price:u64,
    color:vector<u8>,
    distance: u64,
    gallery: &mut Gallery,
    payment: Coin<SUI>,
    ctx:&mut TxContext,
  
) {
    assert!(price >0, INVALID_VALUE);
    transfer::public_transfer(payment,gallery.owner);
    gallery.counter = gallery.counter +1;
    let id = object::new(ctx);
   
    event::emit(
        CarCreated {
            id: object::uid_to_inner(&id),
            name: string::utf8(name),
            owner:tx_context::sender(ctx),
            model: string::utf8(model),
            color:string::utf8(color),
        }
    );

    let car = Car {
    id:id,
    name:string::utf8(name),
    owner: tx_context::sender(ctx),
    model:string::utf8(model),
    year,
    img_url:url::new_unsafe_from_bytes(img_url),
    color:string::utf8(color),
    distance,
    for_sale:true,
    price,
    };

    object_table::add(&mut gallery.cars,gallery.counter,car);
   
}

public entry fun update_car_property(
    car: &mut Car,
    year: u64,
    distance: u64,
    for_sale: bool,
    price:u64,
    user_address: address
) {
    let user_car = car;
    assert!(user_address == user_car.owner,NOT_THE_OWNER);

    user_car.year = year;
    user_car.distance = distance;
    user_car.for_sale = for_sale;
    user_car.price = price;

    event::emit (
        CarUpdated {
            year: user_car.year,
            owner:user_car.owner,
            distance: user_car.distance,
            for_sale: user_car.for_sale,
            price:user_car.price,
        }
    );
}

public entry fun notsale_car(gallery: &mut Gallery,id: u64, ctx: &mut TxContext) {
    let user_car = object_table::borrow_mut(&mut gallery.cars,id);
    assert!(tx_context::sender(ctx) == user_car.owner,NOT_THE_OWNER);
    user_car.for_sale = false;
}

public fun get_car_info(gallery: &Gallery,id:u64): (
     String,
     address,
     String,
     u64,
     Url,
     String,
     u64,
     bool,
     u64,
) {
    let car = object_table::borrow(&gallery.cars,id);
     (
        car.name,
        car.owner,
        car.model,
        car.year,
        car.img_url,
        car.color,
        car.distance,
        car.for_sale,
        car.price,
     ) 
}

public entry fun buy_car(
    gallery: &mut Gallery,
    car_id: u64,
    payment: Coin<SUI>,
    ctx:&mut TxContext
) {
    let car = object_table::remove(&mut gallery.cars,car_id);

    // gallery.counter = gallery.counter -1;
    
    assert!(car.for_sale,   CAR_FOR_NOT_SALE);

    // let payment_amount = coin::value(&payment);
    // assert!(payment_amount == car.price,INSUFFICIENT_FUNDS);

    let buyer = tx_context::sender(ctx);
    let seller = car.owner;
    car.owner = buyer;
    car.for_sale = false;

    let car_id = object::uid_to_inner(&car.id);
    let car_price = car.price;

    transfer::public_transfer(payment, seller);
    transfer::public_transfer(car, buyer);
    
    event::emit(
        CarSold {
          car_id: car_id,
            seller: seller,
            buyer: buyer,
            price: car_price,
        }
    );
}

public entry fun add_car_to_gallery(
    gallery: &mut Gallery,
    car: Car,
    ctx: &mut TxContext
) {
 
    assert!(car.owner == tx_context::sender(ctx), NOT_THE_OWNER);
    gallery.counter = gallery.counter +1;
    object_table::add(&mut gallery.cars, gallery.counter, car);
}

public entry fun delete_car(
    car: Car,
    gallery: &mut Gallery,
    ctx: &mut TxContext,

) {
 assert!(tx_context::sender(ctx) == car.owner,NOT_THE_OWNER);

// if(car.for_sale == true) {
//    gallery.counter = gallery.counter -1;
// };

    event:: emit (
        CarDeleted {
            car_id: object::uid_to_inner(&car.id),
            owner: car.owner,
            name:  car.name,
            model: car.model,
        }
    );

    let Car { id, name: _, owner:_, model:_, year:_, img_url:_, color:_, distance:_, for_sale:_, price:_} = car;
    object::delete(id);
}

 public fun  get_owner(gallery: &Gallery): address {
    gallery.owner
}

 public fun get_counter(gallery: &Gallery): u64{
    gallery.counter
}

 public fun get_car(gallery: &Gallery, car_id: u64): &Car {
    object_table::borrow(&gallery.cars, car_id)
}

public fun get_car_single(car:&Car) : (String, address, String, u64, Url, String, u64, bool, u64) {
    (
        car.name,
        car.owner,
        car.model,
        car.year,
        car.img_url,
        car.color,
        car.distance,
        car.for_sale,
        car.price,
    )
}


#[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx); 
}

}
