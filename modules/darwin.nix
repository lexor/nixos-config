{ ... }:

{
  system.stateVersion = 5;

  services.nix-daemon.enable = true;

  networking.computerName = "kushina";

  system.defaults = {
    dock = {
      orientation = "left";
      autohide = true;
    };

    NSGlobalDomain = {
      _HIHideMenuBar = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };
}
