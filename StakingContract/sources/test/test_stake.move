// #[test_only]
// module stakingContract::test_ticket {
//     use sui::test_scenario::{Self as ts, next_tx, Scenario};
//     use sui::coin::{Self, Coin, mint_for_testing};
//     use sui::sui::SUI;
//     use sui::tx_context::TxContext;
//     use sui::object::UID;
//     use sui::test_utils::{assert_eq};
//     use sui::clock::{Self, Clock};
//     use sui::transfer::{Self};

//     use std::vector;
//     use std::string::{Self, String};

//     use stakingContract::staking::{Self, AdminCap, Pool, AccountCap, test_init};
//     use stakingContract::mnt::{Self, MNT, CapWrapper};
//     use stakingContract::helpers::{Self, init_test_helper};

//     const ADMIN: address = @0xA;
//     const TEST_ADDRESS1: address = @0xB;
//     const TEST_ADDRESS2: address = @0xC;
//     const TEST_ADDRESS3: address = @0xD;
//     const TEST_ADDRESS4: address = @0xE; 
//     const TEST_ADDRESS5: address = @0xF;

  

//     #[test]

//     public fun test_deposit() {
//         let scenario_test = init_test_helper();
//         let scenario = &mut scenario_test;

//         helpers::new_accounts(scenario);

//         next_tx(scenario, TEST_ADDRESS1);
//         {
//             let pool = ts::take_shared<Pool>(scenario);
//             let account_cap = ts::take_from_sender<AccountCap>(scenario);
//             let clock = clock::create_for_testing(ts::ctx(scenario));
//             let coin = mint_for_testing<SUI>(1000_000_000_000, ts::ctx(scenario)); 

//             staking::deposit(&mut pool, coin, &clock, &account_cap);

//             let (balance, reward) = staking::account_balance(&pool, staking::account_owner(&account_cap));
//             assert_eq(balance, 1000000000000);
//             assert_eq(reward, 0);


//             clock::share_for_testing(clock);
//             ts::return_to_sender(scenario, account_cap);
//             ts::return_shared(pool);
//         };

//         next_tx(scenario, TEST_ADDRESS1); 
//         {
//             let pool = ts::take_shared<Pool>(scenario);
//             let account_cap = ts::take_from_sender<AccountCap>(scenario);
//             let clock = ts::take_shared<Clock>(scenario);
//             clock::increment_for_testing(&mut clock, 86400);
//             let amount: u64 = 1000_000_000_000;

//             let coin = staking::withdraw(&mut pool, &account_cap, &clock, amount, ts::ctx(scenario));
//             transfer::public_transfer(coin, TEST_ADDRESS1);

//             let (balance, reward) = staking::account_balance(&pool, staking::account_owner(&account_cap));
//             assert_eq(balance, 0);
//             assert_eq(reward, 86_400_000);


//             ts::return_shared(clock);
//             ts::return_to_sender(scenario, account_cap);
//             ts::return_shared(pool);


//         };

//         ts::end(scenario_test);
//     }

       
// }