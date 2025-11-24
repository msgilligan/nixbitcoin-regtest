{
  description = "Nix Bitcoin RegTest VM Flake";

  inputs = {
    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";

    nixpkgs.follows = "nix-bitcoin/nixpkgs";
    nixpkgs-unstable.follows = "nix-bitcoin/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-bitcoin, home-manager, nixos-lima, deploy-rs, ... }@inputs:
    let
      # FIXME: Edit `local-config.nix` to have your local/preferred settings
      localConfig = import ./local-config.nix;
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forEachSystem = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) systems);
    in {
      # devShell that can be used to install VM via lima, deploy-rs and run the test script with JDK 25.
      devShells = forEachSystem(system:
        let
        #inherit (pkgs) stdenv;
        pkgs = import nixpkgs { inherit system; };
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        in {
        default = pkgs.mkShell {
           buildInputs = [
              pkgs.curl
              pkgs.jq
              pkgs-unstable.bitcoind
              pkgs-unstable.lima
              pkgs-unstable.deploy-rs
              pkgs-unstable.jdk25
              (pkgs-unstable.jbang.override { jdk = pkgs-unstable.jdk25; })
            ];
          shellHook = ''
            alias bcli='bitcoin-cli -conf=$PWD/config/bitcoin.conf'
            echo "Welcome to nixbitcoin-regtest!"
          '';
        };
      });

    # nixbitcoin-regtest installs home-manager as a NixOS module, so deploy-rs can configure everything
    nixosConfigurations.nixbitcoin-regtest = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      # Pass the `nixos-lima` input along with the default module system parameters
      specialArgs = { inherit nixpkgs nix-bitcoin nixos-lima localConfig ; };
      modules = [
        nix-bitcoin.nixosModules.default
        ./hosts/nixbitcoin-regtest-lima.nix
        ./modules/nixbitcoin-regtest-node.nix
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${localConfig.userAccountName} = {
              imports = [ ./home/home-minimal.nix ];
            };
            home-manager.extraSpecialArgs = {
            };
          }
      ];
    };
    # Nodes deployed by the deploy-rs tool
    deploy = {
      nodes = {
        "nixbitcoin-regtest" = {
          hostname = "lima-nixbitcoin-regtest"; # Include ~/.lima/nixbtc-regtest/ssh.config in ~/.ssh/config to find port, user
          profiles.system = {
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.nixbitcoin-regtest;
            user = "root";
          };
        };
      };
    };
  };
}
