import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';
import { fromB64 } from "@mysten/sui.js/utils";
import { SuiObjectChange } from "@mysten/sui.js/client";
import { useCurrentAccount, useConnectWallet, useDisconnectWallet, useWallets, useSignTransactionBlock, useSignAndExecuteTransactionBlock } from '@mysten/dapp-kit'

import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SuiClient, getFullnodeUrl} from '@mysten/sui.js/client';
import {BigNumber} from 'bignumber.js';
import { bcs } from '@mysten/bcs';



export const keyPair1 = () => {
    const privkey = process.env.PRIVATE_KEY
if (!privkey) {
    console.log("Error: DEPLOYER_B64_PRIVKEY not set as env variable.")
    process.exit(1)
}
const keypair = Ed25519Keypair.fromSecretKey(fromB64(privkey).slice(1))
return keypair
}

export const parse_amount = (amount: string) => {
    return parseInt(amount) / 1_000_000_000
}

export const find_one_by_type = (changes: SuiObjectChange[], type: string) => {
    const object_change = changes.find(change => change.type == "created" && change.objectType == type)
    if (object_change?.type == "created") {
        return object_change.objectId
    }
}




