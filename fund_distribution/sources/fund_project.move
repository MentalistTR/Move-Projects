module fund::fund_project { 

    use std::string::{Self,String};
    use std::vector;
    use std::debug;

    use sui::transfer;
    use sui::object::{Self,UID,ID};
    use sui::url::{Self,Url};
    use sui::coin::{Self, Coin, CoinMetadata};
    use sui::sui::SUI;
    use sui::object_table::{Self,ObjectTable};
    use sui::event;
    use sui::tx_context::{Self,TxContext};
    use sui::vec_set::{Self, VecSet};
    use sui::table::{Self, Table};
    use sui::balance:: {Self, Balance};
    use sui::bag::{Self,Bag};

  // =================== Errors ===================

    const ERROR_INVALID_ARRAY_LENGTH: u64 = 0;
    const ERROR_INVALID_PERCENTAGE_SUM: u64 = 1;
    const ERROR_YOU_ARE_NOT_SHAREHOLDER:u64 =2;
    const ERROR_FUNCTION_DISABLED:u64 = 3;
  
 

    /// Defines the share object for saving funds
    /// 
    /// # Arguments
    /// 
    /// * `total_fund` - we keep funds in this bag like <String, Balance<t>>
    struct Fund_Balances has key, store {
        id:UID,
        total_fund: Bag,  
    }

    // only admin  
    struct AdminCap has key {
        id:UID,
        pausable:bool,
    }

    /// We will keep the percentages and balances of ShareHolders here.
    /// 
    /// # Arguments
    /// 
    /// * `shareholders_percentage` - admin will decide shareholder percantage here. 
    /// * `shareholders_amount` -  We keep the shareholders Balance here like Table<address, <String, Balance<T>>>
    /// * `old_shareholders` - We keep the shareholders address in a vector for using in while loop. 
    struct ShareHolders has key {
        id:UID,
        shareholders_percentage: Table<address, u64>, 
        shareholders_amount: Table<address, Bag>,    
        old_shareholders:vector<address>,
    }

    /// We created this object to create a shareholder.
    /// # Arguments
    /// 
    /// * `shareholder` - Address of shareholder
    /// * `share_percentage` percentage of distribution amount 
    // struct ShareHoldersNew has drop {
    //     shareholder: address,
    //     share_percentage: u64,
    // }
   // =================== Initializer ===================

    fun init(ctx:&mut TxContext) {
       // share object
       transfer::share_object(
            Fund_Balances{
                id:object::new(ctx),
                total_fund:bag::new(ctx),
             },
         );
        // share object
        transfer::share_object(
            ShareHolders {
                id:object::new(ctx),
                shareholders_percentage:table::new(ctx),
                shareholders_amount:table::new(ctx),
                old_shareholders:vector::empty(),
            },
        );
       // Admin capability object for the stable coin
        transfer::transfer(AdminCap 
        { id: object::new(ctx), pausable:false}, tx_context::sender(ctx) );
    }
       
     /// People can deposit funds any token to fund.
     /// # Arguments
     /// 
     /// * `coin` - We use generics here for allow the deposit any token. 
     /// * `coin_metadata` - we use coinmetada here to keep token string in a vector. 
     
    public fun deposit_to_bag<T>(bag: &mut Fund_Balances, coin:Coin<T>, coin_metadata: &CoinMetadata<T>) {
        let balance = coin::into_balance(coin);
        let name = coin::get_name(coin_metadata);
        // lets check is there any same token in our bag
        if(bag::contains(&bag.total_fund, name)) { 
        // if there is a same token in our bag we will sum it.
            let coin_value = bag::borrow_mut(&mut bag.total_fund, name);
            balance::join(coin_value, balance);
        }
            // if it is not lets add it.
        else { 
             bag::add(&mut bag.total_fund, name, balance);
        }
     }
    // It is the same function with deposit_to_bag but we cant read sui token metadata. So we have to split it. 
    public fun deposit_to_bag_sui(bag: &mut Fund_Balances, coin:Coin<SUI>) {
        // lets define balance and name 
        let balance = coin::into_balance(coin);
        let name  = b"sui";
        let name_string = string::utf8(name);
            // lets check is there any sui token in bag
        if(bag::contains(&bag.total_fund, name_string)) { 
            let coin_value = bag::borrow_mut(&mut bag.total_fund, name_string);
            // if there is a sui token in our bag we will sum it.
             balance::join(coin_value, balance);
        }
        else { 
             // if it is not lets add it.
            bag::add(&mut bag.total_fund, name_string, balance);
        }
    }
     /// Shareholders can withdraw any token from fund. 
     /// # Arguments
     /// 
     /// * `amount` - Defines the withdraw amount  
     /// * `coin_name - Defines the withdraw token name in String type. 
     
    public fun shareholder_withdraw<T>(shareholders: &mut ShareHolders, amount:u64, coin_name:String,  ctx:&mut TxContext) {
         let sender = tx_context::sender(ctx);
         // firstly, check that  Is sender shareholder? 
          assert!(
           table::contains(&shareholders.shareholders_amount, sender),
            ERROR_YOU_ARE_NOT_SHAREHOLDER   
         );
          // let take shareholder_bag from table 
          let share_holder_bag = table::borrow_mut(&mut shareholders.shareholders_amount, sender);
          //decrease balance in table 
          let coin_value = bag::borrow_mut<String, Balance<T>>( share_holder_bag, coin_name);
          // calculate withdraw balance 
          let coin_transfer = coin::take(coin_value, amount, ctx);
          // transfer fund to sender 
          transfer::public_transfer(coin_transfer, sender);       
    }

     /// Only admin  can withdraw any token from fund. 
     /// # Arguments
     /// 
     /// * `withdraw_amount` - Defines the withdraw amount  
     /// * `coin_name - Defines the withdraw token name in String type. 

    public fun admin_withdraw<T>(_:&AdminCap, fund:&mut Fund_Balances, withdraw_amount:u64, coin_name:String, ctx:&mut TxContext) { 
        // let define the total_value from the bag 
        let total_value = bag::borrow_mut<String, Balance<T>>( &mut fund.total_fund, coin_name); 
        // let calculate the withdraw amount
        let withdraw = coin::take(total_value, withdraw_amount, ctx);
        // transfer to admin. 
        transfer::public_transfer(withdraw, tx_context::sender(ctx));
    }

    /// Only admin  can distribute tokens for shareholders.
    /// # Arguments
    /// 
    /// * `distribution_amount` - Defines the distribute tokens amount  
    /// * `coin_name - Defines the distribute token name in String type. 
    
    public fun fund_distribution<T>(
      _:&AdminCap,
      fund:&mut Fund_Balances,
      shareholder:&mut ShareHolders,
      distribution_amount: u64,
      coin_name: String, 
      ctx:&mut TxContext
        ) {
           let shareholder_vector_len: u64 = vector::length(&shareholder.old_shareholders);
           let j: u64 = 0;
           let i : u64 = 0;

             while (j < shareholder_vector_len) {
                // take address from oldshareholder vector
                let share_holder_address = vector::borrow(&shareholder.old_shareholders, j);         
                if (!table::contains(&shareholder.shareholders_amount, *share_holder_address)) {
                    let bag = bag::new(ctx);
                    table::add(&mut shareholder.shareholders_amount,*share_holder_address,bag);
                 }; 
                 // take share_holder percentage from table
                 let share_holder_percentage = table::borrow(&shareholder.shareholders_percentage, *share_holder_address);
                 // calculate shareholder withdraw tokens
                 let share_holder_withdraw_amount =  (distribution_amount * *share_holder_percentage ) / 10000 ;
                 // Calculate the total fund of that coin type in the bag
                 let shareholder_bag = table::borrow_mut<address, Bag>(&mut shareholder.shareholders_amount, *share_holder_address);
                 // let define shareholder Bag
                 let total_coin_value = bag::borrow_mut<String, Balance<T>>(&mut fund.total_fund, coin_name);
                 // calculate the distribute coin value to shareholder           
                 let withdraw_coin = balance::split<T>( total_coin_value, share_holder_withdraw_amount);
                // add to share_holder amount
                     if(bag::contains(shareholder_bag, coin_name) == true) { 
                        let coin_value = bag::borrow_mut( shareholder_bag, coin_name);
                        balance::join(coin_value, withdraw_coin);
                    }
                     else { 
                        bag::add(shareholder_bag, coin_name, withdraw_coin);
                     };
                         j = j + 1;       
                    };                     
           }

    /// Only admin  can set shareholders. Before we set new shareholders. The old shareholders will remove. 
    /// # Arguments
    /// 
    /// * `shareholder` - Defines the shareholders in a vector.
 
    public fun set_shareholders(admin_cap: &AdminCap, receipt:&mut ShareHolders, shareholder_address:vector<address>, shareholder_percentage:vector<u64>) {
        // check input length >= 2 
        assert!((vector::length(&shareholder_address) >= 2 && 
        vector::length(&shareholder_address) == vector::length(&shareholder_percentage)), 
        ERROR_INVALID_ARRAY_LENGTH);
        // check admincap.pausable is equal to false ? 
        assert!(admin_cap.pausable == false, ERROR_FUNCTION_DISABLED);
        // check percentange sum must be equal to 100 
        let percentage_sum:u64 = 0;

        while(!vector::is_empty(&receipt.old_shareholders)) {
            // Remove the old shareholders from table. 
            let shareholder_address = vector::pop_back(&mut receipt.old_shareholders);
            table::remove(&mut receipt.shareholders_percentage, shareholder_address);
        };
         // add shareholders to table. 
        while(!vector::is_empty(&shareholder_address)) {
            let shareholder_address = vector::pop_back(&mut shareholder_address); 
            let shareholder_percentage = vector::pop_back(&mut shareholder_percentage);
            // add new shareholders to old_shareholders vector. 
            vector::push_back(&mut receipt.old_shareholders, shareholder_address);   
            // add table to new shareholders and theirs percentange
            table::add(&mut receipt.shareholders_percentage, shareholder_address , shareholder_percentage);
             // sum percentage
            percentage_sum = percentage_sum + shareholder_percentage;

        };
            // check percentage is equal to 100.
            assert!(percentage_sum == 10000, ERROR_INVALID_PERCENTAGE_SUM);
    }

    // This function is for contract security 

    public entry fun pause_set_shareholder (admin_cap: &mut AdminCap) {
        admin_cap.pausable = !admin_cap.pausable
    }
    
    // We will use this functions in test.
    #[test_only]

        // calling init function. 
        public fun init_for_testing(ctx: &mut TxContext) {
            init(ctx); 
        }

         // create a shareholder
        // public fun create_shareholdernew(shareholder: address, share_percentage: u64): ShareHoldersNew {
        //     ShareHoldersNew { shareholder, share_percentage}
        // }

        // return shareholder percentange u64.
        public fun return_shareholder_percentage(sh:&ShareHolders,recipient:address): u64  {
            let share_percentage_ref= table::borrow(&sh.shareholders_percentage, recipient);
            *share_percentage_ref / 100
        }

        // return the total amount of the token we set from bag
        public fun get_bag_fund<T>(bag:& Fund_Balances, coin_metada: &CoinMetadata<T>): &Balance<T> {
            bag::borrow(&bag.total_fund, coin::get_name(coin_metada))
        }

        // return the total amount of SUI from bag.
         public fun get_bag_fund_SUI(bag: &Fund_Balances): &Balance<SUI> {
            let name  = b"sui";
            let name_string = string::utf8(name);
            bag::borrow(&bag.total_fund, name_string)
        }

       //return shareholder allowance withdraw amount 
         public fun return_shareholder_allowance_amount<T>(shareholder:&ShareHolders, token_name:String, holder:address): u64  {
             let shareholder_bag = table::borrow<address, Bag>(&shareholder.shareholders_amount, holder);
             let shareholder_allowance = bag::borrow<String, Balance<T>>(shareholder_bag, token_name );
             balance::value<T>(shareholder_allowance)
        }
}