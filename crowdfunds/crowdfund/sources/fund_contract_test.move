// #[test_only]

// module crowdfund::fund_contract_test {

//  use SupraOracle::SupraSValueFeed::{get_price, get_prices,OracleHolder,init_for_testing_supra};
//  use sui::test_scenario as ts;
//  use crowdfund::fund_contract as fc;
//  use crowdfund::fund_contract::{Fund,FundOwnerCap};
//  use sui::coin::{Self,Coin,mint_for_testing};
//  use sui::sui::SUI;
//  use sui::tx_context::TxContext;
//  use sui::object::UID;
//  use sui::balance;

// #[test]
   
//    fun create_fund_test()  { 

//    let owner: address = @0xA;
//    let user1: address = @0xB;
//    let user2: address = @0xC;

   
//    let scenario_test = ts::begin(owner);
//    let scenario = &mut scenario_test;

//    ts::next_tx(scenario,owner);

//    {
//    init_for_testing_supra(ts::ctx(scenario));
//    };

//    ts::next_tx(scenario,user1);
//    {
//      let target: u64 = 100000;
//      fc::create_fund(target,ts::ctx(scenario));
//    };

//    ts::next_tx(scenario,user1);
//    {
//      let target: u64 = 100000;
//      let fund = ts::take_shared<Fund>(scenario);

//      let fund_target = fc::get_target(&fund);
//         assert!(fund_target == target, 0);

//      let fund_raised = fc::get_raised(&fund);
//         assert!(fund_raised == 0, 0);


//      let fund_owner_cap = ts::take_from_sender<FundOwnerCap>(scenario);
//      ts::return_to_sender(scenario,fund_owner_cap);
//      ts::return_shared(fund);
//    };
   
//    ts::next_tx(scenario,user2);
//    {
//    let fund = ts::take_shared<Fund>(scenario);
//    let oracle_holder = ts::take_shared<OracleHolder>(scenario);
//    let donation_amount = mint_for_testing<SUI>(1000,ts::ctx(scenario));
  
//    fc::donate(&oracle_holder, &mut fund, donation_amount,ts::ctx(scenario));

//    let fund_raised = fc::get_raised(&fund);
//    assert!(fund_raised == 1000 , 0);

//    ts::return_shared(oracle_holder);
//    ts::return_shared(fund);
//    };

//    ts::next_tx(scenario,user1);

//    {
//     let fund_owner_cap = ts::take_from_sender<FundOwnerCap>(scenario);
//     let fund = ts::take_shared<Fund>(scenario);


//    fc::withdraw_funds(&fund_owner_cap,&mut fund,ts::ctx(scenario));

//    let fund_raised = fc::get_raised(&fund);
//    assert!(fund_raised == 0 , 0);

//    ts::return_to_sender(scenario,fund_owner_cap);
//    ts::return_shared(fund);
//    };

//    ts::end(scenario_test);
//    }

// }