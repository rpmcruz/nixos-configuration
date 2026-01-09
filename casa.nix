{ lib, pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "casa";

programs.steam.enable = true;

# install my exodus package modification
nixpkgs.overlays = [
  (final: prev: {
    exodus = prev.callPackage ./exodus.nix {};
  })
];
environment.systemPackages = with pkgs; [
  exodus
];

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
};
hardware.graphics.enable = true;

}
