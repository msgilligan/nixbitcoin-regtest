///usr/bin/env java "$0" "$@" ; exit $?
//JAVA 25+
// Test script for accessing CLightning Rest API.

import module java.net.http;
import java.nio.charset.StandardCharsets;
import java.security.cert.X509Certificate;

String serverUri = "https://localhost:3010/v1/";
String UTF8 = StandardCharsets.UTF_8.name();

void main(String[] args) throws Exception {
    if (args.length != 2) {
        IO.println("Usage: ClnRpc <method> <rune>");
        System.exit(1);
    }
    var method = args[0];
    var rune = args[1];
    var client = buildClient();
    var req = switch(method) {
        case "list-methods" -> buildGetRequest(method, rune);
        default -> buildJsonRpcPostRequest(method, rune);
    };
    client.sendAsync(req, HttpResponse.BodyHandlers.ofString())
        .whenComplete(this::printResult)
        .join();
}

HttpClient buildClient() throws Exception {
    // Trust manager that accepts all certificates
    TrustManager[] trustAllCerts = new TrustManager[] {
        new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
            public void checkClientTrusted(X509Certificate[] certs, String authType) {}
            public void checkServerTrusted(X509Certificate[] certs, String authType) {}
        }
    };

    // Create SSLContext that uses the all-trusting manager
    SSLContext sslContext = SSLContext.getInstance("TLS");
    sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

    // Disable hostname verification
    SSLParameters sslParams = new SSLParameters();
    sslParams.setEndpointIdentificationAlgorithm(""); // disables host name verification

    // Build the HttpClient
    return HttpClient.newBuilder()
                    .sslContext(sslContext)
                    .sslParameters(sslParams)
                    .connectTimeout(Duration.ofMinutes(2))
                    .build();
}

HttpRequest buildGetRequest(String method, String rune) {
    return HttpRequest
            .newBuilder(URI.create(serverUri + method))
            .header("Rune", rune)
            .header("Accept-Charset", UTF8)
            .GET()
            .build();
}

HttpRequest buildJsonRpcPostRequest(String method, String rune) {
    return HttpRequest
            .newBuilder(URI.create(serverUri + method))
            .header("Rune", rune)
            .header("Accept-Charset", UTF8)
            .header("Accept", "application/json")
            .POST(HttpRequest.BodyPublishers.noBody())
            .build();
}

void printResult(HttpResponse<String> r, Throwable t) {
    if (r != null) {
        IO.println(r.body());
    } else {
        IO.println("Exception: " + t);
    }
}

