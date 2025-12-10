# ~/git/nixos-dotfiles/flake.nix
{
  description = "Home Manager configuration for djwilcox on pollux";

  inputs = {
    # nixpkgs pointing to the unstable branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixpkgs pointing to the stable branch
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # nixpkgs master branch to get the latest packages no in unstable
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

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
    nixpkgs-stable,
    nixpkgs-master,
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
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-master = import nixpkgs-master {
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
