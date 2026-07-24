{ config, pkgs, ... }:

let
home-manager = builtins.fetchTarball { url = "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz"; };
nix-flatpak = builtins.fetchTarball { url = "https://github.com/gmodena/nix-flatpak/archive/latest.tar.gz"; };
in
{
system.stateVersion = "25.11";

imports = [
  /etc/nixos/hardware-configuration.nix
  "${home-manager}/nixos"
  "${nix-flatpak}/modules/nixos.nix"
];

############################# LOW-LEVEL STUFF #############################

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

networking.networkmanager.plugins = with pkgs; [
  networkmanager-l2tp
];
# fix networkmanager-l2tp
services.strongswan.enable = true;  # for IPsec
environment.etc."strongswan.conf".text = "";

time.timeZone = "Europe/Lisbon";
i18n.defaultLocale = "pt_PT.UTF-8";
services.xserver.xkb.layout = "pt";
console.useXkbConfig = true;

services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;

# sound
services.pipewire.alsa.support32Bit = true;
security.rtkit.enable = true;

############################# PACKAGES #############################

system.autoUpgrade.enable = true;
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};
nix.settings.auto-optimise-store = true;

nixpkgs.config.allowUnfree = true;
environment.systemPackages = with pkgs; [
  ppp  # needed for L2TP to work
  tmux
  google-chrome
  vscode claude-code openspec
  libreoffice
  git
  pinta inkscape
  transmission_4-gtk
  gummi texliveFull
  xournalpp pdfarranger gromit-mpx meld
  pandoc poppler-utils  # pdfimages and etc
  vokoscreen-ng
  handbrake  # movies format conversion
  # Nix comes with many python packages, but pip has more packages
  # we can just do "python3 -m venv name" and then install packages there
  python3
];

services.flatpak = {
  enable = true;
  remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
  packages = [
    rec {
      appId = "pt.gov.autenticacao";
      sha256 = "1sfw6kji81rc60811h67x6dj22gav4wjrnv6ils6wqgyjbayx5in";
      bundle = "${pkgs.fetchurl {
        url = "https://aplicacoes.autenticacao.gov.pt/apps/pteid-mw-linux.x86_64.flatpak";
        inherit sha256;
      }}";
    }
  ];
};

environment.variables = {
  LD_LIBRARY_PATH =  # for pip packages like pytorch
    "/run/opengl-driver/lib:" +
    pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.cudaPackages.cudatoolkit
    ];
};

# the following is required by some apps, namely vscode-claude-extension
programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [
  stdenv.cc.cc.lib  # libstdc++
  zlib
  openssl
];

/*
# allow running things like virt-manager
programs.virt-manager.enable = true;
virtualisation.libvirtd.enable = true;
virtualisation.spiceUSBRedirection.enable = true;
networking.firewall.trustedInterfaces = ["virbr0"];
systemd.services.libvirt-default-network = {
  description = "Start libvirt default network";
  after = ["libvirtd.service"];
  wantedBy = ["multi-user.target"];
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
    ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
    User = "root";
  };
};

# allow running docker images (podman is compatible)
virtualisation.podman.enable = true;
virtualisation.podman.dockerCompat = true;
*/

############################# MISC #############################

# disable suspend
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;
systemd.sleep.settings.Sleep = {
  AllowSuspend = false;
  AllowHibernation = false;
  AllowHybridSleep = false;
  AllowSuspendThenHibernate = false;
};

services.openssh.enable = true;
networking.firewall.enable = false;

############################# USERS #############################

users.users.rpcruz = {
  isNormalUser = true;
  description = "Ricardo Cruz";
  extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  packages = with pkgs; [
  ];
};
security.sudo.wheelNeedsPassword = false;

home-manager.users.rpcruz = { pkgs, lib, ... }:
# it takes a while for forge to support the new gnome version in nixpkgs
let forge = pkgs.gnomeExtensions.forge.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    substituteInPlace \
      $out/share/gnome-shell/extensions/forge@jmmaranan.com/metadata.json \
      --replace-fail '"49"]' '"49", "50"]'
    '';
  });
