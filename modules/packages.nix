{ pkgs, ... }:
let
  core = with pkgs;
    [
      eza
      fd
      jq
      pastel
      ripgrep
      sd
      sops
    ]
    ++ (import ./lsp.nix { pkgs = pkgs; });

  darwin = with pkgs; [
    act
    age
    alejandra
    awscli2
    bore-cli
    cachix
    coreutils
    delta
    erlang
    fish
    fzf
    git
    git-lfs
    gleam
    go
    graph-easy
    graphviz
    htop
    kbt
    librsvg
    libwebp
    lsd
    nodejs
    gum
    lazygit
    openssl
    postgresql
    python312Packages.grip
    python312Packages.west
    redis
    rustup
    tree-sitter
    unixtools.script
    watch
    watchexec
    yq
    zig
  ];

  linux = with pkgs; [ ];
in
{
  home.packages =
    core
    ++ (
      if pkgs.stdenv.isDarwin
      then darwin
      else linux
    );

  programs.bat.config.theme = "Nord";
  programs.bat.enable = true;
  programs.home-manager.enable = true;
  programs.taskwarrior.colorTheme = "dark-16";
  programs.taskwarrior.enable = true;
}
