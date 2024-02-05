#[test_only]

    module hackathon::fund_test{

    use sui::test_scenario::{Self as ts, next_tx};
    use sui::coin::{Self,Coin,mint_for_testing};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::balance;
    use sui::table;
    use sui::test_utils::{assert_eq};
    use sui::clock::{Self,Clock};

    use hackathon::fund;
    use hackathon::fund::{init_for_testing, Fund, Receipt, Votes, AdminCap};
    use hackathon::helpers::{ten_users_deposit, admin_create_vote_test,  ten_user_vote, admin_get_result_test};
    use std::vector;
    



    //*****************************************************************************************************************************************// 

#[test]
    fun users_deposit_fund() {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;
      
      //initiliaze
      next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };
      
      //user1 deposit funds
      next_tx(scenario, test_address1);
      {
        let share_fund = ts::take_shared<Fund>(scenario);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(scenario));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(scenario));

        ts::return_shared(share_fund);

      };
       //user2 deposit funds
      next_tx(scenario, test_address2);
      {
        let share_fund = ts::take_shared<Fund>(scenario);
        let deposit_sui = mint_for_testing<SUI>(2000, ts::ctx(scenario));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(scenario));

        ts::return_shared(share_fund);

      };

      // lets check user1 balance is equal to 1000 
      next_tx(scenario, test_address1);
      {
        let share_fund = ts::take_shared<Fund>(scenario);
        let user1_balance = fund::get_donate_amount(&share_fund, ts::ctx(scenario));

        assert_eq(user1_balance, 1000);

        ts::return_shared(share_fund);
      };

        // lets check user2 balance is equal to 2000
      next_tx(scenario, test_address2);
      {
        let share_fund = ts::take_shared<Fund>(scenario);
        let user2_balance = fund::get_donate_amount(&share_fund, ts::ctx(scenario));

        assert_eq(user2_balance, 2000);

        ts::return_shared(share_fund);
      };
      // lets check Fund.counter is equal to 2 now. (2 people deposit fund) 
      next_tx(scenario, owner);
      {
        let share_fund = ts::take_shared<Fund>(scenario);
        let fund_counter = fund::get_fund_counter(&share_fund);

        assert_eq(fund_counter, 2);

        ts::return_shared(share_fund);
      };
      // lets check does test_address1 has Receipt ?
      next_tx(scenario, test_address1);
      {
        let receipt = ts::take_from_sender<Receipt>(scenario);

        ts::return_to_sender(scenario,receipt);
      };
    
      ts::end(scenario_test);
    }

#[test]

    fun admin_create_vote() {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;

       //initiliaze
      next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };
      // 10 person deposit 1000 SUI
      ten_users_deposit(scenario);
      
      next_tx(scenario, owner);
      { 
      let admin_cap = ts::take_from_sender<AdminCap>(scenario);
      let votes = ts::take_shared<Votes>(scenario);
      let duration_time: u64 = 100;
      let time = clock::create_for_testing(ts::ctx(scenario));
      
      fund::create_vote(&admin_cap, &mut votes, duration_time, &time ,ts::ctx(scenario));

      ts::return_to_sender(scenario, admin_cap);
      ts::return_shared(votes);
      clock::share_for_testing(time);

      };
      // lets check from Our Vote shareobject is it exist ? 
      next_tx(scenario, owner);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let vector_number:u64 = 0;
        
        fund::votes_array_vote(&votes, vector_number);

        ts::return_shared(votes);
        
      };
     // let admin create another vote 
    next_tx(scenario, owner);
      { 
      let admin_cap = ts::take_from_sender<AdminCap>(scenario);
      let votes = ts::take_shared<Votes>(scenario);
      let duration_time: u64 = 100;
      let time = clock::create_for_testing(ts::ctx(scenario));
      
      fund::create_vote(&admin_cap, &mut votes, duration_time, &time ,ts::ctx(scenario));

      ts::return_to_sender(scenario, admin_cap);
      ts::return_shared(votes);
      clock::share_for_testing(time);

      };
      // lets check from Our Vote shareobject array index [1]
      next_tx(scenario, owner);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let vector_number:u64 = 1;
        
        fund::votes_array_vote(&votes, vector_number);

        ts::return_shared(votes);    
      };

       ts::end(scenario_test);
    }

