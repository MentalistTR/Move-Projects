/// LIRA Token is the stabil coin for turkish goverment lira
module stakingContract::staking {

    // === Imports ===
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext, sender};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::balance::{Self, Balance};
    use sui::clock::{Clock, timestamp_ms};
    use sui::sui::{SUI};

    use std::debug;

    use stakingContract::mnt::{MNT, CapWrapper, mint};
    use stakingContract::account::{Self, Account, AccountCap, Pool};
    use stakingContract::reward::{Self, calculateReward, calculateReward_withdraw};
    // === Errors ===

    const ERROR_INSUFFICENT_COIN: u64 = 0;
    const ERROR_INVALID_QUANTITIY: u64 = 1;


    // === Public-Mutative Functions ===

    // users should create an account for themself
    public fun new_account(ctx: &mut TxContext) {
        transfer::public_transfer(account::create_account(ctx), sender(ctx))
    }
    // deposit SUI for stake
    public fun deposit(pool: &mut Pool, coin: Coin<SUI>, clock: &Clock, account_cap: &AccountCap)  {
        deposit_pool( pool, coin, clock, account_cap);
    }
    // withdraw Sui from stake
    public fun withdraw(
        pool: &mut Pool,
        account_cap: &AccountCap,
        clock: &Clock,
        quantity: u64,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(quantity > 0, ERROR_INVALID_QUANTITIY);
        withdraw_asset(pool, account_cap, clock, quantity, ctx)
    }
    // users can withdraw rewards
    public fun withdraw_reward(
        pool: &mut Pool,
        account_cap: &AccountCap,
        capwrapper: &mut CapWrapper,
        clock: &Clock,
        ctx: &mut TxContext
    ) :Coin<MNT> {
        let rewards_ = calculateReward_withdraw(pool, clock, account::get_account_cap(account_cap));
        let coin = mint(capwrapper,rewards_, ctx);
        coin
    }
 
    // === Helper Functions ===

    public fun deposit_pool(
        pool: &mut Pool,
        coin: Coin<SUI>,
        clock: &Clock,
        account_cap: &AccountCap
    ) {
        let quantity = coin::value(&coin);
        assert!(quantity != 0, ERROR_INSUFFICENT_COIN);
        increase_user_available_balance(
            pool,
            account::account_owner(account_cap),
            coin::into_balance(coin),
            clock
        );
    }

    public fun withdraw_asset(
        pool: &mut Pool,
        account_cap: &AccountCap,
        clock: &Clock,
        quantity: u64,
        ctx: &mut TxContext
    ): Coin<SUI> {
        coin::from_balance(decrease_user_available_balance(pool, account_cap, quantity, clock), ctx)
    }

    // === Private Functions ===

    fun increase_user_available_balance(
        pool: &mut Pool,
        owner: address,
        quantity: Balance<SUI>,
        clock: &Clock
    ) {
        calculateReward(pool, clock, owner);
        let account = account::borrow_mut_account_balance2(pool, owner, clock );
        balance::join( account, quantity);
    }

    fun decrease_user_available_balance(
        pool: &mut Pool,
        account_cap: &AccountCap,
        quantity: u64,
        clock: &Clock
    ): Balance<SUI> {
        calculateReward(pool, clock, account::get_account_cap(account_cap));
        let account = account::borrow_mut_account_balance2(pool, account::get_account_cap(account_cap), clock );
        balance::split( account, quantity)
    }
}
