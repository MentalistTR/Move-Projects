#[test_only]
module BusTicket::test_ticket {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::coin::{Self, Coin, mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::balance:: {Self, Balance};
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self, Clock};

    use std::vector;
    use std::string::{Self, String};

    use BusTicket::ticket::{Self, AdminCap, Station, Bus, test_init};
    use BusTicket::helpers::{Self, init_test_helper};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;
    const TEST_ADDRESS3: address = @0xD;
    const TEST_ADDRESS4: address = @0xE; 
    const TEST_ADDRESS5: address = @0xF;

    #[test]
    #[expected_failure(abort_code = ticket::ERROR_INVALID_SEED_NUMBER)]
    public fun test_new_bus() {

        let scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        next_tx(scenario, ADMIN);
        {
            let cap = ts::take_from_sender<AdminCap>(scenario);
            let station = ts::take_shared<Station>(scenario);
            let time = clock::create_for_testing(ts::ctx(scenario));

            let seeds_ :u8 = 20;
            let from_ = string::utf8(b"Ankara");
            let to_ = string::utf8(b"istanbul");
            let price: u64 = 1_000_000_000;
            let start: u64 = 60;
            let end: u64 = (86400) * (7);

            ticket::new(
                &cap,
                &mut station,
                seeds_,
                from_,
                to_,
                price,
                start,
                end,
                &time,
                ts::ctx(scenario)
            );
            ts::return_to_sender(scenario, cap);
            ts::return_shared(station);
            clock::share_for_testing(time);        
        };
        // the balance of Bus must be zero
        next_tx(scenario, ADMIN);
        {
            let bus = ts::take_shared<Bus>(scenario);

            assert_eq(ticket::get_bus_balance(&bus), 0);

            ts::return_shared(bus);
        };
        // but ticket 
        next_tx(scenario, TEST_ADDRESS1);
        {
            let bus = ts::take_shared<Bus>(scenario);
            let time = ts::take_shared<Clock>(scenario);
            let coin = coin::mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
            let seed_no: u8 = 1;

            ticket::buy(&mut bus, coin, seed_no, &time, ts::ctx(scenario));

            ts::return_shared(bus);
            ts::return_shared(time);
        };
        // buy ticket 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let bus = ts::take_shared<Bus>(scenario);
            let time = ts::take_shared<Clock>(scenario);
            let coin = coin::mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
            let seed_no: u8 = 21;

            ticket::buy(&mut bus, coin, seed_no, &time, ts::ctx(scenario));

            ts::return_shared(bus);
            ts::return_shared(time);
        };
        // buy ticket 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let bus = ts::take_shared<Bus>(scenario);
            let time = ts::take_shared<Clock>(scenario);
            let coin = coin::mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
            let seed_no: u8 = 0;

            ticket::buy(&mut bus, coin, seed_no, &time, ts::ctx(scenario));

            ts::return_shared(bus);
            ts::return_shared(time);
        };
        // buy ticket 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let bus = ts::take_shared<Bus>(scenario);
            let time = ts::take_shared<Clock>(scenario);
            let coin = coin::mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
            let seed_no: u8 = 1;

            ticket::buy(&mut bus, coin, seed_no, &time, ts::ctx(scenario));

            ts::return_shared(bus);
            ts::return_shared(time);
        };













        ts::end(scenario_test);


    }





}