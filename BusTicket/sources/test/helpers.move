#[test_only]
module BusTicket::helpers {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
 
    use std::string::{Self};
    use std::vector;

    use BusTicket::ticket::{Self, AdminCap, test_init};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;
    const TEST_ADDRESS3: address = @0xD;
    const TEST_ADDRESS4: address = @0xE; 
    const TEST_ADDRESS5: address = @0xF;   

    public fun init_test_helper() : Scenario {
       let owner: address = @0xA;
       let scenario_val = ts::begin(owner);
       let scenario = &mut scenario_val;
 
       {
            test_init(ts::ctx(scenario));
       };
       scenario_val
    }

}