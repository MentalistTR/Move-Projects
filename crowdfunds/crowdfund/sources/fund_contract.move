module crowdfund::fund_contract {
    
use SupraOracle::SupraSValueFeed::{get_price, get_prices, OracleHolder};
use sui::transfer;
use sui:: tx_context:: {Self, TxContext};
use sui::coin:: {Self, Coin};
use sui::balance:: {Self, Balance};
use sui::sui::SUI;
use sui::event;
use sui::object::{Self,UID,ID};

const EnotFundOwner: u64 = 0;
// The Fund Object 

struct Fund has key {
    id: UID,
    target: u64,
    raised: Balance <SUI>,
}

struct Receipt has key {
    id: UID,
    amount_donated: u64,    
}

struct FundOwnerCap has key {
    id: UID,
    fund_id: ID,
}

struct TargetReached has copy,drop {
    raised_amount_sui: u128,
}

// Functions 

// The create_fund function 

public entry fun create_fund(target: u64, ctx: &mut TxContext) {
    let fund_uid = object::new(ctx);
    let fund_idd = object::uid_to_inner(&fund_uid); 
    // Use fund_uid directly if it's of type sui::object::UID
    let fund = Fund {
        id: fund_uid,
        target: target, // Use the 'target' parameter from the function
        raised: balance::zero(),
    };
    // create and send a fund owner capability for the creator 
    transfer::transfer(FundOwnerCap {
        id: object::new(ctx),
        fund_id: fund_idd,  // Assuming 'fund_uid' holds the actual UID value
    }, tx_context::sender(ctx));

    transfer::share_object(fund);
}

// // The donate function 

public entry fun donate(oracle_holder: &OracleHolder, fund: &mut Fund, amount: Coin<SUI>, ctx: &mut TxContext) {
      
      // get the amount beign donated in SUI for receipt 
      let amount_donated: u64 = coin::value(&amount);

      // add the amount to the fund's balance 
      let coin_balance: Balance<SUI> = coin::into_balance(amount);

      balance::join(&mut fund.raised, coin_balance);

   // get the price of SUI_USDT using Supra's Oracle SValueFeed
      let (price, _, _, _) = get_price(oracle_holder, 90);


    //   //adjust price to have the same number of decimal places as SUI
       let adjusted_price = price / 1000000000; 
      
    //   // get the total raised amount so far in SUI
      let raised_amount_sui = (balance::value(&fund.raised) as u128);

    //   // get the fund target amount in USD 
       let fund_target_usd = (fund.target as u128) * 1000000000;

      
     // check if the fund target in USD has been rached (by the amount donated in SUI)
       if((raised_amount_sui * adjusted_price) >= fund_target_usd) {
        event::emit(TargetReached{raised_amount_sui});
       };

      let receipt: Receipt = Receipt {
        id:object:: new(ctx),
        amount_donated,
      };

      transfer::transfer(receipt, tx_context::sender(ctx));

}

// // withdraw funds from the fund contract, requires a FundOwnerCap that matches the fund id 

public entry fun withdraw_funds(cap: &FundOwnerCap, fund: &mut Fund, ctx: &mut TxContext) {

   assert!(&cap.fund_id == object::uid_as_inner(&fund.id), EnotFundOwner);


    let amount: u64 = balance::value(&fund.raised);

    let raised: Coin<SUI> = coin::take(&mut fund.raised, amount, ctx);

    transfer::public_transfer(raised, tx_context::sender(ctx));

}

    public fun get_target(fund: &Fund): u64 {
        fund.target
    }

    public fun get_raised(fund: &Fund): u64 {
        balance::value(&fund.raised)
    }

}