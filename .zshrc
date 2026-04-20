# Homebrew: FPATH для zsh-completions
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi

# Инициализация автодополнения (один раз, после всех FPATH)
autoload -Uz compinit
compinit

# Плагины
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# PATH
export PATH="$HOME/.local/bin:$PATH"

# История команд
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS

# Git-интеграция в приглашении (vcs_info)
autoload -Uz vcs_info

zstyle ':vcs_info:*'        check-for-changes true
zstyle ':vcs_info:git:*'    formats       '%b%m'
zstyle ':vcs_info:git:*'    actionformats '%b (%a)%m'

zstyle ':vcs_info:git:*+set-message:*' hooks git-status

+vi-git-status() {
    local ahead behind
    local -a gitstatus

    ahead=$(git rev-list @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    behind=$(git rev-list HEAD..@{upstream} 2>/dev/null | wc -l | tr -d ' ')

    [[ $ahead  -gt 0 ]] && gitstatus+=( "+$ahead" )
    [[ $behind -gt 0 ]] && gitstatus+=( "-$behind" )

    if [[ -n $gitstatus ]]; then
        hook_com[misc]=" [${(j:/:)gitstatus}]"
    else
        hook_com[misc]=""
    fi
}

precmd() { vcs_info }

# Приглашение (prompt)
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %F{yellow}${vcs_info_msg_0_}%f $ '
