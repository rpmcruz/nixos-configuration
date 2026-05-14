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
# headless CUDA:
boot.extraModprobeConfig = ''
  options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
'';

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
