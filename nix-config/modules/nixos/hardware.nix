{ pkgs, ... }: {
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  services.fwupd.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.upower.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;

      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 85;
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.printing.enable = true;
  services.gvfs.enable = true;

  # Network printer / Bonjour discovery (used by CUPS).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Fingerprint reader (T480: Validity 138a:0090, supported by libfprint).
  # Fingerprint is offered alongside password — falls back gracefully
  # before any prints are enrolled (run `fprintd-enroll` after first boot).
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.swaylock.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = true;

  # SSD TRIM (NVMe).
  services.fstrim.enable = true;

  # Hardware debugging / power tooling.
  environment.systemPackages = with pkgs; [
    acpi
    powertop
    v4l-utils
    lm_sensors
  ];
}
