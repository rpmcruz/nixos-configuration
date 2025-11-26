{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    sha256 = "07pk5m6mxi666dclaxdwf7xrinifv01vvgxn49bjr8rsbh31syaq";
  };
  hostName = builtins.getEnv "HOSTNAME";
  hostPath = "/etc/nixos/hosts/${hostName}.nix";
  hostConfig = if builtins.pathExists hostPath then hostPath else throw "Not found \"${hostPath}\" for HOSTNAME=\"${hostName}\"";
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    "${home-manager}/nixos"
    hostConfig
  ];

  ######################################### LOW-LEVEL STUFF #########################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostName;
  networking.networkmanager.enable = true;

  # fix networkmanager-l2tp
  services.strongswan.enable = true;  # for IPsec
  environment.etc."strongswan.conf".text = "";

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "pt_PT.UTF-8";
  services.xserver.xkb.layout = "pt";
  console.keyMap = "pt-latin1";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  ######################################### PACKAGES #########################################

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ppp  # needed for L2TP to work
    google-chrome
    vscode
    libreoffice
    git
    pinta
    transmission_4-gtk
    # micromamba has more packages than nix and comes with binaries (compiling things like
    # python313.torchWithCuda takes forever!
    micromamba
  ];

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

  ######################################### MISC #########################################

  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "25.05";
  system.autoUpgrade.enable = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  ######################################### USERS #########################################

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
    # initialize micromamba (which manages python environments)
    programs.bash = {
      enable = true;
      initExtra = ''
        eval "$(micromamba shell hook --shell bash --root-prefix $HOME/.micromamba)"
      '';
    };
    # git
    programs.git = {
      enable = true;
      userName = "Ricardo Cruz";
      userEmail = "ricardo.pdm.cruz@gmail.com";
    };
    # ssh
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host atlas
          HostName atlas.fe.up.pt
        Host compute
          HostName compute01.atlas.fe.up.pt
        Host rfeup
          HostName 10.227.91.107
        Host mia
          HostName 10.227.246.75
        Host mia01
          HostName 10.227.246.73
        Host mia02
          HostName 10.227.246.74
        Host deucalion
          HostName login.deucalion.macc.fccn.pt
          User rcruz.up
      '';
    };
    # gnome stuff
    home.packages = with pkgs.gnomeExtensions; [
      forge
      dash-to-panel
      clipboard-indicator
    ];
    dconf = {
      settings = {
        "org/gnome/desktop/interface" = {
          text-scaling-factor = 1.25;
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            forge.extensionUuid
            dash-to-panel.extensionUuid
            clipboard-indicator.extensionUuid
          ];
          favorite-apps = ["google-chrome.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "code.desktop"];
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
          switch-to-workspace-1 = ["<Super>F1"];
          switch-to-workspace-2 = ["<Super>F2"];
          switch-to-workspace-3 = ["<Super>F3"];
          switch-to-workspace-4 = ["<Super>F4"];
          switch-to-workspace-5 = ["<Super>F5"];
          switch-to-workspace-6 = ["<Super>F6"];
          switch-to-workspace-7 = ["<Super>F7"];
          switch-to-workspace-8 = ["<Super>F8"];
          switch-to-workspace-left = ["<Super>Left"];
          switch-to-workspace-right = ["<Super>Right"];
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
