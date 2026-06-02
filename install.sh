#!/bin/bash

# Переменные:
# DOTFILES - путь к директории с dotfiles
# BREWFILE - путь к Brewfile
# OS       - определяем операционную систему (Darwin = macOS, Linux = Linux)
DOTFILES="$HOME/dotfiles"
BREWFILE="$DOTFILES/Brewfile"
OS="$(uname)"



# Цвета для вывода в терминал:
# GREEN  - зелёный
# YELLOW - жёлтый
# RED    - красный
# NC     - сброс цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'



# Вспомогательные функции:
# info    - вывод информационного сообщения (зелёный)
# warning - вывод предупреждения (жёлтый)
# error   - вывод ошибки (красный)
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; }



# check_brew: проверка наличия Homebrew
check_brew() {
    # Проверяем, доступна ли команда brew в системе
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed. Install it:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
}



# check_brewfile: проверка пакетов из Brewfile
check_brewfile() {
    # Убеждаемся, что brew установлен перед проверкой
    check_brew

    # Убеждаемся, что Brewfile существует
    if [ ! -f "$BREWFILE" ]; then
        error "Brewfile not found: $BREWFILE"
        exit 1
    fi

    echo ""
    echo "Checking packages from Brewfile..."
    echo ""

    # Читаем Brewfile построчно
    while IFS= read -r line; do
        # Пропускаем комментарии и пустые строки
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # Проверяем CLI-утилиты (brew "name")
        if [[ "$line" =~ ^brew\ \"(.+)\" ]]; then
            local name="${BASH_REMATCH[1]%%,*}"
            if brew list --formula "$name" &>/dev/null; then
                info "brew: $name"
            else
                warning "brew: $name (not installed)"
            fi

        # Проверяем cask-приложения (cask "name")
        elif [[ "$line" =~ ^cask\ \"(.+)\" ]]; then
            local name="${BASH_REMATCH[1]}"
            if brew list --cask "$name" &>/dev/null; then
                info "cask: $name"
            else
                warning "cask: $name (not installed)"
            fi
        fi
    done < "$BREWFILE"

    echo ""
}



# create_symlink: создание симлинка
create_symlink() {
    local src="$1"
    local dst="$2"

    # Если по целевому пути уже существует обычный файл - делаем бэкап,
    # чтобы не потерять существующую конфигурацию
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        warning "File already exists: $dst -> backing up to $dst.backup"
        mv "$dst" "$dst.backup"
    fi

    # Создаём симлинк (-s символьный, -f перезаписать если симлинк уже есть)
    ln -sf "$src" "$dst"
    info "Symlink created: $dst -> $src"
}



# Точка входа

# Если передан флаг --check — запускаем режим проверки (только macOS)
if [[ "$1" == "--check" ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        check_brewfile
    else
        error "--check is only supported on macOS"
        exit 1
    fi
    exit 0
fi

echo ""
echo "Installing dotfiles on $OS..."
echo ""

# На macOS проверяем наличие Homebrew перед установкой
if [[ "$OS" == "Darwin" ]]; then
    check_brew
fi

# Создаём симлинки для общих конфигов (работает на macOS и Linux)
create_symlink "$DOTFILES/.zshrc"     "$HOME/.zshrc"
create_symlink "$DOTFILES/.zprofile"  "$HOME/.zprofile"
create_symlink "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# Симлинки специфичные для macOS
if [[ "$OS" == "Darwin" ]]; then
    info "macOS: applying system-specific symlinks..."
    # create_symlink "$DOTFILES/macos/.somefile" "$HOME/.somefile"
fi

# Симлинки специфичные для Linux
if [[ "$OS" == "Linux" ]]; then
    info "Linux: applying system-specific symlinks..."
    # create_symlink "$DOTFILES/linux/.somefile" "$HOME/.somefile"
fi

echo ""
info "Done. Restart the terminal or run: source ~/.zshrc"
echo ""
