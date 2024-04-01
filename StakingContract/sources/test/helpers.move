#[test_only]
module stakingContract::helpers {
    use sui::test_scenario::{Self as ts, next_tx, Scenario};
 
    use std::string::{Self};
    use std::vector;

    use stakingContract::staking::{Self};
    use stakingContract::admin::{test_init}; 
    use stakingContract::mnt::{return_init_mnt};

    const ADMIN: address = @0xA;
    const ALICE: address = @0xB;
    const BOB: address = @0xC;
    const DIANA: address = @0xD;

    public fun new_accounts(scenario: &mut Scenario) {
        next_tx(scenario, ALICE);
        {
            staking::new_account(ts::ctx(scenario));
        };
        next_tx(scenario, BOB);
        {
            staking::new_account(ts::ctx(scenario));
        };
        next_tx(scenario, DIANA);
        {
            staking::new_account(ts::ctx(scenario));
        };
    }

    public fun init_test_helper() : Scenario {
       let owner: address = @0xA;
       let scenario_val = ts::begin(owner);
       let scenario = &mut scenario_val;
 
       {
          test_init(ts::ctx(scenario));
       };
       {
        return_init_mnt(ts::ctx(scenario));
       };
       scenario_val
    }

}