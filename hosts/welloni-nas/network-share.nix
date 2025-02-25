{
  pkgs,
  config,
  lib,
  ...
}: {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "hosts allow" = "127.0.0.1 192.168.0.0/24";
        "hosts deny" = "0.0.0.0/0";
      };
      storage = {
        path = "/mnt/storage";
        writeable = "true";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
}
