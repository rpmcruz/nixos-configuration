{ pkgs, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "rfeup";

# disable suspend
systemd.targets.sleep.enable = false;
systemd.targets.suspend.enable = false;
systemd.targets.hibernate.enable = false;
systemd.targets.hybrid-sleep.enable = false;
systemd.sleep.extraConfig = ''
  AllowSuspend=no
  AllowHibernation=no
  AllowHybridSleep=no
  AllowSuspendThenHibernate=no
'';

home-manager.users.rpcruz.systemd.user.services.update_fp = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "${pkgs.bash}/bin/bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
    TimeoutStartSec = 0;  # not sure if this is really needed
    KillMode = "process";
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
