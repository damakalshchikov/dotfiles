# Утилита: добавить путь только если директория существует
path_prepend() {
    [[ -d "$1" ]] && export PATH="$1:$PATH"
}

# OS-specific конфигурация
case "$(uname -s)" in
    Darwin)
        # Homebrew: FPATH для zsh-completions
        if type brew &>/dev/null; then
            FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
        fi

        # Плагины (Homebrew)
        source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # Пути
        path_prepend "/opt/homebrew/bin"
        path_prepend "/Library/TeX/texbin"
        path_prepend "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        ;;
    Linux)
        # Плагины (пакетный менеджер дистрибутива)
        [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
            source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
            source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # Пути
        path_prepend "/usr/local/texlive/2024/bin/x86_64-linux"
        ;;
esac

# Инициализация автодополнения (с кэшированием - быстрее запуск)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Универсальные пути
path_prepend "$HOME/.local/bin"

# Go
export GOPATH=$HOME/go
path_prepend "$GOPATH/bin"

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

# Команда для создания заготовки отчёта
new-report() {
    local template="$HOME/Documents/LaTeX/latex-report-template"
    local dest="$HOME/Documents/LaTeX/${1:?Укажи имя: new-report <название>}"

    cp -r "$template" "$dest"
    rm -rf "$dest/.git" "$dest/build"
    rm -f  "$dest/README.md" "$dest/README.ru.md" "$dest/LICENSE" "$dest/.DS_Store" "$dest/main.pdf"
}