in {
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  programs.git = {
    enable = true;
    settings.user = {
      name = "Ricardo Cruz";
      email = "ricardo.pdm.cruz@gmail.com";
    };
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      atlas = { HostName = "atlas.fe.up.pt"; };
      login = { HostName = "atlas.fe.up.pt"; };
      compute = { HostName = "compute01.atlas.fe.up.pt"; };
      rfeup = { HostName = "10.227.91.107"; };
      cilia = { HostName = "10.227.246.79"; };
      mia = { HostName = "10.227.246.75"; };
      mia01 = { HostName = "10.227.246.73"; };
      mia02 = { HostName = "10.227.246.74"; };
      deucalion = { HostName = "login.deucalion.macc.fccn.pt"; user = "rcruz.up"; };
    };
  };
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh ms-vscode.remote-explorer
      ms-python.python ms-python.debugpy ms-python.vscode-pylance ms-python.vscode-python-envs
      james-yu.latex-workshop
      anthropic.claude-code
    ];
  };
  home.file.".config/Code/User/settings.json".text = builtins.toJSON {
    "editor.wordWrap" = true;
    "editor.minimap.enabled" = false;
    "chat.commandCenter.enabled" = false;
    "claudeCode.preferredLocation" = "panel";
    "claudeCode.allowDangerouslySkipPermissions" = true;
  };
  home.packages = with pkgs.gnomeExtensions; [
    forge
    dash-to-panel
    clipboard-indicator
    appindicator
  ];
  dconf = {
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          forge.extensionUuid
          dash-to-panel.extensionUuid
          clipboard-indicator.extensionUuid
          appindicator.extensionUuid
        ];
        favorite-apps = ["google-chrome.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "code.desktop"];
      };
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
      };
      "org/gnome/desktop/session" = {
        idle-delay = lib.hm.gvariant.mkUint32 1800;
      };
      "org/gnome/desktop/interface" = {
        text-scaling-factor = 1.25;
        cursor-size = 32;
        gtk-enable-primary-paste = true;
      };
      "org/gnome/mutter" = {
        auto-maximize = false;
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/shell/extensions/forge" = {
        window-gap-hidden-on-single = true;
        window-gap-size-increment = lib.hm.gvariant.mkUint32 0;
        focus-on-hover-enabled = true;
        dnd-center-layout = "swap";
        tabbed-tiling-mode-enabled = false;
        stacked-tiling-mode-enabled = false;
      };
      "org/gnome/desktop/wm/keybindings" = {
        move-to-workspace-left = ["<Shift><Super>Left"];
        move-to-workspace-right = ["<Shift><Super>Right"];
        switch-to-workspace-1 = ["<Control>F1"];
        switch-to-workspace-2 = ["<Control>F2"];
        switch-to-workspace-3 = ["<Control>F3"];
        switch-to-workspace-4 = ["<Control>F4"];
        switch-to-workspace-5 = ["<Control>F5"];
        switch-to-workspace-6 = ["<Control>F6"];
        switch-to-workspace-7 = ["<Control>F7"];
        switch-to-workspace-8 = ["<Control>F8"];
        switch-to-workspace-left = ["<Super>Left"];
        switch-to-workspace-right = ["<Super>Right"];
        switch-applications = [];
        switch-applications-backward = [];
        switch-windows = ["<Super>Tab"];
        switch-windows-backward = ["<Shift><Super>Tab"];
      };
      "org/gnome/nautilus/list-view" = {
        default-visible-columns = ["name" "date_modified"];
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };
      "org/gnome/TextEditor" = {
        highlight-current-line = true;
        restore-session = false;
        show-line-numbers = true;
        spellcheck = false;
        tab-width = lib.hm.gvariant.mkUint32 4;
        indent-style = "space";
      };
    };
  };
};

}
