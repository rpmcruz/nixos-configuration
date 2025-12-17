{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "gaivota";

environment.systemPackages = with pkgs; [
  steam
];

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
};
hardware.graphics.enable = true;

}
