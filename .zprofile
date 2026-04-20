# macOS
if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    export PATH="/Library/Frameworks/Python.framework/Versions/3.14/bin:$PATH"
fi

# Linux
if [[ "$(uname)" == "Linux" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
