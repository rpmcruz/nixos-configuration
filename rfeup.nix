{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "rfeup";

# disable suspend
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;

home-manager.users.rpcruz.systemd.user.services.update_fp = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "${pkgs.bash}/bin/bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
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
