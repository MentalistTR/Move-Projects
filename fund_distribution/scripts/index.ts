import { SuiClient, getFullnodeUrl } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import path, { dirname } from "path";
import { fileURLToPath } from "url";
import { execSync } from "child_process";
import { writeFileSync } from "fs";
import { keyPair1, parse_amount, find_one_by_type } from './helper'


let keypair = keyPair1();

const path_to_scripts = dirname(fileURLToPath(import.meta.url))
const client = new SuiClient({ url: getFullnodeUrl('testnet') });
const path_to_contracts = path.join(path_to_scripts, "../sources")

console.log("Building move code...")

const { modules, dependencies } = JSON.parse(execSync(
    `sui move build --dump-bytecode-as-base64 --path ${path_to_contracts}`,
    { encoding: "utf-8" }
))

console.log("Deploying contracts...");
console.log(`Deploying from ${keypair.toSuiAddress()}`)

const deploy_trx = new TransactionBlock()

const [upgrade_cap] = deploy_trx.publish({
    modules, dependencies
})

deploy_trx.transferObjects([upgrade_cap], deploy_trx.pure(keypair.toSuiAddress()))

const { objectChanges, balanceChanges } = await client.signAndExecuteTransactionBlock({
    signer: keypair, transactionBlock: deploy_trx, options: {
        showBalanceChanges: true,
        showEffects: true,
        showEvents: true,
        showInput: false,
        showObjectChanges: true,
        showRawInput: false
    }
})

if (!balanceChanges) {
    console.log("Error: Balance Changes was undefined")
    process.exit(1)
}

if (!objectChanges) {
    console.log("Error: object  Changes was undefined")
    process.exit(1)
}
console.log(objectChanges)

console.log(`Spent ${Math.abs(parse_amount(balanceChanges[0].amount))} on deploy`)

const published_change = objectChanges.find(change => change.type == "published")
if (published_change?.type !== "published") {
    console.log("Error: Did not find correct published change")
    process.exit(1)
}


// get package_id
const package_id = published_change.packageId

const deployed_address: any = {
    packageId: published_change.packageId,

    fundProject:{
        fundBalances: "",
        shareholders:"",
        AdminCap: "",
    },
    
    usdc:{
        USDCcointype:`${package_id}::usdc::USDC`
    },
    usdt:{
        USDTcointype:`${package_id}::usdt::USDT`
    }

}

// Get Fund_Balances Share object 
const fund_balances = `${deployed_address.packageId}::fund_project::Fund_Balances`

const fund_balances_id = find_one_by_type(objectChanges, fund_balances)
if (!fund_balances_id) {
    console.log("Error: Could not find Fund_balances object")
    process.exit(1)
}

deployed_address.fundProject.fundBalances = fund_balances_id;



// Get ShareHolder shareobject
const share_balances = `${deployed_address.packageId}::fund_project::ShareHolders`

const share_holders_id = find_one_by_type(objectChanges, share_balances)
if (!share_holders_id) {
    console.log("Error: Could not find Shareholder object")
    process.exit(1)
}

deployed_address.fundProject.shareholders = share_holders_id;

// Get AdminCap
const admin_cap = `${deployed_address.packageId}::fund_project::AdminCap`

const admin_cap_id = find_one_by_type(objectChanges, admin_cap)
if (!admin_cap_id) {
    console.log("Error: Could not find Admin object ")
    process.exit(1)
}

deployed_address.fundProject.AdminCap = admin_cap_id;


writeFileSync(path.join(path_to_scripts, "../scripts/deployed_objects.json"), JSON.stringify(deployed_address, null, 4))





// user deposit 100 SUI 
// DepositSuiBag(packageId, fundBalances)







