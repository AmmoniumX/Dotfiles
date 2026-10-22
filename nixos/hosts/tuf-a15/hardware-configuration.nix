# Hand-written from the current Arch install (ASUS TUF A15 FA507NVR).
# Regenerate with `nixos-generate-config --show-hardware-config` on the target
# and copy the UUIDs over: the root and boot UUIDs change if those partitions
# are reformatted. The btrfs subvolumes (@home, @data, @steam) can be reused as-is.
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/43ed2d15-d13c-49c0-a903-1335cd428c26";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C0B4-E795";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e3eed5c5-7bf1-4cd9-99c5-062cfb8c93e3";
    fsType = "btrfs";
    options = [ "subvol=/@home" "compress=zstd" "ssd" "space_cache=v2" ];
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/e3eed5c5-7bf1-4cd9-99c5-062cfb8c93e3";
    fsType = "btrfs";
    options = [ "subvol=/@data" "compress=zstd" "ssd" "space_cache=v2" ];
  };

  fileSystems."/home/ammonium/.local/share/Steam" = {
    device = "/dev/disk/by-uuid/e3eed5c5-7bf1-4cd9-99c5-062cfb8c93e3";
    fsType = "btrfs";
    options = [ "subvol=/@steam" "compress=zstd" "ssd" "space_cache=v2" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
