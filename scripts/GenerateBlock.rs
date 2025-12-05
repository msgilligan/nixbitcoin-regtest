#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! bitcoin = "0.32.7"
//! corepc-client = { version = "0.10.0", features = ["client-sync"] }
//! ```

use bitcoin::address::{Address, NetworkUnchecked};
use bitcoin::Network;
use corepc_client::client_sync::v29::Client; 
use corepc_client::client_sync::Auth; 

const REGTEST_MINING_ADDRESS_STRING : &str = "mwQA8f4pH23BfHyy4zf8mgAyeNu5uoy6GU";
const URL : &str = "http://localhost:18443";
const USER : &str = "bitcoinrpc";
const PASSWORD : &str = "pass";

fn main() {
    let regtest_mining_address = REGTEST_MINING_ADDRESS_STRING
        .parse::<Address<NetworkUnchecked>>().unwrap()
        .require_network(Network::Regtest).unwrap();

    let auth = Auth::UserPass(USER.to_string(), PASSWORD.to_string());
    let client = Client::new_with_auth(URL, auth).unwrap();
    
    let block_hashes = client.generate_to_address(1, &regtest_mining_address).unwrap().0;
    let hash = block_hashes.get(0).unwrap();
    println!("Mined Block:  {}", hash);
    
    let block_count = client.get_block_count().unwrap().0;
    println!("Block Height: {}", block_count);
}
