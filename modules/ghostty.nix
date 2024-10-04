{config, ...}: let
  colors = import ./colors.nix;
  ghosttyPath = "${config.xdg.configHome}/ghostty";
in {
  home.file."${ghosttyPath}/config".text = ''
    theme = Tomorrow Night Eighties
  '';
}
