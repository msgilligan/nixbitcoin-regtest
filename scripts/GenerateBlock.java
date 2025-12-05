///usr/bin/env jbang "$0" "$@" ; exit $?
//JAVA 25+
//REPOS mavencentral, consensusj=https://gitlab.com/api/v4/projects/8482916/packages/maven
//DEPS org.bitcoinj:bitcoinj-core:0.17
//DEPS com.msgilligan:cj-btc-jsonrpc:0.7.0-alpha3
//DEPS org.slf4j:slf4j-jdk14:2.0.17

import org.bitcoinj.utils.BriefLogFormatter;
import org.consensusj.bitcoin.jsonrpc.BitcoinClient;

import static org.consensusj.bitcoin.jsonrpc.BitcoinExtendedClient.DEFAULT_REGTEST_MINING_ADDRESS;
import static org.bitcoinj.base.BitcoinNetwork.REGTEST;

import java.net.URI;
import java.util.logging.Level;

final URI server = URI.create("http://localhost:18443");
final String user = "bitcoinrpc";
final String password = "pass";

void main() throws IOException {
    BriefLogFormatter.init(Level.WARNING);

    var client = new BitcoinClient(REGTEST, server, user, password);

    var genResult = client.generateToAddress(1, DEFAULT_REGTEST_MINING_ADDRESS);
    IO.println("Mined Blocks: " + genResult);

    var blockHeight = client.getBlockCount();
    IO.println("Block Height: " + blockHeight);
}
