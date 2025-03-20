{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /mnt/storage/share 0770 kevin users - -"
  ];
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "guest account" = "kevin";
        "map to guest" = "Bad User";
        "load printers" = "no";
        "printcap name" = "/dev/null";
        "hosts allow" = "127.0.0.1 192.168.0.0/24";
        "hosts deny" = "0.0.0.0/0";
      };
      "share" = {
        "path" = "/mnt/storage/share";
        "guest ok" = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force group" = "users";
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
