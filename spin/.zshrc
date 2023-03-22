source /etc/zsh/zshrc.default.inc.zsh

alias flogs=systemctl list-units --type=service | grep server.service | grep proc-shopify | awk '{print $1}' | fzf --height 10% | xargs journalctl -fu
