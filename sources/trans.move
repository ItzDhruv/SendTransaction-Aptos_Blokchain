module dhruv::trans {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    /// Transfers Aptos (APT) tokens from sender to recipient.
    public entry fun send_aptos(
        sender: &signer, 
        recipient: address, 
        amount: u64
    ) {
        coin::transfer<aptos_coin::AptosCoin>(sender, recipient, amount);
    }
}
