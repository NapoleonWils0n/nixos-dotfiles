{
  description = "A development shell for WhisperX with CUDA support";

  inputs = {
    # Pinning to the latest NixOS unstable
    nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # Necessary for NVIDIA drivers and CUDA
          };
        };
      in
      {
        devShells.default = pkgs.mkShell rec {
          name = "whisperx-dev";

          # Essential build inputs for CUDA and Python environment
          buildInputs = with pkgs; [
            python312 # Python interpreter for creating the venv
            stdenv.cc.cc.lib # C standard library
            stdenv.cc        # C compiler
            cudaPackages.cudatoolkit # Default CUDA toolkit from NixOS 25.05 (likely 12.x)
            cudaPackages.cudnn  
            linuxPackages.nvidia_x11 # Host NVIDIA X11 drivers (for libcuda.so)
            zlib # Common dependency
            # --- NEW MEDIA/BUILD DEPENDENCIES FOR PYAV/FFMPEG ---
            pkg-config # Required for finding C libraries during python wheel build
            ffmpeg     # Core library for audio/video processing (PyAV backend)
            libiconv   # Character encoding conversion library
            libxml2    # XML parsing library
          ];

          # Environment variables required for CUDA and library linking
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
          CUDA_HOME = pkgs.cudaPackages.cudatoolkit;
          EXTRA_LDFLAGS = "-L${pkgs.linuxPackages.nvidia_x11}/lib";

          # Ensure CUDA binaries (like nvidia-smi) are in PATH for diagnostics
          PATH = pkgs.lib.makeBinPath [
            pkgs.cudaPackages.cudatoolkit
          ];

          # Shell hook to set up the Python virtual environment and install dependencies
          shellHook = ''
            echo "Entering WhisperX development shell with CUDA support"
            echo "Note: PyTorch and WhisperX will be installed via pip within a virtual environment."

            # Set the locale for consistent encoding
            export LC_ALL="en_US.UTF-8"
            export LANG="en_US.UTF-8"
            export PYTHONIOENCODING="utf-8"

            # Create and activate Python virtual environment
            if [ ! -d ".venv" ]; then
              echo "Creating Python virtual environment..."
              ${pkgs.python312}/bin/python3.12 -m venv .venv
            else
              echo "Re-activating existing Python virtual environment..."
            fi
            source .venv/bin/activate
            echo "Virtual environment activated."

            # Set CUDA variables
            export CUDA_VISIBLE_DEVICES=0
            export XDG_CACHE_HOME="$HOME/.cache"

            # Upgrade pip
            pip install --upgrade pip

            # Set environment variable to prevent silent async CUDA errors (Crucial for debugging low-level crashes)
            export CUDA_LAUNCH_BLOCKING=1
            export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=true

            # cuda 13
            pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu130

            # install whisperx
            pip install -U whisperx

            echo "WhisperX setup complete. You can now use 'whisperx' command."
          '';
        };
      });
}
