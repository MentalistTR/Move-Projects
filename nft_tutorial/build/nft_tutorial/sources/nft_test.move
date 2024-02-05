#[test_only]

module nft_tutorial::nft_test {
    use sui::test_scenario as ts;
    use sui::object:: {Self,UID};
    use sui::transfer;
    use sui::tx_context:: {Self, TxContext};
    use std::string::String;
    use nft_tutorial::nft::{NFT};
    use nft_tutorial::nft;


#[test]

fun create_Test () {

  let owner: address = @0xA;
  let user1: address = @0xB;   
  let user2: address = @0xC;
  
  let scenario_test = ts::begin(owner);
  let scenario = &mut scenario_test;

  ts::next_tx(scenario,owner);
  {
   let name = b"vzus";
   let description = b"asd";

   nft::mint(name,description,ts::ctx(scenario));
  };

  ts::next_tx(scenario,owner);
  {

    let nft_take = ts::take_from_sender<NFT>(scenario);
    let nft_mut = &mut nft_take;
    
    let(_name,_description,_owner) = nft::get_nft_property(nft_mut);

     assert!(_owner == owner,2);
    ts::return_to_sender(scenario,nft_take);
  };

  ts::next_tx(scenario,owner);
  {
     let nft_take = ts::take_from_sender<NFT>(scenario);
     
     nft::transfer(nft_take,user1);
     
  };

  ts::next_tx(scenario,user1);
  {
  let nft_take = ts::take_from_sender<NFT>(scenario);
  nft::transfer(nft_take,user2);

  };

  ts::end(scenario_test);
}


}