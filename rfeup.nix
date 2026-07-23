{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "rfeup";

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = true;
  modesetting.enable = false;
};
hardware.graphics.enable = true;

/*
users.users.miguel = {
  isNormalUser = true;
  packages = with pkgs; [
    python3 micromamba uv poetry
    gcc
  ];

};
home-manager.users.miguel = {
  home.stateVersion = "25.11";
  home.sessionVariables = {
    ES2_LIBRARY = "${pkgs.libglvnd}/lib/libGLESv2.so.2";
    VISPY_GL_LIB = "${pkgs.libglvnd}/lib/libGL.so.1";
    LD_LIBRARY_PATH =
      "/run/opengl-driver/lib:" +
      (with pkgs; lib.makeLibraryPath [
        # for pytorch
        stdenv.cc.cc.lib
        zlib
        cudaPackages.cudatoolkit
        # micro-sam
        libGL libglvnd mesa
        # cellpose-sam
        glib fontconfig libX11 libxkbcommon freetype dbus libxcb
        xcb-util-cursor wayland
        zstd
        libxcb libxext libxrender libxi libxrandr libxcursor libsm libice
        xcbutil xcbutilimage xcbutilkeysyms xcbutilrenderutil xcbutilwm
        libxtst
      ]);
  };
  programs.bash = {
    enable = true;
    initExtra = ''
      export MAMBA_ROOT_PREFIX="''${MAMBA_ROOT_PREFIX:-$HOME/micromamba}"
      __mamba_setup="$(micromamba shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
      if [ $? -eq 0 ]; then
        eval "$__mamba_setup" 2>/dev/null
        micromamba() { __mamba_wrap "$@"; }
      fi
      unset __mamba_setup
    '';
  };
};

services.xserver.desktopManager.xfce.enable = true;
services.xrdp.enable = true;
services.xrdp.defaultWindowManager = "xfce4-session";

# add SWAP because of cellpose
swapDevices = [{
  device = "/swapfile";
  size = 16384;  # Size in MB (16GB in this example)
}];

programs.nix-ld = {
  enable = true;
  libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    cudaPackages.cudatoolkit
    # micro-sam
    libGL libglvnd mesa
    # cellpose-sam
    glib fontconfig libx11 libxkbcommon freetype dbus libxcb
    xcb-util-cursor wayland
    zstd
    libxcb libxext libxrender libxi libxrandr
    libxcursor libsm libice
    xcbutil xcbutilimage xcbutilkeysyms xcbutilrenderutil xcbutilwm
    libxtst
  ];
};

home-manager.users.rpcruz = {
  # mouse cursor gets broken after enabling xfce
  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Adwaita";
      };
    };
  };
};
*/

/*
users.users.claw = {
  isNormalUser = true;
  description = "Claw AI Agent";
  hashedPassword = "$6$14rF1qa9BfIownj2$McyMkalipXZNHQOBpfXQ0vPwgeUAe9MeBBedGQ0o0NewQePX68OhmE0ECvh1AVS17wYyZx0O1Gm3afM/VgakP/";
  packages = with pkgs; [
    nodejs cmake
    playwright playwright-driver.browsers
  ];
};
home-manager.users.claw = {
  programs.bash.enable = true;
  home.stateVersion = "25.05";
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
    GOG_KEYRING_PASSWORD = "password";
  };
  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/gog"
  ];
};
*/

/*
home-manager.users.rpcruz.systemd.user.services.fpro = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "${pkgs.bash}/bin/bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
    TimeoutStartSec = 0;  # disable timeout
  };
};
home-manager.users.rpcruz.systemd.user.timers.fpro = {
  Timer = {
    OnUnitActiveSec = "2h";
    Unit = "fpro.service";
  };
  Install.WantedBy = [ "timers.target" ];
};
*/

}
