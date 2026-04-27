{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      lgt = "lazygit";
      python = "python3";
      claude = "claude --dangerously-skip-permissions";
      laude = "claude --dangerously-skip-permissions";

      # git aliases (oh-my-zsh git plugin)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gau = "git add --update";
      gav = "git add --verbose";

      gbl = "git blame -w";
      gb = "git branch";
      gba = "git branch --all";
      gbd = "git branch --delete";
      gbD = "git branch --delete --force";
      gbm = "git branch --move";
      gbnm = "git branch --no-merged";
      gbr = "git branch --remote";

      gbs = "git bisect";
      gbsb = "git bisect bad";
      gbsg = "git bisect good";
      gbsr = "git bisect reset";
      gbss = "git bisect start";

      gco = "git checkout";
      gcb = "git checkout -b";
      gcB = "git checkout -B";

      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";

      gcl = "git clone --recurse-submodules";

      gc = "git commit --verbose";
      gca = "git commit --verbose --all";
      gcam = "git commit --all --message";
      gcmsg = "git commit --message";
      gcsm = "git commit --signoff --message";

      gcf = "git config --list";

      gd = "git diff";
      gdca = "git diff --cached";
      gdcw = "git diff --cached --word-diff";
      gds = "git diff --staged";
      gdw = "git diff --word-diff";

      gf = "git fetch";
      gfo = "git fetch origin";

      ghh = "git help";

      glog = "git log --oneline --decorate --graph";
      gloga = "git log --oneline --decorate --graph --all";
      glo = "git log --oneline --decorate";
      glgg = "git log --graph";
      glgga = "git log --graph --decorate --all";
      glol = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'';
      glola = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'';
      glols = ''git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'';
      glg = "git log --stat";
      glgp = "git log --stat --patch";

      gm = "git merge";
      gma = "git merge --abort";
      gmc = "git merge --continue";
      gms = "git merge --squash";
      gmff = "git merge --ff-only";

      gl = "git pull";
      gpr = "git pull --rebase";
      gprv = "git pull --rebase -v";
      gpra = "git pull --rebase --autostash";
      gprav = "git pull --rebase --autostash -v";

      gp = "git push";
      gpd = "git push --dry-run";
      gpv = "git push --verbose";

      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase --interactive";
      grbo = "git rebase --onto";
      grbs = "git rebase --skip";

      grf = "git reflog";

      gr = "git remote";
      grv = "git remote --verbose";
      gra = "git remote add";
      grrm = "git remote remove";
      grmv = "git remote rename";
      grset = "git remote set-url";
      grup = "git remote update";

      grh = "git reset";
      gru = "git reset --";
      grhh = "git reset --hard";
      grhk = "git reset --keep";
      grhs = "git reset --soft";

      grs = "git restore";
      grss = "git restore --source";
      grst = "git restore --staged";

      grev = "git revert";
      greva = "git revert --abort";
      grevc = "git revert --continue";

      grm = "git rm";
      grmc = "git rm --cached";

      gcount = "git shortlog --summary --numbered";
      gsh = "git show";
      gsps = "git show --pretty=short --show-signature";

      gsta = "git stash";
      gstall = "git stash --all";
      gstaa = "git stash apply";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
      gsts = "git stash show --patch";

      gst = "git status";
      gss = "git status --short";
      gsb = "git status --short --branch";

      gsi = "git submodule init";
      gsu = "git submodule update";

      gsw = "git switch";
      gswc = "git switch --create";

      gta = "git tag --annotate";
      gts = "git tag --sign";
      gtv = "git tag | sort -V";

      gwt = "git worktree";
      gwta = "git worktree add";
      gwtls = "git worktree list";
      gwtmv = "git worktree move";
      gwtrm = "git worktree remove";

      gignore = "git update-index --assume-unchanged";
      gunignore = "git update-index --no-assume-unchanged";
    };

    initContent = ''
      # claude-code native install
      path=("$HOME/.local/bin" $path)

      # nix-darwin rebuild — uses LocalHostName as the flake key, override with arg.
      # `nrs` -> auto, `nrs <hostname>` -> explicit.
      nrs() {
        local host="''${1:-$(scutil --get LocalHostName 2>/dev/null)}"
        sudo darwin-rebuild switch --flake "$HOME/.config/nix-config#$host"
      }

      # oh-my-zsh git helper functions (used by dynamic aliases below)
      function git_current_branch() {
        local ref
        ref=$(git symbolic-ref --quiet HEAD 2>/dev/null)
        local ret=$?
        if [[ $ret != 0 ]]; then
          [[ $ret == 128 ]] && return
          ref=$(git rev-parse --short HEAD 2>/dev/null) || return
        fi
        echo "''${ref#refs/heads/}"
      }

      function git_main_branch() {
        command git rev-parse --git-dir &>/dev/null || return
        local ref
        for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,master}; do
          if command git show-ref -q --verify "$ref"; then
            echo "''${ref:t}"
            return 0
          fi
        done
        echo master
        return 1
      }

      function git_develop_branch() {
        command git rev-parse --git-dir &>/dev/null || return
        local branch
        for branch in dev devel develop development; do
          if command git show-ref -q --verify "refs/heads/$branch"; then
            echo "$branch"
            return 0
          fi
        done
        echo develop
        return 1
      }

      # dynamic git aliases (depend on helper functions above)
      alias gcm='git checkout $(git_main_branch)'
      alias gcd='git checkout $(git_develop_branch)'
      alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
      alias gmom='git merge origin/$(git_main_branch)'
      alias gmum='git merge upstream/$(git_main_branch)'
      alias gprom='git pull --rebase origin $(git_main_branch)'
      alias gprum='git pull --rebase upstream $(git_main_branch)'
      alias ggpull='git pull origin "$(git_current_branch)"'
      alias gluc='git pull upstream $(git_current_branch)'
      alias glum='git pull upstream $(git_main_branch)'
      alias gpsup='git push --set-upstream origin $(git_current_branch)'
      alias gpod='git push origin --delete'
      alias ggpush='git push origin "$(git_current_branch)"'
      alias gpu='git push upstream'
      alias grbd='git rebase $(git_develop_branch)'
      alias grbm='git rebase $(git_main_branch)'
      alias grbom='git rebase origin/$(git_main_branch)'
      alias grbum='git rebase upstream/$(git_main_branch)'
      alias groh='git reset origin/$(git_current_branch) --hard'
      alias gswm='git switch $(git_main_branch)'
      alias gswd='git switch $(git_develop_branch)'
      alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'

      # Discord IPC
      ln -sf "$TMPDIR/discord-ipc-0" /tmp/discord-ipc-0 2>/dev/null

      # Work navigation helper
      z() { cd "$HOME/work/iv-pro/iv-pro-$1"; }
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        $os$directory$git_branch$git_status$fill$cmd_duration$direnv$nix_shell
        $character
      '';
      right_format = "$time";

      os = {
        disabled = false;
        style = "bold white";
      };
      os.symbols = {
        Macos = " ";
      };

      directory = {
        style = "bold cyan";
        truncate_to_repo = true;
        truncation_symbol = "…/";
      };

      git_branch = {
        style = "bold green";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
      };

      fill.symbol = " ";

      cmd_duration = {
        style = "bold yellow";
        min_time = 2000;
        format = "[$duration]($style) ";
      };

      direnv = {
        disabled = false;
        style = "bold blue";
      };

      nix_shell = {
        disabled = false;
        style = "bold purple";
        format = "[$symbol$state]($style) ";
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "bold dimmed white";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
