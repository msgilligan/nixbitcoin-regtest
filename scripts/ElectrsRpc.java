///usr/bin/env jbang "$0" "$@" ; exit $?
//JAVA 25+
//DEPS net.osslabz:json-rpc-client:0.0.4
//DEPS org.slf4j:slf4j-jdk14:2.0.17
import net.osslabz.jsonrpc.*;

void main() {
    var client = new JsonRpcTcpClient("localhost", 50001);
    Object[] params = {"json-rpc-client", "1.4"};
    var result = client.call("server.version", params);
    IO.println(result);
}
