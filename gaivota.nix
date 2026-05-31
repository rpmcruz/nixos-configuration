{ config, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "gaivota";

programs.steam.enable = true;

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
  package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
};
hardware.graphics.enable = true;

}
