{ config, pkgs, ... }:

let
home-manager = builtins.fetchTarball {
  url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
};
in
{
system.stateVersion = "25.05";

imports = [
  /etc/nixos/hardware-configuration.nix
  "${home-manager}/nixos"
];

############################# LOW-LEVEL STUFF #############################

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

networking.networkmanager = {
  enable = true;
  plugins = with pkgs; [
    networkmanager-l2tp
  ];
};
# fix networkmanager-l2tp
services.strongswan.enable = true;  # for IPsec
environment.etc."strongswan.conf".text = "";

time.timeZone = "Europe/Lisbon";
i18n.defaultLocale = "pt_PT.UTF-8";
services.xserver.xkb.layout = "pt";
console.keyMap = "pt-latin1";
i18n.inputMethod = {
  enable = true;  # required for keyboard accents to work
  type = "ibus";
};

services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;

# print
services.printing.enable = true;

# sound
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};

############################# PACKAGES #############################

nix = {  # keys for ROS https://github.com/lopsided98/nix-ros-overlay
  extraOptions = ''
    extra-substituters = https://ros.cachix.org
    extra-trusted-public-keys = ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=
  '';
};

system.autoUpgrade.enable = true;
nix.gc.automatic = true;

nixpkgs.config.allowUnfree = true;
environment.systemPackages = with pkgs; [
  ppp  # needed for L2TP to work
  tmux
  google-chrome
  vscode
  libreoffice
  git
  pinta inkscape
  transmission_4-gtk
  gummi texliveFull
  xournalpp pdfarranger gromit-mpx
  # Nix comes with many python packages, but pip has more packages
  # we can just do "python3 -m venv name" and then install packages there
  python3
];
services.flatpak.enable = true;

environment.variables = {
LD_LIBRARY_PATH =
  "/run/opengl-driver/lib:" +
  pkgs.lib.makeLibraryPath [
    # for pytorch
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.cudaPackages.cudatoolkit
  ];
};

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

nix.settings.experimental-features = [
  "nix-command"
  "flakes"
];

############################# MISC #############################

# disable suspend
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;
systemd.sleep.extraConfig = ''
  AllowSuspend=no
  AllowHibernation=no
  AllowHybridSleep=no
  AllowSuspendThenHibernate=no
'';

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

home-manager.users.rpcruz = { pkgs, lib, ... }: {
  home.stateVersion = "25.05";
  # git
  programs.git = {
    enable = true;
    settings.user = {
      name = "Ricardo Cruz";
      email = "ricardo.pdm.cruz@gmail.com";
    };
  };
  # ssh
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      atlas = { hostname = "atlas.fe.up.pt"; };
      login = { hostname = "atlas.fe.up.pt"; };
      compute = { hostname = "compute01.atlas.fe.up.pt"; };
      rfeup = { hostname = "10.227.91.107"; };
      mia = { hostname = "10.227.246.75"; };
      mia01 = { hostname = "10.227.246.73"; };
      mia02 = { hostname = "10.227.246.74"; };
      deucalion = { hostname = "login.deucalion.macc.fccn.pt"; user = "rcruz.up"; };
    };
  };
  # gnome stuff
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
      };
      "org/gnome/shell/extensions/forge" = {
        window-gap-hidden-on-single = true;
        window-gap-size-increment = lib.hm.gvariant.mkUint32 0;
      };
      "org/gnome/TextEditor" = {
        highlight-current-line = true;
        restore-session = false;
        show-line-numbers = true;
        spellcheck = false;
        tab-width = lib.hm.gvariant.mkUint32 4;
        indent-style = "space";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
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
      "org/gnome/file-roller/listing" = {
        list-mode = "as-folder";
      };
      "org/gnome/nautilus/list-view" = {
        default-visible-columns = ["name" "date_modified"];
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };
    };
  };
};

}
