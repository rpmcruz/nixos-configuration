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
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [ libGL ];  # electron needs this for libEGL_mesa.so
};

# Remap Lenovo 310 keyboard top-row keys to F1-F12 (fn lock behavior).
# Without this, F1-F12 require holding fn; the top row sends media keys instead.
# F7/F8/F9 send key combos (C-A-tab, M-s, M-l) instead of consumer events, so they
# need keyd (below) to swap them. hwdb handles the rest via scan code remapping.
services.udev.packages = [
  (pkgs.runCommand "lenovo-keyboard-hwdb" {} ''
    mkdir -p $out/etc/udev/hwdb.d
    cat > $out/etc/udev/hwdb.d/99-lenovo-keyboard.hwdb <<'EOF'
    evdev:input:b0003v17EFp6212*
     KEYBOARD_KEY_c00e2=f1
     KEYBOARD_KEY_c00ea=f2
     KEYBOARD_KEY_c00e9=f3
     KEYBOARD_KEY_90011=f4
     KEYBOARD_KEY_c00cd=f5
     KEYBOARD_KEY_c0223=f6
     KEYBOARD_KEY_90027=f10
     KEYBOARD_KEY_c00fd=f11
     KEYBOARD_KEY_c00fe=f12
     KEYBOARD_KEY_7003a=mute
     KEYBOARD_KEY_7003b=volumedown
     KEYBOARD_KEY_7003c=volumeup
     KEYBOARD_KEY_7003e=playpause
     KEYBOARD_KEY_7003f=homepage
    EOF
  '')
];
# keyd swaps F7/F8/F9 ↔ their combos (Ctrl+Alt+Tab, Super+S, Super+L).
# Side effect: pressing Super+S or Super+L manually also maps to F8/F9 on this keyboard.
services.keyd = {
  enable = true;
  keyboards.lenovo310 = {
    ids = [ "17ef:6212" ];
    settings = {
      main = { f7 = "macro(C-A-tab)"; f8 = "macro(M-s)"; f9 = "macro(M-l)"; };
      "control+alt" = { tab = "f7"; };
      meta = { s = "f8"; l = "f9"; };
    };
  };
};

}
