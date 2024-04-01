module stakingContract::mnt {
  use std::option;

  use sui::transfer;
  use sui::object::{Self, UID};
  use sui::tx_context::TxContext;
  use sui::coin::{Self, Coin, TreasuryCap};

  friend stakingContract::staking;

  struct MNT has drop {}

  // wrapped the TreasuryCap
  struct CapWrapper has key {
    id: UID,
    cap: TreasuryCap<MNT>
  }

  // === Init ===  

  #[lint_allow(share_owned)]
  fun init(witness: MNT, ctx: &mut TxContext) {
      let (treasury, metadata) = coin::create_currency<MNT>(
            witness, 
            9, 
            b"MNT",
            b"MNT Token", 
            b"Token for rewards", 
            option::none(), 
            ctx
        );

      transfer::share_object(CapWrapper { id: object::new(ctx), cap: treasury });
      transfer::public_freeze_object(metadata);
  }

  // === Public-Mutative Functions ===  

  public fun burn(cap: &mut CapWrapper, coin_in: Coin<MNT>): u64 {
    coin::burn(&mut cap.cap, coin_in)
  }

  // === Public-Friend Functions ===  

  public(friend) fun mint(cap: &mut CapWrapper, value: u64, ctx: &mut TxContext): Coin<MNT> {
    coin::mint(&mut cap.cap, value, ctx)
  }

  // === Test Functions ===  

  #[test_only]
  public fun return_init_mnt(ctx: &mut TxContext) {
    init(MNT {}, ctx);
  }
}