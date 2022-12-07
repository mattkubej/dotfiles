#!/usr/bin/env zsh

autoload -U colors
colors

link_files() {
  sudo ln -s $(which batcat) /usr/local/bin/bat
  sudo ln -s $(which fdfind) /usr/local/bin/fd
}

install_exa() {
  if ! command -v exa &> /dev/null; then
    echo "\n  -- installing exa -- \n"

    exa_zip_src="https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip"
    exa_zip_dest="/tmp/$(basename $exa_zip_src)"
    exa_dir=/tmp/exa

    curl -L $exa_zip_src -o $exa_zip_dest

    unzip $exa_zip_dest -d $exa_dir

    sudo ln -s "$exa_dir/bin/exa" /usr/local/bin/exa
  fi
}

install_delta() {
  if ! command -v delta &> /dev/null; then
    echo "\n  -- installing delta -- \n"

    delta_pkg_src="https://github.com/dandavison/delta/releases/download/0.8.3/git-delta_0.8.3_amd64.deb"
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

  # curl -L https://github.com/neovim/neovim/releases/download/v0.5.1/nvim.appimage \
  #   -o /tmp/nvim.appimage

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
  install_exa
  install_delta
  install_prettier
  install_eslint_d

  # install_nvim_nightly
  # install_language_servers
}

stow_dirs() {
  stow -d ~/dotfiles nvim
  stow -d ~/dotfiles git
}

bootstrap_nvim_packer() {
  echo "\n -- cloning packer -- \n"
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim &> /dev/null

  #echo "\n -- installing packer plugins -- \n"
  #nvim --headless \
  # -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null

  #echo "\n -- updating treesitter -- \n"
  #nvim --headless "+TSInstallSync all" +q &> /dev/null
}

if [ $SPIN ]; then
  install_dependencies
  stow_dirs
  # bootstrap_nvim_packer
fi
