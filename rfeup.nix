{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "rfeup";

home-manager.users.rpcruz.systemd.user.services.update_fp = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "${pkgs.bash}/bin/bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
    TimeoutStartSec = 0;  # disable timeout
  };
};
home-manager.users.rpcruz.systemd.user.timers.fpro = {
  Timer = {
    OnCalendar = "*:00/2:00";  # every 2 hours
    Unit = "fpro.service";
  };
  Install.WantedBy = [ "timers.target" ];
};

}
