module fund::usdc {
    
    use std::option;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::balance::{Self, Supply};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::tx_context;
    use sui::vec_set::{Self, VecSet};
    use sui::table::{Self, Table};
    

    struct USDC has drop {}

        struct USDCStableCoinStorage has key {
        id: UID,
        supply: Supply<USDC>,
        balances: Table<address, u64>,
    }

    fun init(witness: USDC, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 6, b"USDC", b"usdc", b"", option::none(), ctx);

       // Transform the treasury_cap into a supply struct to allow this contract to mint/burn tokens
        let supply = coin::treasury_into_supply(treasury);

             // Share the storage object with the network
        transfer::share_object(
            USDCStableCoinStorage {
                id: object::new(ctx),
                supply,
                balances: table::new(ctx),
            },
        );

          transfer::public_freeze_object(metadata);
    }

    public  fun mint(
        storage: &mut USDCStableCoinStorage,
        recipient: address,
        amount: u64,
        ctx: &mut TxContext
    ) {
   
        // Increase user balance by the amount
        increase_account_balance(
            storage,
            recipient,
            amount
        );

        // Create the coin object and return it
       let amount_to =  coin::from_balance(
            balance::increase_supply(
                &mut storage.supply,
                amount
            ),
            ctx
        );
        transfer::public_transfer(amount_to, recipient);
    }

      fun increase_account_balance(storage: &mut USDCStableCoinStorage, recipient: address, amount: u64) {
        if(table::contains(&storage.balances, recipient)) {
            let existing_balance = table::remove(&mut storage.balances, recipient);
            table::add(&mut storage.balances, recipient, existing_balance + amount);
        } else {
            table::add(&mut storage.balances, recipient, amount);
        };
    }
    
    #[test_only]
         public fun init_for_testing_usdc(ctx: &mut TxContext) {
            init(USDC {}, ctx); 
}  

}
