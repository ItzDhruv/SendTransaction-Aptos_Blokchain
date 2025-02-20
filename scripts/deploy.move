script {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use dhruv::trans;

    const E_INSUFFICIENT_BALANCE: u64 = 1;
    const E_INVALID_RECIPIENT: u64 = 2;

    /// Script to demonstrate different ways to use the trans module
    fun transfer_examples(
        sender: signer,
        recipient_addr: address,
        amount: u64
    ) {
        // Get sender's address
        let sender_addr = signer::address_of(&sender);
        
        // Check if sender has sufficient balance
        assert!(
            coin::balance<AptosCoin>(sender_addr) >= amount,
            E_INSUFFICIENT_BALANCE
        );

        // Check if recipient account exists and is set up for APT
        assert!(
            coin::is_account_registered<AptosCoin>(recipient_addr),
            E_INVALID_RECIPIENT
        );

        // Perform the transfer using our module
        trans::send_aptos(&sender, recipient_addr, amount);
    }
}