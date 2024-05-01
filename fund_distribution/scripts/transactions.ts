import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { keyPair1, parse_amount, find_one_by_type} from './helper'
import data from './deployed_objects.json';
import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';
import { DepositSuiBag } from './DepositSui';

const packageId = data.packageId;
const fundBalances = data.fundProject.fundBalances;
const shareholders = data.fundProject.shareholders;
const usdc_cointype = data.usdc.USDCcointype;
const admincap = data.fundProject.AdminCap;
const SuiCoin = "0x2::sui::SUI";
const UsdcCoin = "0xc77c942b463535551deb1ac83ef58e9c95e2ef011abfbed6c8de4554c92ac3a7";


export const SetShareHolders = async (address1:string, address2:string, address3:string) => {

    const keypair = keyPair1();
    const client = new SuiClient({ url: getFullnodeUrl('testnet') });
    const setshareholders = new TransactionBlock

    // const shareholdersVecPercantages = setshareholders.makeMoveVec({ objects: ["30" , "30"," 40"]});
     console.log("admin set shareholders...")
    
    // define the shareholders addresses
    const test1 = [address1, address2, address3]
    console.log(test1)
    setshareholders.moveCall({
        target: `${packageId}::fund_project::set_shareholders`,
        arguments: [setshareholders.object(admincap), setshareholders.object(shareholders),setshareholders.pure(test1), setshareholders.pure([4000,3000,3000]) ]
    });

    const {objectChanges}= await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: setshareholders,
        options: {showObjectChanges: true}
    })
    console.log(objectChanges);

}

export const FundDistribution= async (coin:any, coinName:string, amount:number) => {

    const keypair = keyPair1()
    const client = new SuiClient({ url: getFullnodeUrl('testnet') });
    const txb = new TransactionBlock

    console.log("admin distribution funds...")

    txb.moveCall({
        target: `${packageId}::fund_project::fund_distribution`,
        arguments:[
        txb.object(admincap),
        txb.object(fundBalances),
        txb.object(shareholders),
        txb.pure(amount),
        txb.pure(coinName)    
        ],
        typeArguments: [coin]
    })

    const {objectChanges, balanceChanges}= await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: txb,
        options: {
        showObjectChanges: true,
        showEffects: true,
        showEvents: true,
        showInput: false,
        showRawInput: false
    }
    })
    // if (!balanceChanges) {
    //     console.log("Error: Balance Changes was undefined")
    //     process.exit(1)
    // }
    
    if (!objectChanges) {
        console.log("Error: object  Changes was undefined")
        process.exit(1)
    }

    console.log(objectChanges);
    // console.log(balanceChanges)
}

export const ShareholderWithdraw = async (privatekey:string, coin:string, coinName:string, amount:number) => {
    
    const shareholder1PrivateKey = privatekey ;
    const client = new SuiClient({ url: getFullnodeUrl('testnet') });
    const txb = new TransactionBlock;
    const keypair = Ed25519Keypair.deriveKeypair(shareholder1PrivateKey);

    console.log(`shareholder1 withdraw ${coinName} ...`);

    txb.moveCall({
        target: `${packageId}::fund_project::shareholder_withdraw`,
        arguments:[
         txb.object(shareholders),
         txb.pure(amount),
         txb.pure(coinName),
        ],
        typeArguments: [coin]
    })

    const {objectChanges, balanceChanges}= await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: txb,
        options: {
        showObjectChanges: true,
        showEffects: true,
        showEvents: true,
        showInput: false,
        showRawInput: false
    }
    })
 
    if (!objectChanges) {
        console.log("Error: object  Changes was undefined")
        process.exit(1)
    }

    console.log(objectChanges);
}

export const AdminWithdraw = async (coin:string, coinName:string) => {
    
    const keypair = keyPair1()
    const client = new SuiClient({ url: getFullnodeUrl('testnet') });
    const txb = new TransactionBlock;
   

    console.log("admin withdraw USDC...");

    txb.moveCall({
        target: `${packageId}::fund_project::admin_withdraw`,
        arguments:[
         txb.object(admincap),
         txb.object(fundBalances),
         txb.pure(1000000000),
         txb.pure(coinName),
        ],
        typeArguments: [coin]
    })

    const {objectChanges, balanceChanges}= await client.signAndExecuteTransactionBlock({
        signer: keypair,
        transactionBlock: txb,
        options: {
        showObjectChanges: true,
        showEffects: true,
        showEvents: true,
        showInput: false,
        showRawInput: false
    }
    })
 
    if (!objectChanges) {
        console.log("Error: object  Changes was undefined")
        process.exit(1)
    }

    console.log(objectChanges);
}

//   await DepositSuiBag(packageId, fundBalances)
//   await SetShareHolders("0x170c2b10ec624e2c3d28a88fbede893f5e1ba7940761c81a61bb5cf764823885",
//   "0x5fb75c1761c43acfd30b99443d4307101f57391cb1a4b7eb5d795fd91a8aa87a",
//   "0xb1f0fc1cf4a4898a77a5b1b3f9216a4dee2f317b1498820ac0ed362c6d9308c8");

 //await FundDistribution(usdc_cointype, "usdc", 100);

 // await ShareholderWithdraw() 

 // await AdminWithdraw()

 await ShareholderWithdraw("retreat great sister bunker letter victory usual bright young vault busy deputy", usdc_cointype, "usdc", 30000000000)
