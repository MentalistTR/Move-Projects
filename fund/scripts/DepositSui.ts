import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { keyPair1, parse_amount, find_one_by_type} from './helper'
import data from './deployed_objects.json';
import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';


const packageId = data.packageId;
const fundBalances = data.fundProject.fundBalances;
const shareholders = data.fundProject.shareholders;
const usdc_cointype = data.usdc.USDCcointype;
const admincap = data.fundProject.AdminCap


export const DepositSuiBag = async (packageId: string, fund_balances_id: string) => {

    const keypair = keyPair1();
    const client = new SuiClient({ url: getFullnodeUrl('testnet') });

    const deposit_sui_bag = new TransactionBlock

    const [coin] = deposit_sui_bag.splitCoins(deposit_sui_bag.gas, ["1000000000"]);


    deposit_sui_bag.moveCall({
        target: `${packageId}::fund_project::deposit_to_bag_sui`,
        arguments: [deposit_sui_bag.object(fund_balances_id), coin]
    })

    console.log("User1 getting deposit sui...")

    const {objectChanges} = await client.signAndExecuteTransactionBlock({
        signer:keypair,
        transactionBlock: deposit_sui_bag,
        options: {showObjectChanges: true}
    })

    console.log(objectChanges)
}

await DepositSuiBag(packageId, fundBalances)