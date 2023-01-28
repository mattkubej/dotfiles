fish_vi_key_bindings

# scratchpad for quick note taking
alias sp='nvim $HOME/notes/scratchpad-(date +"%m-%d-%Y").md'

# tmux main session
alias tam='tat -c ~/ -s main'

function fish_user_key_bindings
    for mode in insert default visual
        bind -M $mode \cn forward-char
    end
end

# override ls with exa, if exists
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

# pyenv
set -Ux PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
pyenv init - | source

# local scripts
set -x PATH $PATH $HOME/bin

# npm
set -x PATH $PATH $HOME/.npm-global/bin

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
