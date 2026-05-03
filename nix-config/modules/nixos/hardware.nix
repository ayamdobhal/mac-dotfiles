{ ... }: {
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
}
