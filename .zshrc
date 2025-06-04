export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"

# ShellHistory
PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"
__shhist_session="${RANDOM}"
__shhist_command_count=0
__shhist_prompt() {
    local __exit_code="${?:-1}"
    (( __shhist_command_count++ ))
    if (( __shhist_command_count % 10 == 0 )); then
        \history -D -t "%s" -10 | sudo --preserve-env --user ${SUDO_USER:-${LOGNAME}} shhist insert --session ${TERM_SESSION_ID:-${__shhist_session}} --username ${LOGNAME}
        echo "Exported to ShellHistory" >&2
    fi
    return ${__exit_code}
}
if [[ -z "${precmd_functions+x}" ]]; then
    precmd_functions=(__shhist_prompt)
elif [[ ! " ${precmd_functions[@]} " =~ " __shhist_prompt " ]]; then
    precmd_functions+=(__shhist_prompt)
fi
# ================

function generate_prompt_line {
  local time=$(date +%T)
  local term_width=${COLUMNS}
  local line_width=$((term_width - ${#time} - 1))
  printf "%-${line_width}s %s\n" "-" "$time" | tr ' ' '-'
}

# Local ANSI color codes
local user_color=$'\033[1;36m'  # Bright Cyan for username
local host_color=$'\033[1;32m'  # Bright Green for hostname
local dir_color=$'\033[1;34m'   # Bright Blue for directory
local reset_color=$'\033[0m'    # Reset to default terminal color

PROMPT="${user_color}%n${reset_color}@${host_color}%m${reset_color}:${dir_color}%~${reset_color}"$'\n'"%# "

precmd() {
  generate_prompt_line
}

# =================

autoload -Uz compinit && compinit

local gnupghome="${XDG_CONFIG_HOME}/gnupg"
if [ ! -d $gnupghome ]; then
    echo "GNUPGHOME not detected. Setting up GNUPGHOME at ${gnupghome}"
    mkdir -p $gnupghome
fi
export GNUPGHOME=$gnupghome

eval "$(direnv hook zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

eval "$(register-python-argcomplete pipx)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


alias so='source ~/.zshrc'
