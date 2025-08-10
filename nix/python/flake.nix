{
  description = "python";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "python-dev-shell";

          packages = with pkgs; [
            python314
          ];

          shellHook = ''
            echo "You can now run 'python3' by typing 'python3'."
            echo "To exit, press Ctrl+c."
          '';
        };
      });
}
