{ config, pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "casa";

programs.steam.enable = true;

environment.systemPackages = with pkgs; [
  exodus  # torrent wallet
];

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
  package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
};
hardware.graphics.enable = true;

}
