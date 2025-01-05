import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

const CONTRACT_NAME = "sbtc-payment";

Clarinet.test({
    name: "Ensure merchant registration works correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const merchant = accounts.get("wallet_1")!;
        const withdrawalAddress = accounts.get("wallet_2")!;

        // Test merchant registration
        let block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "register-merchant",
                [types.principal(withdrawalAddress.address)],
                merchant.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result, "(ok true)");

        // Verify merchant info
        const merchantInfo = chain.callReadOnlyFn(
            CONTRACT_NAME,
            "get-merchant-info",
            [types.principal(merchant.address)],
            deployer.address
        );

        assertEquals(
            merchantInfo.result,
            `(some {active: true, fee-override: none, payment-count: u0, total-volume: u0, withdrawal-address: (some ${withdrawalAddress.address})})`
        );
    },
});