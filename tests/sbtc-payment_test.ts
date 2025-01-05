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

Clarinet.test({
    name: "Ensure payment creation and processing works",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const merchant = accounts.get("wallet_1")!;
        const customer = accounts.get("wallet_2")!;
        const withdrawalAddress = accounts.get("wallet_3")!;
        const paymentAmount = 2000000; // 0.02 sBTC

        // Register merchant first
        let block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "register-merchant",
                [types.principal(withdrawalAddress.address)],
                merchant.address
            )
        ]);

        // Create payment
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "create-payment",
                [
                    types.principal(merchant.address),
                    types.uint(paymentAmount),
                    types.none()
                ],
                customer.address
            )
        ]);

        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result, "(ok u1)");

        // Process payment
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "process-pending-payment",
                [types.uint(1)],
                customer.address
            )
        ]);

        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result, "(ok true)");

        // Verify payment status
        const paymentInfo = chain.callReadOnlyFn(
            CONTRACT_NAME,
            "get-payment",
            [types.uint(1)],
            merchant.address
        );

        // Payment should be completed
        assertEquals(
            paymentInfo.result.includes('"completed"'),
            true
        );
    },
});

Clarinet.test({
    name: "Ensure admin functions work correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const merchant = accounts.get("wallet_1")!;
        const withdrawalAddress = accounts.get("wallet_2")!;

        // Register merchant
        let block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "register-merchant",
                [types.principal(withdrawalAddress.address)],
                merchant.address
            )
        ]);

        // Set new fee percentage
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "set-fee-percentage",
                [types.uint(200)], // 2%
                deployer.address
            )
        ]);

        assertEquals(block.receipts[0].result, "(ok true)");

        // Set merchant fee override
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "set-merchant-fee-override",
                [
                    types.principal(merchant.address),
                    types.some(types.uint(150)) // 1.5%
                ],
                deployer.address
            )
        ]);

        assertEquals(block.receipts[0].result, "(ok true)");

        // Toggle merchant status
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                "toggle-merchant-status",
                [types.principal(merchant.address)],
                deployer.address
            )
        ]);

        assertEquals(block.receipts[0].result, "(ok true)");

        // Verify contract info
        const contractInfo = chain.callReadOnlyFn(
            CONTRACT_NAME,
            "get-contract-info",
            [],
            deployer.address
        );

        // Contract info should show updated fee percentage
        assertEquals(
            contractInfo.result.includes("fee-percentage: u200"),
            true
        );
    },
});