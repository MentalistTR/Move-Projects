#[test_only]
module fund::helpers {

    use sui::test_scenario::{Self as ts, next_tx,Scenario};
    use fund::fund_project as fp;
    use fund::fund_project::{Fund_Balances,AdminCap,ShareHolders};
    use fund::usdc::{init_for_testing_usdc, USDC};
    use fund::usdt::{init_for_testing_usdt, USDT};
    use sui::coin::{Self, Coin, mint_for_testing, CoinMetadata};
    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::UID;
    use sui::balance:: {Self, Balance};
    use sui::table;
    use std::vector;
    use sui::test_utils::{assert_eq};
    use std::string::{Self,String};
  
  
    public fun  add_share_holders(ts: &mut Scenario, perc1:u64,perc2:u64, perc3:u64, perc4:u64) {

       let owner: address = @0xA;
       let test_address1: address = @0xB;
       let test_address2: address = @0xC;
       let test_address3: address = @0xD;
       let test_address4: address = @0xE;  

       next_tx(ts,owner);
       { 
       let shared_ShareHolders = ts::take_shared<ShareHolders>(ts);
       let shared_ShareHolders_ref = &mut shared_ShareHolders; 
       let admin_cap = ts::take_from_sender<AdminCap>(ts);
       
       let shareholder_address_vector  = vector::empty();   
       let shareholder_percentage_vector = vector::empty(); 

       vector::push_back(&mut shareholder_address_vector, test_address1);
       vector::push_back(&mut shareholder_address_vector, test_address2); 
       vector::push_back(&mut shareholder_address_vector, test_address3); 
       vector::push_back(&mut shareholder_address_vector, test_address4);  

       vector::push_back(&mut shareholder_percentage_vector, perc1);
       vector::push_back(&mut shareholder_percentage_vector, perc2);
       vector::push_back(&mut shareholder_percentage_vector, perc3);
       vector::push_back(&mut shareholder_percentage_vector, perc4);

       fp::set_shareholders(&admin_cap, shared_ShareHolders_ref, shareholder_address_vector, shareholder_percentage_vector);      
       ts::return_shared(shared_ShareHolders);
       ts::return_to_sender(ts,admin_cap);     
      };
   }

   // USER deposit 10000 USDC
    public fun users_deposit_token<T>(ts: &mut Scenario) {

     let test_address1: address = @0xB;
     let test_address2: address = @0xC;
     let test_address3: address = @0xD;
     let test_address4: address = @0xE;

     next_tx(ts,test_address1);
    {
       let fund_balances = ts::take_shared<Fund_Balances>(ts);
       let deposit_amount1 = mint_for_testing<T>(10000, ts::ctx(ts));
       let usdc_metadata = ts::take_immutable<CoinMetadata<T>>(ts);
   
       fp::deposit_to_bag(&mut fund_balances, deposit_amount1,&usdc_metadata);
 
       ts::return_shared(fund_balances);
       ts::return_immutable(usdc_metadata);
   };

   }

 // USER deposit 10000 SUI 
   public fun users_deposit_sui(ts: &mut Scenario) {

     let test_address1: address = @0xB;
     let test_address2: address = @0xC;
     let test_address3: address = @0xD;
     let test_address4: address = @0xE;

    next_tx(ts,test_address1);
    {
       let fund_balances = ts::take_shared<Fund_Balances>(ts);
       let deposit_amount1 = mint_for_testing<SUI>(10000, ts::ctx(ts));
   
       fp::deposit_to_bag_sui(&mut fund_balances, deposit_amount1);
 
       ts::return_shared(fund_balances);
   };

}

  public fun admin_distribute_funds_usdc<T>(ts: &mut Scenario, distribution_amount: u64) {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      next_tx(ts,owner);
   {
      let admin_cap = ts::take_from_sender<AdminCap>(ts);
      let shared_ShareHolders = ts::take_shared<ShareHolders>(ts);
      let fund_balances = ts::take_shared<Fund_Balances>(ts);
      let name  = b"usdc";
      let name_string = string::utf8(name);

      fp::fund_distribution<T>(&admin_cap, &mut fund_balances, &mut shared_ShareHolders, distribution_amount, name_string, ts::ctx(ts) );

      ts::return_to_sender(ts,admin_cap); 
      ts::return_shared(shared_ShareHolders);
      ts::return_shared(fund_balances);
   }

   }

