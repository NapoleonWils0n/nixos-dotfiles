# ~/git/nixos-dotfiles/flake.nix
{
  description = "Home Manager configuration for djwilcox on pollux";

  inputs = {
    # Nixpkgs, pointing to the unstable branch for the latest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # davinci resolve fix
    # You can also use a specific git commit hash to lock the version
    nixpkgs-ee930f975.url = "github:nixos/nixpkgs/ee930f9755f58096ac6e8ca94a1887e0534e2d81";

    # Home Manager itself
    home-manager = {
      url = "github:nix-community/home-manager"; # Defaults to master/unstable branch [1]
      # Crucial: Ensure Home Manager uses the same Nixpkgs as this flake
      # to prevent version conflicts and ensure consistency. [1, 2]
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-ee930f975,
    home-manager,
    ... }:
    let
      # Define the system architecture
      system = "x86_64-linux"; # For your MacBook Air 2011
      # Define your username
      username = "djwilcox"; # Replace with your actual username if different
    in
    {
      # Define the Home Manager configuration for your user on this host
      # The attribute name is typically "username@hostname" for standalone setups [3]
      homeConfigurations."${username}@pollux" = home-manager.lib.homeManagerConfiguration {
        # Pass the Nixpkgs instance to Home Manager
        pkgs = nixpkgs.legacyPackages.${system}; # Use the unstable nixpkgs for packages [3]
        
        # Pass extra arguments to your home.nix if needed.
        # For example, if your home.nix needs access to the 'inputs' set:
        extraSpecialArgs = {
          pkgs-ee930f975 = import nixpkgs-ee930f975 {
            inherit system;
            config.allowUnfree = true;
          };
        };
        
        # Import your existing home.nix file from its relative path within this repository [3]
        modules = [
        ./.config/home-manager/home.nix # Your existing Home Manager configuration
        ];
      };
    };
}
