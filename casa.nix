{ lib, pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "casa";

environment.systemPackages = lib.mkAfter (with pkgs; [
  steam
]);

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
};
hardware.graphics.enable = true;

}
