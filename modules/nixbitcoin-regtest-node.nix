# NixOS Module for configuring a Nix Bitcoin RegTest Node. This should be reusable
# without needing modification, but it is intended for use on `regtest` only.
{ config, nixpkgs, nix-bitcoin, pkgs, localConfig, ... }:
  let
    zmqPorts = {
      pubrawblock = 38443;
      pubrawtx = 38444;
    };
  in {
  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  # Enable some services.
  # See nix-bitcoin for all available features.
  services.bitcoind = {
    enable = true;
    # `network` is a read-only setting that is set to "regtest" when `regtest = true`
    regtest = true;
    rpc.address = "0.0.0.0"; # Listen to RPC connections on all interfaces

    rpc.allowip = [
      "0.0.0.0/0" # Allow RPC connections from all external addresses
    ];

    rpc.users = {
      bitcoinrpc.passwordHMAC = "${localConfig.rpcHMAC}";
    };

    tor.enforce = false; # Set this if you're using the `secure-node.nix` template

    # Using ZMQ port recommendations from:  https://github.com/ConsensusJ/btcproxy/blob/master/doc/config.adoc
    zmqpubrawblock = nixpkgs.lib.mkForce "tcp://0.0.0.0:${toString zmqPorts.pubrawblock}";
    zmqpubrawtx = nixpkgs.lib.mkForce "tcp://0.0.0.0:${toString zmqPorts.pubrawtx}";
  };

  services.clightning = {
    enable = true;
    plugins.clnrest = {
      enable = true;
      address = "0.0.0.0";
    };
  };
  services.clightning-rest = {
    enable = true;
  };
  services.electrs.enable = true;
  services.electrs.address = "0.0.0.0";

  # When using nix-bitcoin as part of a larger NixOS configuration, the following enables
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = localConfig.userAccountName; # module parameter
  };

  # If you use a custom nixpkgs version for evaluating your system
  # (instead of `nix-bitcoin.inputs.nixpkgs` like in this example),
  # consider setting `useVersionLockedPkgs = true` to use the exact pkgs
  # versions for nix-bitcoin services that are tested by nix-bitcoin.
  # The downsides are increased evaluation times and increased system
  # closure size.
  #
  # nix-bitcoin.useVersionLockedPkgs = true;

  # Firewall ports to open
  networking.firewall.allowedTCPPorts = [
    config.services.bitcoind.rpc.port
    config.services.mempool.port
    config.services.mempool.frontend.port
    config.services.electrs.port
    config.services.clightning.plugins.clnrest.port
    config.services.clightning-rest.port
    config.services.clightning-rest.docPort
    zmqPorts.pubrawblock
    zmqPorts.pubrawtx
  ];
}
