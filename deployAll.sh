mkdir ~/.config/oh-my-posh
cp oh-my-posh/.pure.json ~/.config/oh-my-posh/.pure.json
cp ./zshrc/.zshrc ~/.zshrc
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cp -r ./tmux ~/.config/
tmux source ~/.config/tmux/tmux.conf
#open a new tmux pane then control-b then I

cp -r ./nvim ~/.config/
cd vscode
./deploy.sh
