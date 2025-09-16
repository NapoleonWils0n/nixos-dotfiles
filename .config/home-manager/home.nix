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
    ./programs/dconf/dconf.nix
    ./programs/firefox/firefox.nix
  ];
 
  # xdg directories
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
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
    apg
    alacritty
    aria2
    ardour
    aspell
    aspellDicts.en
    bat
    bc
    chromium
    curl
    dict
    dconf-editor
    fd
    fdk-aac-encoder
    ffmpeg-full
    file
    fira-code
    gcc
    git
    gnome-tweaks
    gnumake
    grim
    handbrake
    imagemagick
    iosevka
    (kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
      inputstream-adaptive
    ]))
    libnotify
    libwebp
    lsp-plugins
    openssl
    mpc
    mpd
    mpv
    ncdu
    ncmpc
    nerd-fonts.fira-code
    noise-repellent
    noto-fonts-emoji
    nsxiv
    oath-toolkit
    openvpn
    pandoc
    pinentry-curses
    playerctl
    python314
    pwgen
    qpwgraph
    realesrgan-ncnn-vulkan
    rnnoise-plugin
    ripgrep
    sox
    tofi
    tmux
    translate-shell
    transmission_4-gtk
    tree
    ts
    unzip
    pkgs-master.yt-dlp
    wbg
    wget
    pkgs-master.widevine-cdm
    wl-clipboard
    wlrctl
    wlr-which-key
    zathura
    zip
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
  gnome-keyring = {
    enable = true;
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
