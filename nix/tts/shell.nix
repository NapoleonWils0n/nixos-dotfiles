{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ pkgs.tts ];

  shellHook = ''
    export NIXPKGS_ALLOW_UNFREE=1
    echo "Coqui TTS environment loaded.  Run 'tts --help' for usage."
  '';
}
