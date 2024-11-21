#for new machines
darwin-rebuild switch --flake ./nix-darwin
stow .
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.config/tmux/tmux.conf
#open a new tmux pane then control-b then Shift + I

cd vscode
./deploy.sh
