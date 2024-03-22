#[test_only]
module stakingContract::test_ticket {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
    use sui::coin::{Self, Coin, mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self, Clock};
    use sui::transfer::{Self};

    use std::vector;
    use std::string::{Self, String};

    use stakingContract::staking::{Self, AdminCap, test_init};
    use stakingContract::mnt::{Self, MNT, CapWrapper};
    use stakingContract::helpers::{Self, init_test_helper};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;
    const TEST_ADDRESS3: address = @0xD;
    const TEST_ADDRESS4: address = @0xE; 
    const TEST_ADDRESS5: address = @0xF;

    #[test]

    public fun test_deposit() {

        let scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        next_tx(scenario, ADMIN);

        {

        };

        ts::end(scenario_test);
    }

       
}