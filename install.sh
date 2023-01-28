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
  [ -f /usr/local/bin/nvim ] || sudo ln -s /squashfs-root/usr/bin/nvim /usr/local/bin/nvim
}

install_language_servers() {
  echo "\n -- installing language servers -- \n"
  sudo yarn global add typescript typescript-language-server --prefix /usr/local
  sudo yarn global add vscode-langservers-extracted --prefix /usr/local
  sudo yarn global add graphql-language-service-cli --prefix /usr/local
}

install_dependencies() {
  install_delta
  install_prettier
  install_eslint_d

  install_nvim_nightly
  # install_language_servers
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
  stow -d ~/dotfiles shell
}

bootstrap_nvim_packer() {
  echo "\n -- cloning packer -- \n"
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim &> /dev/null

  echo "\n -- installing packer plugins -- \n"
  nvim --headless \
   -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null

  #echo "\n -- updating treesitter -- \n"
  #nvim --headless "+TSInstallSync all" -c q &> /dev/null
}

if [ $SPIN ]; then
  install_dependencies
  link_files
  stow_dirs
  setup_copilot
  #bootstrap_nvim_packer
fi
