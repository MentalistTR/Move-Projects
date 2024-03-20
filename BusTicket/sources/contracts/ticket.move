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
    use sui::table_vec::{Self, TableVec};
    use sui::bag::{Self, Bag};
    use sui::balance:: {Self, Balance};
    use sui::clock::{Clock, timestamp_ms};

    // === Friends ===

    // =================== Errors ===================

    // === Constants ===

    // === Structs ===

    //share object that we keep ticket price 
    struct Station has key, store {
        id: UID,
        balance: Balance<SUI>,
        consolidation: Table<String, Bag>
    }

    // share object that users can see property of consolidation
    struct Bus has key, store {
        id: UID,
        owner: ID,
        from: String,
        to: String,
        seed_num: u8,
        seed: TableVec<address>,
        price: u64,
        start: u64,
        end: u64
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
            consolidation: table::new<String, Bag>(ctx)
        });

        transfer::transfer(AdminCap{id: object::new(ctx)}, sender(ctx));
    }

    // === Public-Mutative Functions ===

    // owner of station should create new bus 
    public fun new(
        _: &AdminCap,
        station: &mut Station,
        seeds: u8,
        from_: String,
        to_: String,
        price_: u64,
        start_: u64,
        end_: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let id_ = object::new(ctx);
        let inner_ = object::uid_to_inner(&id_);
        // check is the from_ avaliable in the table
        if(!table::contains(&station.consolidation, from_)) {
            // create a new bag
            let bag_ = bag::new(ctx);
            // add bag to the table
            table::add(&mut station.consolidation, from_, bag_);
        };
        let bag_ = table::borrow_mut(&mut station.consolidation, from_);
        // If the key value parameter is not valid in the bag, we add it.
        if(!bag::contains( bag_, to_)) {
            bag::add<String, vector<ID>>(bag_, to_, vector::empty());
        };
        // get coins vector from bag 
        let bus = bag::borrow_mut<String, vector<ID>>(bag_, to_);
        vector::push_back(bus, inner_);

        // end_ refers the minute and it calculated as a second.
        let remaining_ :u64 = ((end_) * (60)) + timestamp_ms(clock);
        let starts = ((start_) * (60)) + timestamp_ms(clock);
        // share the bus object 
        transfer::share_object(Bus{
            id: id_,
            owner: inner_,
            from: from_,
            to: to_,
            seed_num: seeds,
            seed: table_vec::empty(ctx),
            price: price_,
            start: starts,
            end : remaining_
        });
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