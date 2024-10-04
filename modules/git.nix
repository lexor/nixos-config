{ pkgs, ... }:
let
  email = "ben@emre.dev";
  name = "Emre Deger";
  user = "lexor";
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ ".DS_Store" "result" ];
    extraConfig = {
      branch.sort = "-committerdate";
      color.ui = true;
      commit.gpgsign = true;
      core.askPass = "";
      core.commitGraph = true;
      core.pager = "delta";
      credential.helper =
        if pkgs.stdenv.isDarwin
        then "osxkeychain"
        else "cache";
      delta.navigate = true;
      diff.algorithm = "patience";
      diff.colorMoved = "default";
      fetch.prune = true;
      gc.worktreePruneExpire = "now";
      gc.writeCommitGraph = true;
      github.user = user;
      hub.protocol = "https";
      init.defaultBranch = "main";
      interactive.diffFilter = "delta --color-only";
      merge.conflictstyle = "diff3";
      protocol.version = "2";
      pull.rebase = true;
      pull.twohead = "ort";
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
    signing = {
      key = "863EFEB0E78AE490";
      signByDefault = true;
    };
    userEmail = email;
    userName = name;
    aliases = {
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
  };
}
