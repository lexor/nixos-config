{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-mono
    (
      nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      }
    )
  ];
}
