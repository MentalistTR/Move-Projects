/// LIRA Token is the stabil coin for turkish goverment lira
module stakingContract::reward {

    // === Imports ===
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::balance::{Self, Balance};
    use sui::clock::{Clock, timestamp_ms};
    use sui::sui::{SUI};

    use std::debug;

    use stakingContract::mnt::{MNT, CapWrapper, mint};
    use stakingContract::account::{Self, Pool, Account};

    friend stakingContract::staking;

    // === Errors ===

    const ERROR_INSUFFICENT_COIN: u64 = 0;
    const ERROR_INVALID_QUANTITIY: u64 = 1;


    public(friend) fun calculateReward(pool: &mut Pool , clock: &Clock, owner: address) : u64 {
        let interest = account::get_interest(pool);
        let account = account::borrow_mut_account_balance(pool, owner, clock);
        let duration_ = timestamp_ms(clock) - account::get_duration(account);
        //debug::print(&duration_);
        let balance = account::get_balance(account);
        // debug::print(&balance);
        let reward = ((balance as u128) * (duration_ as u128) as u64);
        let reward_ = (((reward as u128) * interest / 1_00_000_000_000) as u64);
        //debug::print(&reward_);
        account::set_account(account, timestamp_ms(clock), reward_);
        account::get_rewards(account)
    }

    public(friend) fun calculateReward_withdraw(pool: &mut Pool , clock: &Clock, owner: address) : u64 {
        let interest = account::get_interest(pool);
        let account = account::borrow_mut_account_balance(pool, owner, clock);
        let duration_ = timestamp_ms(clock) - account::get_duration(account);
        //debug::print(&duration_);
        let balance = account::get_balance(account);
        let reward = ((balance as u128) * (duration_ as u128) as u64);
        let reward_ = (((reward as u128) * interest / 1_00_000_000_000) as u64);
       // debug::print(&reward_);
        account::set_account(account, timestamp_ms(clock), reward_);
        let mint =  account::get_rewards(account);
        assert!(mint > 0, ERROR_INVALID_QUANTITIY);
        account::set_reward(account);
        mint
    }
}
