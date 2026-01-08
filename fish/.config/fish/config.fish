fish_vi_key_bindings

# scratchpad for quick note taking
alias sp='nvim $HOME/notes/scratchpad-(date +"%m-%d-%Y").md'

# tmux main session
alias tam='tat -c ~/ -s main'

function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cj forward-char
    end
end

# override ls with eza, if exists
if command -v exa > /dev/null
  abbr -a l 'exa'
  abbr -a ls 'exa'
  abbr -a ll 'exa -l'
  abbr -a lll 'exa -la'
else
  abbr -a l 'ls'
  abbr -a ll 'ls -l'
  abbr -a lll 'ls -la'
end

# brew (hardcoded for speed - always /opt/homebrew on Apple Silicon)
# to regenerate: /opt/homebrew/bin/brew shellenv
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
fish_add_path --global /opt/homebrew/bin /opt/homebrew/sbin
set -q MANPATH; or set -gx MANPATH ''
set -gx MANPATH :$MANPATH
set -gx INFOPATH /opt/homebrew/share/info:$INFOPATH

# pyenv (lazy loaded)
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path --global $PYENV_ROOT/bin $PYENV_ROOT/shims

function __pyenv_init_if_needed
  if not set -q __pyenv_initialized
    set -g __pyenv_initialized 1
    command pyenv init --no-rehash - fish | source
  end
end

for cmd in python python3 pip pip3
  eval "function $cmd --wraps $cmd; __pyenv_init_if_needed; command $cmd \$argv; end"
end

function pyenv --wraps pyenv
  __pyenv_init_if_needed
  command pyenv $argv
end

# local scripts
set -x PATH $PATH $HOME/bin

# private scripts
set -x PATH $PATH $HOME/.private/bin

# npm
set -x PATH $PATH $HOME/.npm-global/bin

# rust
set -x PATH $PATH $HOME/.cargo/bin

# fzf
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

# turn off greeting
set -U fish_greeting

# shopify dev
if test -f /opt/dev/dev.fish
  source /opt/dev/dev.fish
end

# force true color
set -g fish_term24bit 1

starship init fish | source

# pnpm
set -gx PNPM_HOME "/Users/mattkubej/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


alias pr-description='claude -p (cat ~/prompts/pr-description.md) --allowedTools "Bash(git diff:*)" "Bash(git log:*)"'

# Added by tec agent
test -x /Users/mattkubej/.local/state/tec/profiles/base/current/global/init && /Users/mattkubej/.local/state/tec/profiles/base/current/global/init fish | source


# Set NVM directory
set -gx NVM_DIR "$HOME/.nvm"

function nvm
  bass source '/opt/dev/sh/nvm/nvm.sh' ';' nvm $argv
end

# try function is auto-loaded from ~/.config/fish/functions/try.fish
# to regenerate: ~/.local/try.rb init ~/src/tries > ~/.config/fish/functions/try.fish
export PATH="$HOME/.local/bin:$PATH"
