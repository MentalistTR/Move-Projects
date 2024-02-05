#[test_only]
module hackathon::helpers{

    use sui::test_scenario::{Self as ts, next_tx,Scenario};
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
    use std::vector;
  
    // 10 person  deposit 1000 SUI . 
    public fun ten_users_deposit(ts: &mut Scenario) {

       let owner: address = @0xA;
       let test_address1: address = @0xB;
       let test_address2: address = @0xC;
       let test_address3: address = @0xD;
       let test_address4: address = @0xE;
       let test_address5: address = @0xF;  
       let test_address6: address = @0xBB;
       let test_address7: address = @0xCC;  
       let test_address8: address = @0xDD;  
       let test_address9: address = @0xEE;  
       let test_address10: address = @0xFF; 

       
       next_tx(ts, test_address1);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
        next_tx(ts, test_address2);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address3);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address4);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address5);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address6);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address7);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address8);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address9);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
           next_tx(ts, test_address10);
      {
        let share_fund = ts::take_shared<Fund>(ts);
        let deposit_sui = mint_for_testing<SUI>(1000, ts::ctx(ts));
       
        fund::deposit(&mut share_fund,deposit_sui,ts::ctx(ts));

        ts::return_shared(share_fund);
      };
         
   }

    public fun admin_create_vote_test(ts: &mut Scenario) {

       let owner: address = @0xA;
       let test_address1: address = @0xB;

     next_tx(ts, owner);
      { 
      let admin_cap = ts::take_from_sender<AdminCap>(ts);
      let votes = ts::take_shared<Votes>(ts);
      let duration_time: u64 = 100;
      let time = clock::create_for_testing(ts::ctx(ts));
      
      fund::create_vote(&admin_cap, &mut votes, duration_time, &time ,ts::ctx(ts));

      ts::return_to_sender(ts, admin_cap);
      ts::return_shared(votes);
      clock::share_for_testing(time);

      };

    }

    public fun ten_user_vote(ts: &mut Scenario, 
    decision1:u64, 
    decision2:u64, 
    decision3:u64, 
    decision4:u64, 
    decision5:u64, 
    decision6:u64, 
    decision7:u64, 
    decision8:u64, 
    decision9:u64, 
    decision10:u64) 
    {

       let owner: address = @0xA;
       let test_address1: address = @0xB;
       let test_address2: address = @0xC;
       let test_address3: address = @0xD;
       let test_address4: address = @0xE;
       let test_address5: address = @0xF;  
       let test_address6: address = @0xBB;
       let test_address7: address = @0xCC;  
       let test_address8: address = @0xDD;  
       let test_address9: address = @0xEE;  
       let test_address10: address = @0xFF; 

    next_tx(ts, test_address1);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes,  decision1, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    next_tx(ts, test_address2);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision2, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    next_tx(ts, test_address3);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision3, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

     next_tx(ts, test_address4);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision4, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    next_tx(ts, test_address5);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision5, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    next_tx(ts, test_address6);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision6, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    next_tx(ts, test_address7);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision7, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

     next_tx(ts, test_address8);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision8, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

     next_tx(ts, test_address9);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision9, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

     next_tx(ts, test_address10);
      {
        let votes = ts::take_shared<Votes>(ts);
        let time2 = clock::create_for_testing(ts::ctx(ts));
        let vote_number: u64 = 0;

        fund::vote(&mut votes, decision10, &time2, vote_number, ts::ctx(ts));

        ts::return_shared(votes);
        clock::share_for_testing(time2);

      };

    }

    public fun admin_get_result_test(ts: &mut Scenario) {

       let owner: address = @0xA;
       let test_address1: address = @0xB;
       let test_address2: address = @0xC;
       let test_address3: address = @0xD;
       let test_address4: address = @0xE;


        next_tx(ts, owner);
      {
       let share_fund = ts::take_shared<Fund>(ts);
       let votes = ts::take_shared<Votes>(ts);
       let admin_cap = ts::take_from_sender<AdminCap>(ts);
       let time2 = clock::create_for_testing(ts::ctx(ts));
       let withdraw_amount:u64 = 3000;
       let vote_number = 0;
       
       // lets increase time 101 seconds. 
       clock::increment_for_testing(&mut time2, 101);
       
       fund::get_results(&admin_cap, &mut votes, &mut share_fund, &time2, test_address4, withdraw_amount, vote_number, ts::ctx(ts));

       ts::return_shared(share_fund);
       ts::return_shared(votes);
       ts::return_to_sender(ts, admin_cap);
       clock::share_for_testing(time2);
       
      };
    }

}