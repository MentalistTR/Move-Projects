module hackathon::fund {

use std::string::{Self,String};
use sui::transfer;
use sui::object::{Self,UID,ID};
use sui::url::{Self,Url};
use sui::coin::{Self,Coin};
use sui::sui::SUI;
use sui::object_table::{Self,ObjectTable};
use sui::event;
use sui::tx_context::{Self,TxContext};
use sui::vec_set::{Self, VecSet};
use sui::table::{Self, Table};
use sui::balance:: {Self, Balance};
use std::vector;
use std::debug;
use sui::clock::{Self,Clock};

const ERROR_INVALID_FUND_BALANCES :u64 = 0;
const ERROR_YOU_ALREADY_VOTED: u64 = 1;
const ERROR_TIME_IS_NOT_COMPLETED: u64 = 2;
const ERROR_INVALID_VOTING_POWER: u64 = 3;

// onlyadmin object 
struct AdminCap has key {
    id:UID,
}

// share object for users can deposit theirs fund
struct Fund has key {
    id:UID,
    balances:Balance<SUI>,
    sender_table: Table<address,u64>,
    senders:vector<address>,
    counter:u64,
}

// vote struct for share object 

struct Vote has key,store {
    id:UID,
    votes:Table<address,bool>, // keep users used vote. 
    total_votes:u64,
    total_yes:u64,
    total_no:u64,
    total_abstain:u64,  
    total_no_with_veto:u64,        
    vote_started:u64,
    vote_end:u64        
}

struct Votes has key {
    id:UID,
    keep_votes: vector<Vote>,   
}

//  We send users an NFT for donating
struct Receipt has key {
    id: UID,
    deposit_amount: u64,
    receipt_number: u64  
}
// event for donate 
struct Transfer has copy,drop {
    sender:address,
    amount:u64,   
}

fun init(ctx:&mut TxContext) {
    transfer::share_object(
        Fund {
            id:object::new(ctx),
            balances:balance::zero(),
            senders:vector::empty(),
            sender_table:table::new(ctx),
            counter:0
        },
    );
    transfer::share_object(
        Votes{
            id:object::new(ctx),
            keep_votes:vector::empty(),
           
        }
    );

    transfer::transfer(AdminCap{id:object::new(ctx)},tx_context::sender(ctx));
}

public entry fun deposit(fund: &mut Fund, amount:Coin<SUI>, ctx:&mut TxContext) {
    let caller_address = tx_context::sender(ctx);
    let deposit_amount = coin::value(&amount);
    fund.counter = fund.counter + 1;

    // add SUI into the fund balance 
    let coin_balance: Balance<SUI> = coin::into_balance(amount);
    balance::join(&mut fund.balances, coin_balance);

    event::emit(
        Transfer{
        sender:tx_context::sender(ctx),
        amount:deposit_amount
        }
    );
     // increase sender donated amount in table
    increase_account_balance(fund,caller_address, deposit_amount);

    // create a Receipt for proof 
   let receipt: Receipt = Receipt {
        id:object:: new(ctx),
        deposit_amount: deposit_amount,
        receipt_number: fund.counter
      };

    transfer::transfer(receipt, tx_context::sender(ctx)); 
}
  // admin starting vote
public entry fun create_vote(_:&AdminCap, votes:&mut Votes, duration: u64, clock:&Clock, ctx:&mut TxContext) {
    assert!(duration > 0,ERROR_TIME_IS_NOT_COMPLETED);
    let current_time: u64 = clock::timestamp_ms(clock);
    let end_time = current_time + duration;
    let id = object::new(ctx);

    let vote = Vote {
    id:id,
    votes:table::new(ctx),
    total_votes:0,
    total_yes:0,
    total_no:0,
    total_abstain:0,  
    total_no_with_veto:0,        
    vote_started:current_time,
    vote_end:end_time, 
    };
    
    vector::push_back(&mut votes.keep_votes, vote); 
}

//users now can vote 
public entry fun vote(votes:&mut Votes, decision:u64, clock:&Clock, vote_number:u64, ctx:&mut TxContext) {
     let vote_array_property = vector::borrow_mut(&mut votes.keep_votes, vote_number); 
   assert!(
     !table::contains(&vote_array_property.votes,tx_context::sender(ctx)),
     ERROR_YOU_ALREADY_VOTED
   );
   
     let current_time: u64 = clock::timestamp_ms(clock);
     let vote_end_time = vote_array_property.vote_end;
     assert!(current_time < vote_end_time,ERROR_TIME_IS_NOT_COMPLETED);
    
     let caller_address = tx_context::sender(ctx);
     // increase vote 
    if(decision == 0) {
       vote_array_property.total_yes = vote_array_property.total_yes+ 1;
       vote_array_property.total_votes = vote_array_property.total_votes +1;
       }
    else if(decision ==1) {
       vote_array_property.total_no =  vote_array_property.total_no + 1;
       vote_array_property.total_votes = vote_array_property.total_votes +1;
        }
    else if(decision ==2) {
        vote_array_property.total_abstain = vote_array_property.total_abstain + 1;
        vote_array_property.total_votes = vote_array_property.total_votes +1;
        }
    else if(decision ==3) {
        vote_array_property.total_no_with_veto= vote_array_property.total_no_with_veto + 1;
        vote_array_property.total_votes = vote_array_property.total_votes +1;
        };

    user_voted(vote_array_property, caller_address);
}

public entry fun get_results(_:&AdminCap, vote:&mut Votes, fund:&mut Fund, clock:&Clock, recipient:address, amount:u64, vote_number:u64, ctx:&mut TxContext) {

    let vote_array_property = vector::borrow_mut(&mut vote.keep_votes, vote_number); 
    let current_time: u64 = clock::timestamp_ms(clock);

    assert!(current_time > vote_array_property.vote_end,ERROR_TIME_IS_NOT_COMPLETED);
    // check yes votes > %51
    assert!(vote_array_property.total_yes * 100 / vote_array_property.total_votes  > 51, ERROR_INVALID_VOTING_POWER);
    
    // send fund to recipient
    withdraw_fund(fund,amount,ctx,recipient);
}

fun withdraw_fund(fund:&mut Fund, amount:u64, ctx:&mut TxContext,recipient:address) {
     // check the input amount <= fund_balances
     let withdraw_amount = amount;
     let fund_balance_value = balance::value(&fund.balances);
     assert!(withdraw_amount <= fund_balance_value ,ERROR_INVALID_FUND_BALANCES);

     let withdraw: Coin<SUI> = coin::take(&mut fund.balances, amount, ctx);
     transfer::public_transfer(withdraw, recipient);
}


   // users can see theirs donated amount from table 
public fun get_donate_amount(fund:&Fund, ctx:&mut TxContext) : u64 {
      let user_donate_amount= table::borrow(&fund.sender_table,tx_context::sender(ctx));
      *user_donate_amount
}
   // users can see fund total balances
public fun get_fund_balances(fund:&Fund) : u64 {
    balance::value(&fund.balances)
}
    // get counter from Fund 
public fun get_fund_counter(fund:&Fund) : u64 {
    fund.counter
}

  // helper function that runs when users deposit fund
fun increase_account_balance(storage: &mut Fund, recipient: address, amount:u64) {
      if(table::contains(&storage.sender_table, recipient)) {
          let existing_balance = table::remove(&mut storage.sender_table, recipient);
          table::add(&mut storage.sender_table, recipient, existing_balance +amount);
      } else {
          table::add(&mut storage.sender_table, recipient, amount); 
      };
  }
     // increase fund balance 
fun increase_fund_balance(storage: &mut Fund, recipient: address, amount: u64) {
    if (table::contains(&storage.sender_table, recipient)) {
        let existing_balance = table::remove(&mut storage.sender_table, recipient);
        table::add(&mut storage.sender_table, recipient, existing_balance + amount);
    } else {
        table::add(&mut storage.sender_table, recipient, amount);
    };
}
  fun  user_voted(vote: &mut Vote, user: address) {
 
    if (table::contains(&vote.votes, user)) {
        abort 3;
    } else {
        table::add(&mut vote.votes, user, true);
    }
  }

  #[test_only]

     // calling init function. 
     public fun init_for_testing(ctx: &mut TxContext) {
         init(ctx); 
     }

     // lets check votes array length
     public fun votes_array_vote(vote:&Votes, array_number:u64) : &Vote {
          vector::borrow(&vote.keep_votes, array_number)
     }
     // get VOTES. total no number 
     public fun get_total_no(vote:&Votes, array_number:u64) : u64 {
       let vote_prop =  vector::borrow(&vote.keep_votes, array_number);
       vote_prop.total_no
     }
        // get VOTES.total votes 
     public fun get_total_vote(vote:&Votes, array_number:u64) : u64 {
       let vote_prop =  vector::borrow(&vote.keep_votes, array_number);
       vote_prop.total_votes
     }
       // get user voted or no 
    // public fun get_user_active_bool(vote:&Votes, array_number:u64, ctx:&mut TxContext ) : bool {
    //    let vote_prop =  vector::borrow(&vote.keep_votes, array_number);
    //    let table = vote_prop.votes;
    //    table::contains(&table, tx_context::sender(ctx))
    //  }

}