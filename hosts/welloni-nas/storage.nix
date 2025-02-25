{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  disks = [
    {
      type = "data";
      name = "data0";
      uuid = "ff2cea5a-64f1-4c5d-a1d4-61e7bcda3aed";
    }
  ];
  parityDisks = builtins.filter (d: d.type == "parity") disks;
  dataDisks = builtins.filter (d: d.type == "data") disks;
  parityFs = builtins.listToAttrs (builtins.map (d: {
    name = "/mnt/${d.name}";
    value = {
      device = "/dev/disk/by-uuid/${d.uuid}";
      fsType = "xfs";
    };
  })
  parityDisks);
  dataFs = builtins.listToAttrs (builtins.concatMap (d: [
    {
      name = "/mnt/root/${d.name}";
      value = {
        device = "/dev/disk/by-uuid/${d.uuid}";
        fsType = "btrfs";
      };
    }
    {
      name = "/mnt/${d.name}";
      value = {
        device = "/dev/disk/by-uuid/${d.uuid}";
        fsType = "btrfs";
        options = ["subvol=data"];
      };
    }
    {
      name = "/mnt/${d.name}/.snapshots";
      value = {
        device = "/dev/disk/by-uuid/${d.uuid}";
        fsType = "btrfs";
        options = ["subvol=.snapshots"];
      };
    }
  ])
  dataDisks);
  snapperConfigs = builtins.listToAttrs (builtins.map (d: {
    name = "${d.name}";
    value = {
      SUBVOLUME = "/mnt/${d.name}";
      ALLOW_GROUPS = ["wheel"];
      SYNC_ACL = true;
    };
  })
  dataDisks);

in {
  environment.systemPackages = with pkgs; [
    mergerfs
  ];
  
  services.snapper = {
    configs = snapperConfigs;
  };

  fileSystems = {
    "/mnt/root/data0" = {
      device = "/dev/disk/by-uuid/ff2cea5a-64f1-4c5d-a1d4-61e7bcda3aed";
      fsType = "btrfs";
    };
    "/mnt/data0" = {
      device = "/dev/disk/by-uuid/ff2cea5a-64f1-4c5d-a1d4-61e7bcda3aed";
      fsType = "btrfs";
      options = ["subvol=data"];
    };
    "/mnt/data0/.snapshots" = {
      device = "/dev/disk/by-uuid/ff2cea5a-64f1-4c5d-a1d4-61e7bcda3aed";
      fsType = "btrfs";
      options = ["subvol=.snapshots"];
    };
  };

  fileSystems."/mnt/storage" = {
    device = "/mnt/data*";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "nofail"
      "nonempty"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "category.create=mfs"
      "moveonenospc=true"
      "dropcacheonclose=true"
      "minfreespace=20G"
      "fsname=mergerfs"
    ];
  };
}
  
