{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "rfeup";

home-manager.users.rpcruz.systemd.user.services.update_fp = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "${pkgs.bash}/bin/bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
    TimeoutStartSec = "60min";
  };
};
home-manager.users.rpcruz.systemd.user.timers.update_fp = {
  Timer = {
    OnCalendar = "hourly";
    Persistent = true;
    Unit = "update_fp.service";
  };
  Install.WantedBy = [ "timers.target" ];
};

}
