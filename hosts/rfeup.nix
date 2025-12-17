{ pkgs, ... }:

{

# disable suspend
services.logind.settings.Login = {
  IdleAction = "ignore";
  IdleActionSec = 0;
  HandleLidSwitch = "ignore";
  HandleLidSwitchDocked = "ignore";
  HandleLidSwitchExternalPower = "ignore";
};

home-manager.users.rpcruz.systemd.user.services.update_fp = {
  Service = {
    Type = "oneshot";
    WorkingDirectory = "/home/rpcruz/projs/FP-Admin/moodle-api";
    ExecStart = "/usr/bin/env bash -lc 'source venv/bin/activate && ./leaderboard_update.sh'";
  };
};
home-manager.users.rpcruz.systemd.user.timers.update_fp = {
  Timer = {
    OnCalendar = "hourly";
    Persistent = true;
    Unit = "update_fp.service";
  };
  Install = {
    WantedBy = [ "timers.target" ];
  };
};

}
