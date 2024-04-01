module stakingContract::admin {

    // === Imports ===
    use sui::transfer::{Self};
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext, sender};

    use stakingContract::account::{Self as account, Pool};


    struct AdminCap has key {
        id: UID
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(AdminCap{
            id: object::new(ctx)
        }, sender(ctx));
    }

    public fun set_interest(_: &AdminCap, pool: &mut Pool, num: u128) {
        account::new_interest(pool, num);
    }


    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}
