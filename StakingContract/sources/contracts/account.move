module stakingContract::account {

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
    // === Errors ===

    const ERROR_INSUFFICENT_COIN: u64 = 0;
    const ERROR_INVALID_QUANTITIY: u64 = 1;

    // === Constants ===

    friend stakingContract::reward;
    friend stakingContract::staking;
    friend stakingContract::test_stake;
    friend stakingContract::admin;

    // === Structs ===
    
    struct Account has store {
       balance: Balance<SUI>,
       rewards: u64, 
       duration: u64 
    }

    struct AccountCap has key, store {
        id: UID,
        /// The owner of this AccountCap. Note: this is
        /// derived from an object ID, not a user address
        owner: address
    }

    // Protocol pool to users can stake SUI
    struct Pool has key, store {
       id: UID,
       account_balances: Table<address, Account>,
       interest: u128
    }

    public fun get_duration(account: &Account) : u64 {
        account.duration
    }

    public fun get_balance(account: &Account) : u64 {
        balance::value(&account.balance)
    }

    public fun get_rewards(account: &Account) : u64 {
        account.rewards
    }

    public fun get_account_cap(account: &AccountCap) : address {
        account.owner
    }

    public fun borrow_pool(pool: &Pool) : &Pool {
        pool
    }

    public fun get_interest(pool: &Pool) : u128 {
        pool.interest
    }

    public(friend) fun borrow_mut_pool(pool: &mut Pool) : &mut Pool {
        pool
    }

    public(friend) fun new_interest(pool: &mut Pool, num: u128) {
        pool.interest = num;
    }

    public fun set_account(account: &mut Account, duration_: u64, reward: u64) {
        account.duration = duration_;
        account.rewards = account.rewards + reward;
    }

    public fun set_reward(account: &mut Account) {
        account.rewards = 0;
    }

    /// Return the owner of an AccountCap
    public(friend) fun account_owner(account_cap: &AccountCap): address {
        account_cap.owner
    }

    public(friend) fun create_account(ctx: &mut TxContext) : AccountCap {
        let id = object::new(ctx);
        let owner = object::uid_to_address(&id);
        AccountCap { id, owner }
    }

    // create new pool 
    public fun new(ctx: &mut TxContext) : Pool {
        let pool = Pool{
            id:object::new(ctx),
            account_balances: table::new(ctx),
            interest:10
            };
        pool
    }

    // return the user balance and reward
    public fun account_balance(
        pool: &Pool,
        owner: address
    ): (u64, u64) {
        // if the account is not created yet, directly return (0, 0) rather than abort
        if (!table::contains(&pool.account_balances, owner)) {
            return (0, 0)
        };
        let account_balances = table::borrow(&pool.account_balances, owner);
        let avail_balance = balance::value(&account_balances.balance);
        let reward = account_balances.rewards;
        (avail_balance, reward)
    }

    public(friend) fun  borrow_mut_account(
        pool: &mut Pool,
        owner: address,
        clock: &Clock,
    ): &mut Account {
        if (!table::contains(&pool.account_balances, owner)) {
            table::add(
                &mut pool.account_balances,
                owner,
                Account { balance: balance::zero(), rewards: 0, duration: timestamp_ms(clock) }
            );
        };
         table::borrow_mut(&mut pool.account_balances, owner)
      
    }

    public(friend) fun  borrow_mut_account_balance(
        pool: &mut Pool,
        owner: address,
        clock: &Clock,
    ): &mut Balance<SUI> {
        if (!table::contains(&pool.account_balances, owner)) {
            table::add(
                &mut pool.account_balances,
                owner,
                Account { balance: balance::zero(), rewards: 0, duration: timestamp_ms(clock) }
            );
        };
        let account = table::borrow_mut(&mut pool.account_balances, owner);
        &mut account.balance
    }
}
