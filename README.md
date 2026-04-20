# dotfiles

Мои персональные конфигурационные файлы

## Содержимое

| Файл | Описание |
|------|----------|
| `.zshrc` | Конфигурация Zsh |
| `.zprofile` | Переменные окружения |
| `.gitconfig` | Конфигурация Git |

## Установка

```bash
git clone https://github.com/damakalshchikov/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Скрипт создаст симлинки из домашней папки на файлы в `~/dotfiles/`.  
Если файл уже существует - он будет сохранён с расширением `.backup`.

## Добавление нового дотфайла

1. Скопируй файл в `~/dotfiles/`
2. Добавь строку в `install.sh`:
   ```bash
   create_symlink "$DOTFILES/.file_name" "$HOME/.file_name"
   ```
3. Закоммить и запушь
