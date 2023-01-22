{ config, pkgs, ... }:

let

  unstable = import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
      overlays = [
        (import (builtins.fetchTarball {
          url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
        }))
      ];
    };

in {

    programs = {
      emacs = {
        enable = true;
        package = unstable.emacsPgtk;
        extraPackages = epkgs: with epkgs; [
          vterm
        ];
      };
      gpg = {
        enable = true;
      };
    };

    imports = [
      ./programs/firefox/firefox.nix
      ./programs/dconf/dconf.nix
    ];

    services = {
      emacs = {
        enable = true;
        client.enable = true;
      };
      gnome-keyring = {
        enable = true;
      };
      gpg-agent = {
        enable = true;
        extraConfig = ''
          allow-emacs-pinentry
          allow-loopback-pinentry
        '';
        pinentryFlavor = "curses";
      };
      mpd = {
        enable = true;
        musicDirectory = "~/Music";
        network = {
          startWhenNeeded = true;
        };
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "My PipeWire Output"
          }
        '';
      };
    };

    # systemd
    systemd.user.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      DISPLAY = ":0";
      WAYLAND_DISPLAY = "wayland-0";
    };


    # gtk
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

  # mpv mpris 
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris ];
      };
    })
  ];

  home.packages = with pkgs;[
    abook
    apg
    aria
    bat
    bc
    curl
    csvkit
    gnome.dconf-editor
    gnome.gnome-tweaks
    exiftool
    exa
    fd
    fzf
    ffmpeg
    fira-code
    git
    imagemagick
    jq
    lynx
    libxslt
    libnotify
    mediainfo
    mpc_cli
    mpd
    mpv
    mutt
    ncdu
    ncmpc
    newsboat
    nsxiv
    oathToolkit
    obs-studio
    openvpn
    pandoc
    pinentry-curses
    playerctl
    p7zip
    ripgrep
    socat
    sox
    shellcheck
    surfraw
    tmux
    transmission
    ts
    unzip
    viddy
    urlscan
    urlview
    yt-dlp
    w3m
    weechat
    widevine-cdm
    xclip
    zathura
    zip
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  manual.manpages.enable = false; # needed for dell xps15
  home.username = "djwilcox";
  home.homeDirectory = "/home/djwilcox";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