   public fun admin_distribute_funds_usdt<T>(ts: &mut Scenario, distribution_amount: u64) {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      next_tx(ts,owner);
   {
      let admin_cap = ts::take_from_sender<AdminCap>(ts);
      let shared_ShareHolders = ts::take_shared<ShareHolders>(ts);
      let fund_balances = ts::take_shared<Fund_Balances>(ts);
      let name  = b"usdt";
      let name_string = string::utf8(name);

      fp::fund_distribution<T>(&admin_cap, &mut fund_balances, &mut shared_ShareHolders, distribution_amount, name_string, ts::ctx(ts) );

      ts::return_to_sender(ts,admin_cap); 
      ts::return_shared(shared_ShareHolders);
      ts::return_shared(fund_balances);
   }

   }

    public fun admin_distribute_funds_sui<T>(ts: &mut Scenario, distribution_amount: u64) {

      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      let test_address3: address = @0xD;
      let test_address4: address = @0xE;

      next_tx(ts,owner);
   {
      let admin_cap = ts::take_from_sender<AdminCap>(ts);
      let shared_ShareHolders = ts::take_shared<ShareHolders>(ts);
      let fund_balances = ts::take_shared<Fund_Balances>(ts);
      let name  = b"sui";
      let name_string = string::utf8(name);

      fp::fund_distribution<T>(&admin_cap, &mut fund_balances, &mut shared_ShareHolders, distribution_amount, name_string, ts::ctx(ts) );

      ts::return_to_sender(ts,admin_cap); 
      ts::return_shared(shared_ShareHolders);
      ts::return_shared(fund_balances);
   }

   }

   public fun before_test_admin_distribute(ts: &mut Scenario, perc1:u64, perc2:u64, perc3:u64, perc4:u64) {

    let owner: address = @0xA;
    let test_address1: address = @0xB;
    let test_address2: address = @0xC;
    let test_address3: address = @0xD;
    let test_address4: address = @0xE;      
    
     next_tx(ts,owner);
    {
     fp::init_for_testing(ts::ctx(ts));
     init_for_testing_usdc(ts::ctx(ts));
     init_for_testing_usdt(ts::ctx(ts));
    };
    // add share holders
    next_tx(ts,owner);
    {
     add_share_holders(ts,perc1, perc2, perc3, perc4);
    };
    // user deposit 10000 USDC
    next_tx(ts,owner);
    {
       users_deposit_token<USDC>(ts); 
    };
       // user deposit 10000 USDT
    next_tx(ts,owner);
    {
       users_deposit_token<USDT>(ts);
    };
       // user deposit 10000 SUI
    next_tx(ts,owner);
    {
       users_deposit_sui(ts);
    };

    }

    public fun before_shareholder_withdraw(ts: &mut Scenario, perc1:u64, perc2:u64, perc3:u64, perc4:u64) {
      let owner: address = @0xA;
      let test_address1: address = @0xB;
      let test_address2: address = @0xC;
      
      // check init function
      next_tx(ts,owner);
      {
         fp::init_for_testing(ts::ctx(ts));
      };

      next_tx( ts, owner);
        {
        init_for_testing_usdc(ts::ctx(ts))
        };
      next_tx(ts, owner);
        {
        init_for_testing_usdt(ts::ctx(ts))
        };

      next_tx(ts,owner);
      {
          add_share_holders(ts,perc1, perc2, perc3, perc4);
      };
      next_tx(ts,owner);
      {
         users_deposit_token<USDC>(ts); 
      };
         // user deposit 10000 USDT
      next_tx(ts,owner);
      {
         users_deposit_token<USDT>(ts);
      };
         // user deposit 10000 SUI
      next_tx(ts,owner);
      {
          users_deposit_sui(ts);
      };

      next_tx(ts, owner);
      {
      // Lets distribute USDC
          admin_distribute_funds_usdc<USDC>(ts, 5000);
      };
       // Lets distribute USDT
      next_tx(ts, owner);
      {
        admin_distribute_funds_usdt<USDT>(ts, 5000);
      };
       // Lets distribute SUI
      next_tx(ts, owner);
      {
        admin_distribute_funds_sui<SUI>(ts, 5000);
      };
       }

}