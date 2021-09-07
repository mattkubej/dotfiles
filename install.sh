#!/usr/bin/env zsh

install_ripgrep() {
  if ! command -v rg &> /dev/null; then
    echo "\n  -- installing ripgrep -- \n"

    sudo apt-get install -y ripgrep
  fi
}

install_fzf() {
  if ! command -v fzf &> /dev/null; then
    echo "\n  -- installing fzf -- \n"

    sudo apt-get install -y fzf
  fi
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

install_bat() {
  if ! command -v bat &> /dev/null; then
    echo "\n  -- installing bat -- \n"

    # https://askubuntu.com/a/1300824
    sudo apt-get install -o Dpkg::Options::="--force-overwrite" -y bat

    sudo ln -s $(which batcat) /usr/local/bin/bat
  fi
}

install_fd() {
  if ! command -v fd &> /dev/null; then
    echo "\n  -- installing fd -- \n"

    sudo apt-get install -y fd-find

    sudo ln -s $(which fdfind) /usr/local/bin/fd
  fi
}

install_stow() {
  if ! command -v stow &> /dev/null; then
    echo "\n  -- installing stow -- \n"

    sudo apt-get install -y stow
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

install_dependencies() {
  install_fzf
  install_exa
  install_delta
  install_fd

  # order matters
  install_ripgrep
  install_bat

  install_stow
  install_nvim_nightly
}

stow_dirs() {
  stow -d ~/dotfiles nvim
}

bootstrap_nvim_packer() {
  sudo git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

  nvim --headless \
    -c 'autocmd User PackerComplete quitall' -c 'PackerSync' &> /dev/null
}

install_language_servers() {
  sudo npm install -g typescript typescript-language-server
}

if [ $SPIN ]; then
  install_dependencies
  stow_dirs
  bootstrap_nvim_packer
  install_language_servers
fi
