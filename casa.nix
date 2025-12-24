{ lib, pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "casa";

programs.steam.enable = true;

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
};
hardware.graphics.enable = true;

}
