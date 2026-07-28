# dotfiles

Мои персональные конфигурационные файлы

## Содержимое

| Файл | Описание |
|------|----------|
| `.zshrc` | Конфигурация Zsh |
| `.zprofile` | Переменные окружения |
| `.gitconfig` | Конфигурация Git |
| `Brewfile` | Список CLI-утилит и приложений |
| `install.sh` | Скрипт установки симлинков |
| `obsidian/` | Настройки Obsidian |
| `obsidian-sync.sh` | Синхронизация `obsidian/` с хранилищем |

## Установка

```bash
git clone https://github.com/damakalshchikov/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Скрипт создаст симлинки из домашнего каталога на файлы в `~/dotfiles/`.  
Если файл уже существует - он будет сохранён с расширением `.backup`.

Для установки приложений из Brewfile:

```bash
brew bundle install
```

## Добавление нового дотфайла

1. Скопируй файл в `~/dotfiles/`
2. Добавь строку в `install.sh`:
   ```bash
   create_symlink "$DOTFILES/.file_name" "$HOME/.file_name"
   ```
3. commit и push

## Настройки Obsidian

`obsidian/` - копия части `.obsidian/` из хранилища.

### Сохранить изменения настроек

```bash
~/dotfiles/obsidian-sync.sh export
cd ~/dotfiles && git add obsidian && git commit -m "Update Obsidian settings" && git push
```

### Применить настройки на новом компьютере

1. Открой Obsidian
2. `~/dotfiles/obsidian-sync.sh import "/путь/к/хранилищу"` (по умолчанию `DEFAULT_VAULT` в скрипте)
3. Перезапусти Obsidian
4. Settings -> Community plugins -> Browse -> установи плагины из `community-plugins.json`
5. Settings -> Appearance -> Themes -> Browse -> установи тему из `appearance.json`
