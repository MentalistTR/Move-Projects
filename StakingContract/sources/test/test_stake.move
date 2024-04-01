#[test_only]
module stakingContract::test_stake {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::coin::{Self, Coin, mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self, Clock};
    use sui::transfer::{Self};

    use std::vector;
    use std::string::{Self, String};

    use stakingContract::account::{Self, Account, AccountCap, Pool};
    use stakingContract::mnt::{Self, MNT, CapWrapper};
    use stakingContract::staking::{Self};

    use stakingContract::helpers::{Self, init_test_helper};

    const ADMIN: address = @0xA;
    const ALICE: address = @0xB;

    #[test]
    public fun test_deposit() {
        let scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        helpers::new_accounts(scenario);

        next_tx(scenario, ADMIN);
        {
            let pool = account::new(ts::ctx(scenario));
            transfer::public_share_object(pool);
        };
        // deposit 1000 SUI
        next_tx(scenario, ALICE);
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = clock::create_for_testing(ts::ctx(scenario));
            let coin = mint_for_testing<SUI>(1000_000_000_000, ts::ctx(scenario)); 

            staking::deposit(&mut pool, coin, &clock, &account_cap);

            let (balance, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance, 1000_000_000_000);
            assert_eq(reward, 0);

            clock::share_for_testing(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };
        // Withdraw SUI
        next_tx(scenario, ALICE); 
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = ts::take_shared<Clock>(scenario);
            // increment the time 1 day
            clock::increment_for_testing(&mut clock, 86400);
            let amount: u64 = 1000_000_000_000;

            let coin = staking::withdraw(&mut pool, &account_cap, &clock, amount, ts::ctx(scenario));
            transfer::public_transfer(coin, ALICE);

            let (balance, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance, 0);
            assert_eq(reward, 2_737_909_262);

            ts::return_shared(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };
        // withdraw the reward Token MNT
        next_tx(scenario, ALICE);
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = ts::take_shared<Clock>(scenario);
            let capwrapper = ts::take_shared<CapWrapper>(scenario);

            let coin = staking::withdraw_reward(&mut pool, &account_cap, &mut capwrapper, &clock, ts::ctx(scenario));
            assert_eq(coin::value(&coin), 2_737_909_262);
            transfer::public_transfer(coin, ALICE);

            ts::return_shared(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
            ts::return_shared(capwrapper);
        };
        // check the balance 
        next_tx(scenario, ALICE);
        {

            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);

            let balance = ts::take_from_sender<Coin<MNT>>(scenario);
            assert_eq(coin::value(&balance), 2_737_909_262);

            let (balance_, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance_, 0);
            assert_eq(reward, 0);

            ts::return_to_sender(scenario, balance);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };
        // deposit 100000 SUI 
        next_tx(scenario, ALICE);
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = ts::take_shared<Clock>(scenario);
            let coin = mint_for_testing<SUI>(100000_000_000_000, ts::ctx(scenario)); 

            staking::deposit(&mut pool, coin, &clock, &account_cap);

            let (balance, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance, 100000_000_000_000);
            assert_eq(reward, 0);

            ts::return_shared(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };

        // Withdraw 100000 SUI
        next_tx(scenario, ALICE); 
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = ts::take_shared<Clock>(scenario);
            // increment the time 1 day
            clock::increment_for_testing(&mut clock, 86400 * 12);
            let amount: u64 = 100000_000_000_000;

            let coin = staking::withdraw(&mut pool, &account_cap, &clock, amount, ts::ctx(scenario));
            transfer::public_transfer(coin, ALICE);

            let (balance, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance, 0);
            assert_eq(reward, 3285_491_115_325);

            ts::return_shared(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };

        // withdraw the reward Token MNT
        next_tx(scenario, ALICE);
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);
            let clock = ts::take_shared<Clock>(scenario);
            let capwrapper = ts::take_shared<CapWrapper>(scenario);

            let coin = staking::withdraw_reward(&mut pool, &account_cap, &mut capwrapper, &clock, ts::ctx(scenario));
            assert_eq(coin::value(&coin), 3285_491_115_325);
            transfer::public_transfer(coin, ALICE);

            ts::return_shared(clock);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
            ts::return_shared(capwrapper);
        };

         // check the balance 
        next_tx(scenario, ALICE);
        {
            let pool = ts::take_shared<Pool>(scenario);
            let account_cap = ts::take_from_sender<AccountCap>(scenario);

            let balance = ts::take_from_sender<Coin<MNT>>(scenario);
            assert_eq(coin::value(&balance), 3285_491_115_325);

            let (balance_, reward) = account::account_balance(&pool, account::account_owner(&account_cap));
            assert_eq(balance_, 0);
            assert_eq(reward, 0);

            ts::return_to_sender(scenario, balance);
            ts::return_to_sender(scenario, account_cap);
            ts::return_shared(pool);
        };
        ts::end(scenario_test);
    }   
}
