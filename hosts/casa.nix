{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "rpcruz";
  };
}
