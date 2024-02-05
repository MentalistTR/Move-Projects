#[test_only]

module crowdfund::crypto_index_fund_test {

 use SupraOracle::SupraSValueFeed::{get_price, get_prices,OracleHolder,init_for_testing_supra};
 use sui::test_scenario as ts;
 use crowdfund::crypto_index_fund as cf;
 use crowdfund::crypto_index_fund::{init_for_testing,IndexFund,IndexFundToken};
 use sui::coin::{Self,Coin,mint_for_testing};
 use sui::sui::SUI;
 use sui::tx_context::TxContext;
 use sui::object::UID;
 use sui::balance;
 use sui::table;
 
#[test]
// #[expected_failure(abort_code = table::borrow::ERROR_UNAUTHORIZED)]
  
   fun create_fund_test()  { 

   let owner: address = @0xA;
   let user1: address = @0xB;
   let user2: address = @0xC;

   let scenario_test = ts::begin(owner);
   let scenario = &mut scenario_test;

   ts::next_tx(scenario,owner); 

   {
     init_for_testing_supra(ts::ctx(scenario));
     init_for_testing(ts::ctx(scenario));

   };

   ts::next_tx(scenario,user1); 
   { 
      let index_fund = ts::take_shared<IndexFund>(scenario);
      ts::return_shared(index_fund);
   };
   
   ts::next_tx(scenario,user1);
   { 
     let oracle_holder = ts::take_shared<OracleHolder>(scenario);
     let index_fund = ts::take_shared<IndexFund>(scenario);
     let deposit_amount = mint_for_testing<SUI>(1000_000000000,ts::ctx(scenario));

     cf::deposit_investment(&oracle_holder,&mut index_fund,deposit_amount,ts::ctx(scenario));

     ts::return_shared(oracle_holder);
     ts::return_shared(index_fund);
   };

     ts::next_tx(scenario,user1); 
     {
     let index_fund = ts::take_from_sender<IndexFundToken>(scenario);
     let crypto_assets_ref  = cf::get_index_fund_token(&index_fund);

     let value1 = table::borrow(crypto_assets_ref,10);
     
     let value2 = table::borrow(crypto_assets_ref,1);
     let value3 = table::borrow(crypto_assets_ref,14);
     let value4 = table::borrow(crypto_assets_ref,16);
     let value5 = table::borrow(crypto_assets_ref,20);

     let expected_value2 =100_000000000;

      assert!(value1 == &expected_value2,0);
      assert!(value2 == &expected_value2,0);
      assert!(value3 == &expected_value2,0);
      assert!(value4 == &expected_value2,0);
      assert!(value5 == &expected_value2,0);

    ts::return_to_sender(scenario,index_fund);

     };

     ts::next_tx(scenario,user1);
     {
     let oracle_holder = ts::take_shared<OracleHolder>(scenario);
     let index_fund = ts::take_shared<IndexFund>(scenario);
     let index_fund_token = ts::take_from_sender<IndexFundToken>(scenario);
    
     cf::withdraw_investment(&oracle_holder,&mut index_fund,index_fund_token,ts::ctx(scenario));

     ts::return_shared(oracle_holder);
     ts::return_shared(index_fund);
     //ts::return_to_sender(scenario,index_fund_token);
     };

    // // we are expecting here EEmptyInventory error. 
    //  ts::next_tx(scenario,user1);
    //  {
    //  let index_fund = ts::take_from_sender<IndexFundToken>(scenario);
    //  let crypto_assets_ref  = cf::get_index_fund_token(&index_fund);

    //  let value1 = table::borrow(crypto_assets_ref,10);

    //  ts::return_to_sender(scenario,index_fund);
    //  };

   ts::end(scenario_test);
   }
   }