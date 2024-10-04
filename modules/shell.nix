{ config
, pkgs
, ...
}:
let
  join = builtins.concatStringsSep " && ";
  pathJoin = builtins.concatStringsSep ":";

  environment = rec {
    AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
    BASH_SILENCE_DEPRECATION_WARNING = "1";
    BREW_SBIN = "/usr/local/sbin";
    BROWSER = "open";
    CARGO_BIN = "${CARGO_HOME}/bin";
    CARGO_HOME = "${config.xdg.configHome}/.cargo";
    COLORTERM = "truecolor";
    EDITOR = "nvim";
    GOBIN = "${GOPATH}/bin";
    GOPATH = "${config.xdg.configHome}/go";
    HANDLER = "copilot";
    HOMEBREW_BIN = "${HOMEBREW_PREFIX}/bin";
    HOMEBREW_CELLAR = "${HOMEBREW_PREFIX}/Cellar";
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_REPOSITORY = HOMEBREW_PREFIX;
    HOMEBREW_SBIN = "${HOMEBREW_PREFIX}/sbin";
    KEYTIMEOUT = "1";
    KUBECONFIG = pathJoin [ "$HOME/.kube/config" ];
    NIXOS_OZONE_WL = "1";
    NIX_BIN = "$HOME/.nix-profile/bin";
    NIX_PATH = pathJoin [ "$NIX_PATH" "$HOME/.nix-defexpr/channels" ];
    OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";
    RUSTUP_HOME = "${config.xdg.configHome}/.rustup";
    SHELL = "zsh";
    SOLARGRAPH_CACHE = "${config.xdg.cacheHome}/solargraph";
    SRC = "$HOME/src";
    WLR_NO_HARDWARE_CURSORS = "1";
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_DATA_HOME = config.xdg.dataHome;

    PATH = pathJoin [
      CARGO_BIN
      GOBIN
      NIX_BIN
      BREW_SBIN
      HOMEBREW_BIN
      HOMEBREW_SBIN
      "$PATH"
    ];
  };

  aliases = rec {
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    v = "$EDITOR";
    vi = "$EDITOR";
    vim = "$EDITOR";
    nvim = "$EDITOR";

    tms = "tmux switch -t";
    tma = "tmux attach -t";
    tmn = "tmux new";

    tkss = "tmux kill-session -t";
    tksv = "tmux kill-server";
    tls = "tmux list-sessions";

    df = "${tmn} -ds dotfiles -c ~/nixos-config $SHELL; ${tms} dotfiles || ${tma} dotfiles";

    dstroy = "fd -IH .DS_Store | xargs sudo rm";

    g = "git";
    ga = "git add";
    gaa = "git add -A";
    gc = "git commit -S -v -s";
    gs = "git status -s -b";
    gd = "git diff";
    gfp = "git fetch --prune";
    gco = "git checkout";
    gcb = "git checkout -b";
    gcp = "git cherry-pick";
    gl = "git prettylog";
    gp = "git push";
    gpr = "git pull --rebase";
    gt = "git tag";
    cdr = "cd $(git rev-parse --show-toplevel)";
    nah = "git reset --hard;git clean -df;";
    dev = "git checkout develop && git pull --rebase";

    jf = "jj git fetch";
    jn = "jj new";
    js = "jj st";

    ls = "eza";
    lg = "lazygit";
    cat = "bat";
    k = "kubectl";
    rg = "rg -uui";

    goi = "go install";
    grr = "go run ./...";
    gtt = "go test ./...";
    gmt = "go mod tidy";
    gmu = "go get -u $(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all | gum filter --height 10)";
    gme = "go mod edit -replace $(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all | gum filter --height 10)=$(realpath --relative-to=\"$\{PWD\}\" \"$(gum file --directory ..)\")";

    golint = "golangci-lint run ./...";
    golintsoft = "golangci-lint run ./... --config .golangci-soft.yml";

    cl = "clear";

    lsa = "eza -laF";
    sl = "${ls}";
    tree = "${ls} -T";

    sz = join [
      "unset __HM_ZSH_SESS_VARS_SOURCED"
      "unset __HM_SESS_VARS_SOURCED"
      "source ${config.xdg.configHome}/zsh/.zshrc"
      "source ${config.xdg.configHome}/zsh/.zshenv"
    ];

    ncg = "nix-collect-garbage";
    ns = "open https://search.nixos.org/packages\\?channel=unstable";

    scim = "sc-im";

    dw = ''gum choose "热爱开源" "你好" | pbcopy'';

    scratch = "FILE=`mktemp /tmp/scratch.XXXXXX`; $EDITOR $FILE +startinsert && pbcopy < $FILE; rm $FILE";
  };
