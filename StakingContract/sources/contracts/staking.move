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

    use stakingContract::mnt::{MNT, CapWrapper, mint};

    // === Errors ===

    const ERROR_INSUFFICENT_COIN: u64 = 0;
    const ERROR_INVALID_QUANTITIY: u64 = 1;

    // === Constants ===

    // === Structs ===

    // Protocol pool to users can stake SUI
    struct Pool has key, store {
       id: UID,
       account_balances: Table<address, Account>,
       interest: u64
    }

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

    //Admin capability
    struct AdminCap has key {
        id: UID
    }

    // =================== Initializer ===================

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Pool{
            id:object::new(ctx),
            account_balances: table::new(ctx),
            interest:1
        });

        transfer::transfer(AdminCap{id: object::new(ctx)}, sender(ctx));
    }

    // === Public-Mutative Functions ===

    // users should create an account for themself
    public fun new_account(ctx: &mut TxContext) {
        transfer::public_transfer(create_account(ctx), sender(ctx))
    }
    // deposit SUI for stake
    public fun deposit(pool: &mut Pool, coin: Coin<SUI>, clock: &Clock, account_cap: &AccountCap)  {
        deposit_pool( pool, coin, clock, account_cap);
    }
    // withdraw Sui from stake
    public fun withdraw(
        pool: &mut Pool,
        quantity: u64,
        account_cap: &AccountCap,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(quantity > 0, ERROR_INVALID_QUANTITIY);
        withdraw_asset(pool, quantity, account_cap, clock, ctx)
    }
    // users can withdraw rewards
    public fun withdraw_reward(
        pool: &mut Pool,
        account_cap: &AccountCap,
        capwrapper: &mut CapWrapper,
        clock: &Clock,
        ctx: &mut TxContext
    ) :Coin<MNT> {
        let rewards_ = calculateReward_withdraw(pool, clock, account_cap.owner);
        let coin = mint(capwrapper,rewards_, ctx);
        coin
    }


    // === Public-View Functions ===

    // return the user balance and reward
    public(friend) fun account_balance(
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


    // === Admin Functions ===

    // admin can change the rate
    public fun update_interest(_:&AdminCap, pool: &mut Pool, rate: u64) {
        pool.interest = rate;
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
            account_owner(account_cap),
            coin::into_balance(coin),
            clock
        );
    }

    public fun withdraw_asset(
        pool: &mut Pool,
        quantity: u64,
        account_cap: &AccountCap,
        clock: &Clock,
        ctx: &mut TxContext
    ): Coin<SUI> {
        coin::from_balance(decrease_user_available_balance(pool, account_cap, quantity, clock), ctx)
    }

    /// Return the owner of an AccountCap
    public fun account_owner(account_cap: &AccountCap): address {
        account_cap.owner
    }

    public fun create_account(ctx: &mut TxContext) : AccountCap {
        let id = object::new(ctx);
        let owner = object::uid_to_address(&id);
        AccountCap { id, owner }
    }

    // === Private Functions ===

    fun increase_user_available_balance(
        pool: &mut Pool,
        owner: address,
        quantity: Balance<SUI>,
        clock: &Clock
    ) {
        calculateReward(pool, clock, owner);
        let account = borrow_mut_account_balance(pool, owner, clock);
        balance::join(&mut account.balance, quantity);
    }

    fun decrease_user_available_balance(
        pool: &mut Pool,
        account_cap: &AccountCap,
        quantity: u64,
        clock: &Clock
    ): Balance<SUI> {
        calculateReward(pool, clock, account_cap.owner);
        let account = borrow_mut_account_balance(pool, account_cap.owner, clock);
        balance::split(&mut account.balance, quantity)
    }

    fun borrow_mut_account_balance(
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

    fun calculateReward(pool: &mut Pool , clock: &Clock, owner: address) : u64 {
        let interest = pool.interest / 10000;
        let account = borrow_mut_account_balance(pool, owner, clock);
        let duration_ = timestamp_ms(clock) - account.duration;
        let reward_ = (balance::value(&account.balance)) * (duration_) * (interest);
        account.duration = timestamp_ms(clock);
        account.rewards = account.rewards + reward_;
        account.rewards
    }

    fun calculateReward_withdraw(pool: &mut Pool , clock: &Clock, owner: address) : u64 {
        let interest = pool.interest / 10000;
        let account = borrow_mut_account_balance(pool, owner, clock);
        let duration_ = timestamp_ms(clock) - account.duration;
        let reward_ = (balance::value(&account.balance)) * (duration_) * (interest);
        account.duration = timestamp_ms(clock);
        account.rewards = account.rewards + reward_;
        let mint = account.rewards;
        assert!(mint > 0, ERROR_INVALID_QUANTITIY);
        account.rewards = 0;
        mint
    }
    
    // === Test Functions ===
    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }

}
