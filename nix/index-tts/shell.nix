{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell rec {
  name = "index-tts";
  buildInputs = with pkgs; [
    ffmpeg-full
    python311
    stdenv.cc.cc.lib
    stdenv.cc
    cudaPackages.cudatoolkit
    linuxPackages.nvidia_x11 # Seems necessary for CUDA context
    zlib # Common dependency
    ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
  CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
  EXTRA_LDFLAGS = "-L${pkgs.linuxPackages.nvidia_x11}/lib";

  shellHook = ''
    echo "Setting up environment for indextts with CUDA..."

    # Set the locale.
    export LC_ALL="en_US.UTF-8"
    export LANG="en_US.UTF-8"
    export PYTHONIOENCODING="utf-8"

    # Create and activate virtual environment
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      ${pkgs.python311}/bin/python3.11 -m venv .venv
    else
      echo "Re-activating existing Python virtual environment..."
    fi
    source .venv/bin/activate
    echo "Virtual environment activated."

    # Set CUDA variables
    export CUDA_VISIBLE_DEVICES=0
    export XDG_CACHE_HOME="$HOME/.cache"

    # pip upgrade
    pip install --upgrade pip

    # install torch torchaudio
    pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu121

    # install index-tts
    pip install -r ./requirements.txt
    pip install -e .

    echo "index-tts setup complete."
  '';
}
