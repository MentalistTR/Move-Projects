module nft_tutorial::nft {
    use sui::object:: {Self, UID};
    use sui::transfer;
    use sui::tx_context:: {Self, TxContext};
    use std::string::{Self,String};
    use sui::object_table::{Self,ObjectTable};

    struct NFT has key, store {
        id: UID,
        name: String,
        description: String,
        owner: address,
    }

    public entry fun mint(name: vector<u8>, description: vector<u8>, ctx: &mut TxContext) {
        // create the new NFT

        let nft = NFT {
            id:object::new(ctx),
            name: string::utf8(name),
            description:string::utf8(description),   
            owner:tx_context::sender(ctx),
        };
        let sender = tx_context::sender(ctx);
        transfer::public_transfer(nft,sender);
    }

    public entry fun transfer(nft:NFT, recipient:address) {
        transfer::transfer(nft,recipient);
      //  change_owner(nft,recipient);
    }

    // public fun change_owner(nft: &mut NFT,recipient:address) {
    //     let nft_pro = nft;
    //     nft_pro.owner = recipient;
    // }

    #[test_only]

    public fun get_nft_property(nft:&NFT) : (String,String,address) {
    (
       nft.name,
       nft.description,
       nft.owner,
    )
}
















}