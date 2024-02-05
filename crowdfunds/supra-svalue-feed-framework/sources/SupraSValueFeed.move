module SupraOracle::SupraSValueFeed {
    
use sui::tx_context::{Self,TxContext};
use sui::transfer;
use sui::object::{Self,UID,ID};
use std::vector;


    struct OracleHolder has key, store {
        id: sui::object::UID,
    }
    struct Price has drop {
        pair: u32,
        value: u128,
        decimal: u16,
        timestamp: u128,
        round: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(
            OracleHolder {
            id:object::new(ctx),
            }
        )
    }
    
     public fun get_price(_oracle_holder: &OracleHolder, _pair: u32) : (u128, u16, u128, u64) {
          let price: u128 = 1_000000000; 
          let confidence_score: u16 = 1; 
          let last_updated: u128 = 1; 
          let data_source: u64 = 1; 
        
          (price, confidence_score, last_updated, data_source)
     }
    
    public fun get_prices(_oracle_holder: &OracleHolder, _pairs: vector<u32>) : vector<Price> {
    let  prices: vector<Price> = vector::empty();

    let length = vector::length(&_pairs);
    let  i = 0;

    while (i < length) {
         let pair = vector::borrow(&_pairs, i);

        let price = Price {
            pair: *pair, 
            value: 2000000000, 
            decimal: 9, 
            timestamp: 50, 
            round: 5 
        };
        vector::push_back(&mut prices, price);
        i = i + 1;
    };
    prices
   }

    public fun extract_price(price: &Price): (u32, u128, u16, u128, u64) {
    (
        price.pair,
        price.value,
        price.decimal,
        price.timestamp,
        price.round
    )
}
    #[test_only]
    public fun init_for_testing_supra(ctx: &mut TxContext) {
    init(ctx); 
    
}

}