export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"


# ShellHistory
# Adding shhist to PATH so we can use it from Terminal
PATH="${PATH}:/Applications/ShellHistory.app/Contents/Helpers"

# Creating a unique session ID for each terminal session
__shhist_session="${RANDOM}"

# Counter to track commands executed since the last export
__shhist_command_count=0

# Function to record history every 10 commands
__shhist_prompt() {
    local __exit_code="${?:-1}"
    (( __shhist_command_count++ )) # Increment the command counter

    # Export history every 10 commands
    if (( __shhist_command_count % 10 == 0 )); then
        \history -D -t "%s" -10 | sudo --preserve-env --user ${SUDO_USER:-${LOGNAME}} shhist insert --session ${TERM_SESSION_ID:-${__shhist_session}} --username ${LOGNAME}
        echo "Exported to ShellHistory" >&2  # Print to stderr to avoid interfering with other outputs
    fi

    return ${__exit_code}
}

# Ensure __shhist_prompt is added only once to precmd_functions
if [[ -z "${precmd_functions+x}" ]]; then
    precmd_functions=(__shhist_prompt)
elif [[ ! " ${precmd_functions[@]} " =~ " __shhist_prompt " ]]; then
    precmd_functions+=(__shhist_prompt)
fi
# ================

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

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
