#darwin-rebuild switch --flake ~/.config/nix-darwin
#darwin-rebuild switch --flake ./nix-darwin
#nix-collect-garbage -d
{
  description = "Mister Joessef nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          nixpkgs.config.allowUnfree = true;
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.awscli2
            pkgs.ffmpeg_7
            pkgs.iterm2
            pkgs.git-lfs
            pkgs.mkalias
            pkgs.neovim
            pkgs.nodejs_20
            #pkgs.oh-my-zsh
            pkgs.oh-my-posh
            pkgs.ollama
            pkgs.onnxruntime
            #pkgs.open-webui
            #pkgs.pyenv
            pkgs.python313
            pkgs.ripgrep
            pkgs.stats
            pkgs.tmux
            pkgs.yt-dlp
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
              "stripe-cli/stripe"
            ];
            casks = [
              "adobe-acrobat-pro"
              "blender"
              "bridge" # used for epic games asset 
              "rectangle"
              "visual-studio-code"
              "docker"
              "google-chrome"
              "discord"
              "epic-games"
              "raycast"
              "github"
              "ollama"
              "miniconda" # used for comfy ui
              "nvidia-geforce-now" # used for cloud gaming
              "obs"
              "spotify"
              "steam"
              "unity-hub"
              "zoom"

            ];
            masApps = {
              "Capcut" = 1500855883;
              "Messenger" = 1480068668;
              "Slack" = 803453959;
              "Xcode" = 497799835;
              "Trello" = 1278508951;
              "Telegram" = 747648890;
            };
          };

          fonts.packages = [
            (pkgs.nerdfonts.override {
              fonts = [
                "JetBrainsMono"
                "Hack"
              ];
            })
          ];

          # adds symlink for all application installed through nix to be index in spotlight
          system.activationScripts.postUserActivation.text = ''
            apps_source="${config.system.build.applications}/Applications"
            moniker="Nix Trampolines"
            app_target_base="$HOME/Applications"
            app_target="$app_target_base/$moniker"
            mkdir -p "$app_target"
            ${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
          '';

          #configuring system defaults
          #https://mynixos.com/nix-darwin/options/system
          system.defaults = {
            dock = {
              autohide = true;
              orientation = "left";
              magnification = true;
              largesize = 32;
              minimize-to-application = false;
              mru-spaces = false;
              show-process-indicators = true;
              show-recents = false;
              static-only = true;
              tilesize = 16;
            };

            finder = {
              _FXShowPosixPathInTitle = false;
              AppleShowAllExtensions = true;
              FXDefaultSearchScope = "SCcf";
              ShowStatusBar = true;
              ShowPathbar = true;
              NewWindowTarget = "Home";
            };
            #todo add new finder window opens in home when implemented

            loginwindow.GuestEnabled = false;

            menuExtraClock = {
              ShowDate = 1;
              ShowSeconds = true;
              ShowDayOfMonth = true;
              ShowDayOfWeek = true;
            };

            screensaver.askForPassword = true;
            screensaver.askForPasswordDelay = 10;

            NSGlobalDomain = {
              _HIHideMenuBar = true;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          #      programs.oh-my-posh.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Misters-Mac-mini
      darwinConfigurations."Misters-Mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "misterjoessef";
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Misters-Mac-mini".pkgs;
    };
}
