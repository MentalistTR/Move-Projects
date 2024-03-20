module BusTicket::ticket {

    // === Imports ===

    use std::string::{Self, String};
    use std::vector;
    //use std::debug;

    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;
    use sui::tx_context::{Self, TxContext, sender};
    use sui::table::{Self, Table};
    use sui::balance:: {Self, Balance};

    // === Friends ===

    // =================== Errors ===================

    // === Constants ===

    // === Structs ===

    //share object that we keep ticket price 
    struct Station has key, store {
        id: UID,
        balance: Balance<SUI>,
        consolidation: Table<String, Table<String, ID>>
    }

    // share object that users can see property of consolidation
    struct Bus has key, store {
        id: UID,
        owner: ID,
        from: String,
        to: String,
        seed: vector<address>,
        price: u64,
        start: u64,
        send: u64
    }

    struct Ticket has store, copy, drop {
        bus: ID,
        owner: address,
        launch_time: u64,
        seed_no: u64
    }

    struct AdminCap has key {
        id: UID

    }

    // =================== Events ===================

    struct BusCreated has copy, drop {
        owner: ID,
        from: String,
        to: String,
        seed: vector<address>,
        price: u64,
        start: u64,
        send: u64
    }


    // =================== Initializer ===================    

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Station{
            id: object::new(ctx),
            balance: balance::zero(),
            consolidation: table::new<String, Table<String, ID>>(ctx)
        });

        transfer::transfer(AdminCap{id: object::new(ctx)}, sender(ctx));
    }

    // === Public-Mutative Functions ===

    // owner of station should create new bus 
    public fun new() {

    }

    // Users can buy tickets
    public fun buy() {

    }
    // Users can rebate tickets before an hour 
    public fun rebate() {

    }

    // return the available tickets from bus 
    public fun get_tickets() {

    }

  







 

    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===





































}