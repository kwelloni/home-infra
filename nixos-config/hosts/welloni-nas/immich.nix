{
  pkgs,
  config,
  lib,
  ...
}: {
  users.extraUsers."immich" = {
    group = "immich";
    extraGroups = [ "users" ];
    isSystemUser = true;
    shell = pkgs.bashInteractive;
    createHome = false;
  };
  services.immich = {
    enable = true;
    port = 2283;
    user = "immich";
    mediaLocation = "/mnt/storage/immich";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."immich.${config.networking.hostName}.home" = {
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
#  services.nginx.virtualHosts."immich.example.com" = {
#    locations."/" = {
#      proxyPass = "http://[::1]:${toString config.services.immich.port}";
#      proxyWebsockets = true;
#      recommendedProxySettings = true;
#      extraConfig = ''
#        client_max_body_size 50000M;
#        proxy_read_timeout   600s;
#        proxy_send_timeout   600s;
#        send_timeout         600s;
#      '';
#    };
#  };
#  services.nginx.virtualHosts."testing" = {
#    locations."/" = {
#      return = "200 '<html><body>It works</body></html>'";
#      extraConfig = ''
#        default_type text/html;
#      '';
#    };
#  };

#  networking.firewall = {
#    allowedTCPPorts = [2283];
#  };
}
