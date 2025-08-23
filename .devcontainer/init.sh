#!/bin/bash
# Initialise a newly created dev container with some conveniences - this is strictly optional.
# It is semi-safe to run multiple times, but don't bet on it.
set -eu -o pipefail

CONFIG_DIR=$(dirname "$(readlink -f "$0")")/config

echo ====
echo Installing fzf ...
rm -fr ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo =====
echo Installing zoxide ...
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
ZOXIDERC="eval \"\$(zoxide init bash)\""
if [[ $(grep -c "^$ZOXIDERC" ~/.bashrc) -eq 0 ]]; then
  echo "$ZOXIDERC" >>~/.bashrc
fi

echo =====
echo Installing complete_alias ...
mkdir -p ~/.bash_completion.d
curl -sS https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias -o ~/.bash_completion.d/complete_alias

echo Updating .bashrc ...
MYBASHRC=$(head -1 "${CONFIG_DIR}/.bashrc")
if [[ $(grep -c "^$MYBASHRC" ~/.bashrc) -eq 0 ]]; then
  echo '' >>~/.bashrc
  cat "${CONFIG_DIR}/.bashrc" >>~/.bashrc
fi

echo Updating .gitconfig ...
MYGITCONFIG=$(head -1 "${CONFIG_DIR}/.gitconfig")
if [[ $(grep -c "^$MYGITCONFIG" ~/.gitconfig) -eq 0 ]]; then
  cat "${CONFIG_DIR}/.gitconfig" >>~/.gitconfig
fi

echo Creating symlinks ...
sudo ln -sf "${CONFIG_DIR}/.bash_aliases" ~/.bash_aliases
mkdir -p ~/.aws
sudo ln -sf "${CONFIG_DIR}/.aws/config" ~/.aws/config
