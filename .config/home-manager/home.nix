{
  config,
  pkgs,
  pkgs-stable,
  pkgs-master,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "djwilcox";
  home.homeDirectory = "/home/djwilcox";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  imports = [
    ./programs/firefox/firefox.nix
  ];

  # dconf
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
     color-scheme = "prefer-dark";
  };
  };
 
  # xdg directories
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      publicShare = null;
      templates = null;
    };
  };

  nixpkgs.config.allowUnfree = true;

  #emacs
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  }; 


  # --- OBS Studio Configuration for wlrobs ---
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [
      obs-studio-plugins.wlrobs
    ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    abook
    adwaita-qt6
    apg
    alacritty
    aria2
    aspell
    aspellDicts.en
    bash-language-server
    bat
    bc
    chromium
    curl
    csvkit
    cryptsetup
    darktable
    deno
    dict
    dictdDBs.wordnet
    dictdDBs.wiktionary
    fd
    fdk-aac-encoder
    ffmpeg-full
    ffmpegthumbnailer
    file
    fira-code
    gcc
    gimp-with-plugins
    git
    gnumake
    grim
    graphviz
    imagemagick
    imv
    iosevka
    kodi-wayland
    libnotify
    libwebp
    openssl
    mpc
    mpd
    mpv
    ncdu
    ncmpc
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    nixd
    oath-toolkit
    obs-cmd
    openvpn
    pandoc
    pinentry-curses
    playerctl
    python313Packages.python-lsp-server
    python314
    pwgen
    qbittorrent
    qpwgraph
    realesrgan-ncnn-vulkan
    ripgrep
    shellcheck-minimal
    sox
    tofi
    tor-browser
    tmux
    translate-shell
    tree
    ts
    unzip
    yt-dlp
    wbg
    wget
    widevine-cdm
    wl-clipboard
    wlrctl
    wlr-which-key
    zathura
    zip
    virt-manager
    virt-viewer
    spice 
    spice-gtk 
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  # home sessions variables
  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

services = {
  emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
  gpg-agent = {
    enable = true;
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
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
#  WAYLAND_DISPLAY = "wayland-0";
};


# dwl wayland socket
systemd.user.services.link-wayland-display = {
    Unit = {
      Description = "Link WAYLAND_DISPLAY for dwl portals";
      # Only run this if we aren't in COSMIC
      ConditionEnvironment = "!XDG_CURRENT_DESKTOP=COSMIC";
      After = [ "graphical-session-pre.target" ];
      Partof = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      # Wait briefly for dwl to create the socket, then push variables to systemd
      ExecStart = pkgs.writeShellScript "link-wayland" ''
        while [ ! -S "$XDG_RUNTIME_DIR/wayland-0" ]; do
          sleep 0.1
        done
        ${pkgs.systemd}/bin/systemctl --user set-environment WAYLAND_DISPLAY=wayland-0
        ${pkgs.systemd}/bin/systemctl --user set-environment XDG_CURRENT_DESKTOP=dwl
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      '';
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
};

# gtk
gtk = {
  enable = true;
  gtk4.theme = null;
  gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
  gtk4.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };
};

# qt
qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt6;
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/djwilcox/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
