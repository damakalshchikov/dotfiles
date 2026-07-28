#!/bin/bash

# obsidian-sync.sh - синхронизация настроек Obsidian между хранилищем и dotfiles

set -e

DOTFILES="$HOME/dotfiles"
DEST="$DOTFILES/obsidian"
DEFAULT_VAULT="$HOME/Desktop/Sync/Моё хранилище"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }

TOP_LEVEL_FILES=(
    app.json appearance.json core-plugins.json community-plugins.json hotkeys.json
    types.json templates.json daily-notes.json graph.json canvas.json backlink.json
    page-preview.json command-palette.json webviewer.json
)

usage() {
    echo "Использование: $0 <export|import> [путь_к_vault]"
    echo "  export — скопировать настройки из vault в $DEST"
    echo "  import — скопировать настройки из $DEST в vault"
    echo "  путь_к_vault по умолчанию: $DEFAULT_VAULT"
    exit 1
}

MODE="$1"
VAULT="${2:-$DEFAULT_VAULT}"
OBS="$VAULT/.obsidian"

[[ "$MODE" == "export" || "$MODE" == "import" ]] || usage
[ -d "$OBS" ] || { warning ".obsidian не найден по пути: $OBS"; exit 1; }

if [[ "$MODE" == "export" ]]; then
    SRC_ROOT="$OBS"; DST_ROOT="$DEST"
else
    SRC_ROOT="$DEST"; DST_ROOT="$OBS"
fi

mkdir -p "$DST_ROOT/snippets" "$DST_ROOT/plugins"

for f in "${TOP_LEVEL_FILES[@]}"; do
    [ -f "$SRC_ROOT/$f" ] && cp "$SRC_ROOT/$f" "$DST_ROOT/$f" && info "$f"
done

if [ -d "$SRC_ROOT/snippets" ]; then
    cp "$SRC_ROOT/snippets/"*.css "$DST_ROOT/snippets/" 2>/dev/null && info "snippets/*.css"
fi

if [ -d "$SRC_ROOT/plugins" ]; then
    for p in "$SRC_ROOT/plugins/"*/; do
        name=$(basename "$p")
        if [ -f "$p/data.json" ]; then
            mkdir -p "$DST_ROOT/plugins/$name"
            cp "$p/data.json" "$DST_ROOT/plugins/$name/data.json" && info "plugins/$name/data.json"
        fi
    done
fi

echo ""
info "Готово: $MODE ($SRC_ROOT -> $DST_ROOT)"
if [[ "$MODE" == "export" ]]; then
    echo "Дальше: cd $DOTFILES && git add obsidian && git commit -m 'Update Obsidian settings' && git push"
else
    warning "Плагины и тему нужно доустановить вручную: Settings -> Community plugins/Themes -> Browse (список в community-plugins.json)"
fi
