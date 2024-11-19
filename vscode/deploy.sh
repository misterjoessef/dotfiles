cp ./settings.json ~/Library/Application\ Support/Code/User/

cat extensionList.txt | xargs -L1 code --install-extension