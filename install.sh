#!/usr/bin/env zsh

autoload -U colors
colors

install_delta() {
  if ! command -v delta &> /dev/null; then
    echo "\n  -- installing delta -- \n"

    delta_pkg_src="https://github.com/dandavison/delta/releases/download/0.15.1/git-delta_0.15.1_amd64.deb"
    delta_pkg_dest="/tmp/$(basename $delta_pkg_src)"

    curl -L $delta_pkg_src -o $delta_pkg_dest

    sudo dpkg -i $delta_pkg_dest
  fi
}

install_prettier() {
  if ! command -v prettier &> /dev/null; then
    echo "\n  -- installing prettier -- \n"

    sudo npm i -g prettier
  fi
}

install_eslint_d() {
  if ! command -v eslint_d &> /dev/null; then
    echo "\n  -- installing eslint_d -- \n"

    sudo npm i -g eslint_d
  fi
}

install_nvim_nightly() {
  echo "\n  -- installing nvim nightly -- \n"

  curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage \
    -o /tmp/nvim.appimage

  chmod u+x /tmp/nvim.appimage

  /tmp/nvim.appimage --appimage-extract

  [ -d /squashfs-root ] || sudo mv squashfs-root /

  sudo rm -f /usr/local/bin/nvim
  sudo ln -s /squashfs-root/usr/bin/nvim /usr/local/bin/nvim
}

install_treesitter() {
  if [[ ! -f /usr/local/bin/tree-sitter ]]; then
    mkdir -p $HOME/dotfiles/tmp
    cd $HOME/dotfiles/tmp

    # Install Tree-Sitter
    TS_VERSION="v0.20.6"
    wget "https://github.com/tree-sitter/tree-sitter/releases/download/${TS_VERSION}/tree-sitter-linux-x64.gz"
    gunzip tree-sitter-linux-x64.gz
    chmod u+x tree-sitter-linux-x64
    sudo mv tree-sitter-linux-x64 /usr/local/bin/tree-sitter
  fi
}

install_dependencies() {
  install_delta
  # install_prettier
  # install_eslint_d

  # install_nvim_nightly
  # install_treesitter
}

link_files() {
  sudo ln -s $(which batcat) /usr/local/bin/bat
  sudo ln -s $(which fdfind) /usr/local/bin/fd
}

setup_copilot() {
  echo "\n -- installing copilot -- \n"

  if [ -f /etc/spin/secrets/copilot_hosts.json ]; then
    mkdir -p "${HOME}/.config/github-copilot"
    cp /etc/spin/secrets/copilot_hosts.json "${HOME}/.config/github-copilot/hosts.json"
  fi
}

stow_dirs() {
  stow -d ~/dotfiles nvim
  stow -d ~/dotfiles git
  stow -d ~/dotfiles tmux
  stow -d ~/dotfiles scripts
}

setup_zsh() {
  # there is probably a cleaner way to do this
  echo "source ~/dotfiles/spin/aliases" >> ~/.zshrc
}

setup_tmux() {
  echo "\n -- setup tmux -- \n"

  # spin hostname
  export FQDN=$(cat /etc/spin/machine/fqdn | sed "s/\\..*//")

  # install tmux plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh
}

if [ $SPIN ]; then
  install_dependencies
  link_files
  stow_dirs
  setup_zsh
  setup_tmux
  setup_copilot

  timeout 2m nvim --headless "+Lazy! sync" +qa || true
fi