#[test]
#[expected_failure(abort_code = fund::ERROR_YOU_ALREADY_VOTED)]

    fun user_vote() {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;

       //initiliaze
      next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };

      ten_users_deposit(scenario);

      admin_create_vote_test(scenario);
      // let address1 vote. 
      next_tx(scenario, test_address1);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let decision:u64 = 1;
        let time2 = clock::create_for_testing(ts::ctx(scenario));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision, &time2, vote_number, ts::ctx(scenario));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };
      // check total no vote 
      next_tx(scenario, test_address1);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let total_no_votes = fund::get_total_no(&votes, 0);
        assert_eq(total_no_votes, 1);

        ts::return_shared(votes);
      };
      // check total vote
        next_tx(scenario, test_address1);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let total_no_votes = fund::get_total_vote(&votes, 0);
        assert_eq(total_no_votes, 1);

        ts::return_shared(votes);
      };
     // we are expecting failure. test_address1 already voted. 
         next_tx(scenario, test_address1);
      {
        let votes = ts::take_shared<Votes>(scenario);
        let decision:u64 = 1;
        let time2 = clock::create_for_testing(ts::ctx(scenario));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision, &time2, vote_number, ts::ctx(scenario));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

       ts::end(scenario_test);
    }

#[test]

    fun admin_get_results() {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;
      

       //initiliaze
    next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };

      ten_users_deposit(scenario);

      admin_create_vote_test(scenario);

      ten_user_vote(scenario,0,0,0,0,0,0,0,0,0,0);
    
    next_tx(scenario, owner);
      {
       let share_fund = ts::take_shared<Fund>(scenario);
       let votes = ts::take_shared<Votes>(scenario);
       let admin_cap = ts::take_from_sender<AdminCap>(scenario);
       let time2 = clock::create_for_testing(ts::ctx(scenario));
       let withdraw_amount:u64 = 3000;
       let vote_number = 0;
       
       // lets increase time 101 seconds. 
       clock::increment_for_testing(&mut time2, 101);
       
       fund::get_results(&admin_cap, &mut votes, &mut share_fund, &time2, test_address4, withdraw_amount, vote_number, ts::ctx(scenario));

       ts::return_shared(share_fund);
       ts::return_shared(votes);
       ts::return_to_sender(scenario, admin_cap);
       clock::share_for_testing(time2);
       
      };
      //lets check test_address4 balance is equal to 4000 SUI 
      next_tx(scenario, test_address4);
      {
        let user4_balance = ts::take_from_sender<Coin<SUI>>(scenario);

        assert_eq(coin::value(&user4_balance), 3000);

        ts::return_to_sender(scenario, user4_balance);
      };

      ts::end(scenario_test);

    }

// we are expecting error. admin cant end this vote after 99 seconds passed. 
 #[test]
 #[expected_failure(abort_code = fund::ERROR_TIME_IS_NOT_COMPLETED)]
 fun admin_get_results_late () {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;
      
       //initiliaze
    next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };

      ten_users_deposit(scenario);

      admin_create_vote_test(scenario);

      ten_user_vote(scenario,0,0,0,0,0,0,0,0,0,0);

    next_tx(scenario, owner);
      {
       let share_fund = ts::take_shared<Fund>(scenario);
       let votes = ts::take_shared<Votes>(scenario);
       let admin_cap = ts::take_from_sender<AdminCap>(scenario);
       let time2 = clock::create_for_testing(ts::ctx(scenario));
       let withdraw_amount:u64 = 3000;
       let vote_number = 0;
       
       // lets increase time 99 seconds. SO admin cant end this vote at the current time. 
       clock::increment_for_testing(&mut time2, 99);
       
       fund::get_results(&admin_cap, &mut votes, &mut share_fund, &time2, test_address4, withdraw_amount, vote_number, ts::ctx(scenario));

       ts::return_shared(share_fund);
       ts::return_shared(votes);
       ts::return_to_sender(scenario, admin_cap);
       clock::share_for_testing(time2);
       
      };
      ts::end(scenario_test);
 }

// we are expecting error here. User already voted 
 #[test]
 #[expected_failure(abort_code = fund::ERROR_YOU_ALREADY_VOTED)]
 fun user_vote_second_time() {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;
      
       //initiliaze
    next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };

      ten_users_deposit(scenario);

      admin_create_vote_test(scenario);

      ten_user_vote(scenario,0,0,0,0,0,0,0,0,0,0);

      next_tx(scenario, test_address1);
      {

        let votes = ts::take_shared<Votes>(scenario);
        let decision:u64 = 0;
        let time2 = clock::create_for_testing(ts::ctx(scenario));
        let vote_number: u64 = 0;

       // clock::increment_for_testing(&mut time2, 101);

        fund::vote(&mut votes, decision, &time2, vote_number, ts::ctx(scenario));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };


      ts::end(scenario_test);

}

// we are expecting error here. User vote late 
 #[test]
 #[expected_failure(abort_code = fund::ERROR_INVALID_VOTING_POWER)]
 fun invalid_voting_power () {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      let scenario_test = ts::begin(owner);
      let scenario = &mut scenario_test;
      

       //initiliaze
    next_tx(scenario, owner);
      {
        init_for_testing(ts::ctx(scenario));
      };

      ten_users_deposit(scenario);

      admin_create_vote_test(scenario);

      ten_user_vote(scenario,1,1,1,1,1,1,0,0,0,0);

      admin_get_result_test(scenario);

      ts::end(scenario_test);
}

}