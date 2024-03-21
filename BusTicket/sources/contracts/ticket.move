module BusTicket::ticket {

    // === Imports ===

    use std::string::{String};
    use std::vector;
    //use std::debug;

    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;
    use sui::tx_context::{TxContext, sender};
    use sui::table::{Self, Table};
    use sui::bag::{Self, Bag};
    use sui::balance:: {Self, Balance};
    use sui::clock::{Clock, timestamp_ms};

    // === Friends ===

    // =================== Errors ===================
    const ERROR_INVALID_PRICE: u64 = 0;
    const ERROR_TIME_IS_UP: u64 = 1;
    const ERROR_INVALID_SEED_NUMBER: u64 = 2;
    const ERROR_INCORRECT_BUS: u64 = 3;
    const ERROR_NOT_OWNER: u64 = 4;
    const ERROR_TIME_NOT_COMPLETED: u64 = 5;

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
        balance: Balance<SUI>,
        from: String,
        to: String,
        seed_num: u8,
        seed: Table<u8, address>,
        taken: vector<u8>,
        price: u64,
        start: u64,
        end: u64
    }

    struct Ticket has key, store {
        id: UID,
        bus: ID,
        owner: address,
        launch_time: u64,
        seed_no: u8
    }

    struct AdminCap has key {
        id: UID
    }

    // =================== Events ===================

    struct BusCreated has copy, drop {
        owner: ID,
        from: String,
        to: String,
        price: u64,
        start: u64,
        end: u64
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

    //  ===================Public-Mutative Functions  ===================

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
        new_bag(station, from_, ctx);
        // get bag from the table as borrow_mut
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
            balance: balance::zero(),
            from: from_,
            to: to_,
            seed_num: seeds,
            seed: table::new(ctx),
            taken: vector::empty(),
            price: price_,
            start: starts,
            end: remaining_
        });
        event::emit(BusCreated{
            owner: inner_,
            from: from_,
            to: to_,
            price: price_,
            start: starts,
            end: remaining_
        });
    }

    // Users can buy tickets
    public fun buy(bus: &mut Bus, coin: Coin<SUI>, seed_no_: u8, clock: &Clock, ctx: &mut TxContext) {
        assert!(coin::value(&coin) >= bus.price, ERROR_INVALID_PRICE);
        assert!(timestamp_ms(clock) < bus.end, ERROR_TIME_IS_UP);
        assert!(seed_no_ <= bus.seed_num, ERROR_INVALID_SEED_NUMBER);
        assert!(!vector::contains(&bus.taken, &seed_no_), ERROR_INVALID_SEED_NUMBER);
        // take the seed spot from table 
        table::add(&mut bus.seed, seed_no_, sender(ctx));
        //push the taken seed number into the vector
        vector::push_back(&mut bus.taken, seed_no_);
        // convert the coin to balance 
        let balance_ = coin::into_balance(coin);
        // add ticket price to bus balance
        balance::join(&mut bus.balance, balance_);
        // transfer the ticket object to buyer.
        transfer::public_transfer(Ticket{
            id: object::new(ctx),
            bus: bus.owner,
            owner: sender(ctx),
            launch_time: bus.end,
            seed_no: seed_no_
        }, sender(ctx));   
    }

    // Users can rebate tickets before an hour 
    public fun refund(
        bus: &mut Bus,
        ticket: Ticket,
        clock: &Clock,
        ctx: &mut TxContext
    ) : Coin<SUI> {
        assert!(sender(ctx) == ticket.owner, ERROR_NOT_OWNER);
        assert!(timestamp_ms(clock) < (ticket.launch_time - 3600), ERROR_TIME_IS_UP);
        assert!(ticket.bus == bus.owner, ERROR_INCORRECT_BUS);
        // remove from the seed
        table::remove(&mut bus.seed, ticket.seed_no);
        // set the index of ticket
        let (_bool, index) = vector::index_of(&bus.taken, &ticket.seed_no);
        // remove from the vector 
        vector::remove(&mut bus.taken, index);
        // destroye the ticket 
        destroye_ticket(ticket);
        // take the ticket price and send it to buyer
        let balance_ = balance::split(&mut bus.balance, bus.price);
        let coin = coin::from_balance<SUI>(balance_, ctx);
        coin
    } 

    // After the bus departs, the admin can transfer the funds to the station and destroy the object
    public fun close_bus(_: &AdminCap, station: &mut Station, bus: Bus, clock: &Clock) {
        assert!(timestamp_ms(clock) > bus.end, ERROR_TIME_NOT_COMPLETED);
        // destructure the bus object
        let Bus{id, owner, balance, from, to, seed_num: _, seed, taken, price: _, start: _, end: _} = bus;
        // merge these two balance
        let _num = balance::join(&mut station.balance, balance);
        // destroye the bus object
        object::delete(id);
        // remove the table
        let i:u64 = 0;
        while(!vector::is_empty(&taken)) {
            // get index from the vector 
            let index = vector::remove(&mut taken, i);
            // remove the i th element in table
            table::remove(&mut seed, index);
            // increase the index 
            i = i + 1;
        };
        // Table is empty now. We can destroye it. 
        table::destroy_empty(seed);
        // remove the bus ID from station
        let bag_ = table::borrow_mut<String, Bag>(&mut station.consolidation, from);
        let vector_ = bag::borrow_mut<String, vector<ID>>(bag_, to);

        let (_bool, index) = vector::index_of(vector_, &owner);
        // remove from the vector 
        vector::remove( vector_, index);
    }

    // ============  Public-View Functions ============ 

    // get bus propertys
    public fun get_bus(bus: &Bus) : (
        ID,
        u64,
        String,
        String,
        u8,
        vector<u8>,
        u64,
        u64,
        u64
    ) {
        let balance_ = balance::value(&bus.balance);
        (
            bus.owner,
            balance_,
            bus.from,
            bus.to,
            bus.seed_num,
            bus.taken,
            bus.price,
            bus.start,
            bus.end
        )
    }
    // return the taken seeds
    public fun get_seeds(bus: &Bus) : vector<u8> {
        bus.taken
    }
    // return the maximum seed number in the bus 
    public fun get_seed_num(bus: &Bus) : u8{
        bus.seed_num
    }
    // Return the IDs of bus objects pertaining to services between two cities
    public fun get_consolidations(station: &Station, from: String, to: String) : vector<ID> {
        let bag_ = table::borrow<String, Bag>(&station.consolidation, from);
        let vector_ = bag::borrow<String, vector<ID>>(bag_, to);
        *vector_
    } 
    //  =================== Private Functions  ===================

    fun new_bag(station: &mut Station, from: String, ctx: &mut TxContext) {
        if(!table::contains(&station.consolidation, from)) {
        // create a new bag
        let bag_ = bag::new(ctx);
        // add bag to the table
        table::add(&mut station.consolidation, from, bag_);
        };
    }
    fun destroye_ticket(ticket: Ticket) {
        let Ticket {id, bus: _, owner: _, launch_time: _, seed_no: _} = ticket;
        object::delete(id);
    }
}
