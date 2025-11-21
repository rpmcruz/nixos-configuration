{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    sha256 = "0q3lv288xlzxczh6lc5lcw0zj9qskvjw3pzsrgvdh8rl8ibyq75s";
  };
in
{
  imports = [
      /etc/nixos/hardware-configuration.nix
      "${home-manager}/nixos"
    ];

  ######################################### LOW-LEVEL STUFF #########################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # fix networkmanager-l2tp
  services.strongswan.enable = true;  # for IPsec
  environment.etc."strongswan.conf".text = "";

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "pt_PT.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "pt";
    variant = "";
  };
  console.keyMap = "pt-latin1";

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

  ######################################### USERS #########################################

  users.users.rpcruz = {
    isNormalUser = true;
    description = "Ricardo Cruz";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  home-manager.users.rpcruz = { pkgs, ... }: {
    home.stateVersion = "25.05";
    home.packages = with pkgs.gnomeExtensions; [
      forge
      dash-to-panel
      clipboard-indicator
    ];
    dconf = {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            forge.extensionUuid
            dash-to-panel.extensionUuid
            clipboard-indicator.extensionUuid
          ];
          favorite-apps = ["google-chrome.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "code.desktop"];
        };
        "org/gnome/shell/extensions/dash-to-panel" = {
          panel-anchors=''{"BOE-0x00000000":"MIDDLE"}'';
          panel-element-positions=''{"BOE-0x00000000":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"dateMenu","visible":true,"position":"centered"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'';
          panel-lengths=''{"BOE-0x00000000":100}'';
          panel-positions=''{"BOE-0x00000000":"TOP"}'';
          panel-sizes=''{"BOE-0x00000000":32}'';
        };
        "org/gnome/shell/extensions/forge" = {
          window-gap-hidden-on-single = true;
          window-gap-size-increment = 0;
        };
        "org/gnome/TextEditor" = {
          highlight-current-line = true;
          restore-session = false;
          show-line-numbers = true;
          spellcheck = false;
          tab-width = 4;
        };
        "org/gnome/desktop/wm/keybindings" = {
          move-to-workspace-left = ["<Shift><Super>Left"];
          move-to-workspace-right = ["<Shift><Super>Right"];
          switch-to-workspace-1 = ["<Control>F1"];
          switch-to-workspace-2 = ["<Control>F2"];
          switch-to-workspace-3 = ["<Control>F3"];
          switch-to-workspace-4 = ["<Control>F4"];
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

  ######################################### PACKAGES #########################################

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    pkgs.ppp  # needed for L2TP to work
    google-chrome
    vscode
    libreoffice
    python3
    git
    pinta
  ];

  ######################################### MISC #########################################

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "25.05";
}
