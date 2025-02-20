#[test_only]
module dhruv::trans_tests {
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::coin::{Self};
    use aptos_framework::aptos_coin;
    use dhruv::trans;

    // Test helper function to set up test accounts with initial balances
    fun setup_test_accounts(
        aptos_framework: &signer,
        sender: &signer,
        recipient: &signer,
        initial_balance: u64
    ) {
        // Initialize the Aptos coin
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);

        // Create and fund accounts
        let sender_addr = signer::address_of(sender);
        let recipient_addr = signer::address_of(recipient);
        
        account::create_account_for_test(sender_addr);
        account::create_account_for_test(recipient_addr);

        coin::register<aptos_coin::AptosCoin>(sender);
        coin::register<aptos_coin::AptosCoin>(recipient);

        // Fund sender account
        aptos_coin::mint(aptos_framework, sender_addr, initial_balance);

        // Clean up test resources
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test]
    public fun test_successful_transfer() {
        // Set up test environment
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        let sender = account::create_account_for_test(@0x123);
        let recipient = account::create_account_for_test(@0x456);
        
        // Initialize accounts with 100 APT
        setup_test_accounts(&aptos_framework, &sender, &recipient, 100);

        // Transfer 50 APT
        trans::send_aptos(&sender, @0x456, 50);

        // Verify balances
        assert!(coin::balance<aptos_coin::AptosCoin>(@0x123) == 50, 0);
        assert!(coin::balance<aptos_coin::AptosCoin>(@0x456) == 50, 1);
    }

    #[test]
    #[expected_failure(abort_code = 0x10006, location=aptos_framework::coin)]
    public fun test_insufficient_balance() {
        // Set up test environment
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        let sender = account::create_account_for_test(@0x123);
        let recipient = account::create_account_for_test(@0x456);
        
        // Initialize sender with only 10 APT
        setup_test_accounts(&aptos_framework, &sender, &recipient, 10);

        // Try to transfer 50 APT (should fail)
        trans::send_aptos(&sender, @0x456, 50);
    }

    #[test]
    #[expected_failure(abort_code = 0x60005, location=aptos_framework::coin)]
    public fun test_transfer_to_unregistered_recipient() {
        // Set up test environment
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        let sender = account::create_account_for_test(@0x123);
        
        // Initialize only sender account
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(&aptos_framework);
        account::create_account_for_test(@0x123);
        coin::register<aptos_coin::AptosCoin>(&sender);
        aptos_coin::mint(&aptos_framework, @0x123, 100);
        
        // Try to transfer to unregistered account (should fail)
        trans::send_aptos(&sender, @0x456, 50);

        // Clean up
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }
}