in
{
  programs.bash = {
    enable = true;
    historySize = 1000;
    bashrcExtra = ''
      export PS1="\[\e[38;2;90;86;224m\]> \[\e[0m\]";
      export PROMPT="\[\e[38;2;90;86;224m\]> \[\e[0m\]";
    '';
    shellAliases = aliases;
    shellOptions = [ ];
    enableCompletion = false;
    sessionVariables = environment;
  };

  programs.fish = {
    enable = true;
    shellAliases = aliases;
  };

  programs.zsh = {
    autocd = true;
    dotDir = ".config/zsh";
    enable = true;
    history = {
      ignoreDups = true;
      ignoreSpace = true;
      path = "$ZDOTDIR/.history";
      share = true;
    };
    shellAliases = aliases;
    defaultKeymap = "viins";
    initExtraBeforeCompInit = ''
      fpath+="$HOME/.nix-profile/share/zsh/site-functions"
      fpath+="$HOME/.nix-profile/share/zsh/5.8/functions"

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      function trash () {
        mv "$@" ~/.Trash/$RANDOM-$@
      }

      function tss() {
        (
          exec </dev/tty
          exec <&1
          SESSION=`ls $SRC | gum choose`
          DIRECTORY="$SRC/$SESSION"
          if [[ -z "$SESSION" ]]
          then
            SESSION="dotfiles"
            DIRECTORY="$HOME/_"
          fi
          tmux new -ds "$SESSION" -c "$DIRECTORY" "$SHELL" 2> /dev/null
          if [[ -n "$TMUX" ]]
          then
            tmux switch -t "$SESSION" 2> /dev/null
          else
            tmux attach -t "$SESSION" 2> /dev/null
          fi
        )
        zle reset-prompt
      }
      zle -N tss
      bindkey "^a" tss

      function hs() {
        BUFFER="$(fc -ln 0 | gum filter --value "$BUFFER")"
        zle -w end-of-line
      }
      zle -N hs
      bindkey "^r" hs

      function fs() {
        BUFFER+="$(fd | gum filter)"
        zle -w end-of-line
      }
      zle -N fs
      bindkey "^f" fs
    '';
    initExtra = ''
      setopt prompt_subst
      setopt histignorealldups

      bindkey '^P' up-history
      bindkey '^N' down-history
      bindkey '^?' backward-delete-char
      bindkey '^[[Z' reverse-menu-complete

      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      precmd() {
        if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
          GIT_BRANCH="($(git branch --show-current))"
          GIT_STATUS=$(git status --porcelain | cut -c2 | tr -d ' \n')
        else
          unset GIT_BRANCH
          unset GIT_STATUS
        fi
      }

      export GPG_TTY=$(tty)

      if [ "$DEMO" = "true" ]; then
        export PROMPT="%F{#5a56e0}>%f "
      else
        export PROMPT="%F{blue}%3~%f %F{magenta}\$GIT_BRANCH%f %F{red}\$GIT_STATUS%f
      %(?.%F{green}>%f.%F{red}>%f) "
      fi

      # secrets
      # [ -z "$COPILOT_API_KEY" ] && export COPILOT_API_KEY="$(pass COPILOT_API_KEY)"
      # [ -z "$OPENAI_API_KEY" ] && export OPENAI_API_KEY="$(pass OPENAI_API_KEY)"
    '';
    sessionVariables = environment;
    plugins = [
      {
        name = "rupa/z";
        src = pkgs.fetchFromGitHub {
          owner = "rupa";
          repo = "z";
          rev = "9f76454b32c0007f20b0eae46d55d7a1488c9df9";
          sha256 = "0qywf8pdrlp43b6c1pgyl51501dhx4f672dk1b0lvdlkj37d4pgz";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "5eb494852ebb99cf5c2c2bffee6b74e6f1bf38d0";
          sha256 = "8gyZe6OPVLMdfruHJAHcyYeuiyvMTLvuX1UnUOv8eg8=";
        };
      }
    ];
  };
}
