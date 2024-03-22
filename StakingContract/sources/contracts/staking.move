/// LIRA Token is the stabil coin for turkish goverment lira
module stakingContract::staking {

    // === Imports ===
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext, sender};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::table::{Self, Table};
    use sui::balance::{Self, Balance};
    use sui::sui::{SUI};

    use stakingContract::mnt::{MNT};

    // === Friends ===

    // === Errors ===

    // === Constants ===

    // === Structs ===

    // Protocol pool to users can stake SUI
    struct Pool has key, store {
       id: UID,
       account_balances: Table<address, Account>,
       interest: u64
    }

    struct Account has store {
       balance: u64,
       rewards: u64  
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
        transfer::transfer(AdminCap{id: object::new(ctx)}, sender(ctx));
    }


    // === Public-Mutative Functions ===

    public fun deposit()  {



    }

    public fun withdraw() {



    }

    public fun withdraw_reward() {



    }
























    // === Public-View Functions ===



    // === Admin Functions ===

    public fun update_interest() {

    }

    // === Public-Friend Functions ===

    // === Private Functions ===

    fun updateReward() {




    }

    fun calculateReward() {


    }

    // === Test Functions ===











}