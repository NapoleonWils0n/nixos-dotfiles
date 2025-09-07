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
            # Set the locale for consistent encoding
            export LC_ALL="en_US.UTF-8"
            export LANG="en_US.UTF-8"
            export PYTHONIOENCODING="utf-8"

            # Create and activate Python virtual environment
            if [ ! -d ".venv" ]; then
              echo "Creating Python virtual environment..."
              ${pkgs.python314}/bin/python3.14 -m venv .venv
            else
              echo "Re-activating existing Python virtual environment..."
            fi
            source .venv/bin/activate
            echo "Virtual environment activated."

            # Upgrade pip
            pip install --upgrade pip

            # install requests
            pip install -U requests

            echo "You can now run 'python3' by typing 'python3'."
            echo "To exit, press Ctrl+c."
          '';
        };
      });
}
