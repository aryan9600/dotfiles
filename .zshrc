# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/sanskarjaiswal/.oh-my-zsh"
export HOMEBREW_NO_AUTO_UPDATE=1
export PATH=$PATH:/Users/sanskarjaiswal/.pyenv/shims
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm (node resolved via homebrew/mise; run `nvm use` to switch)

export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/opt/homebrew/opt/libpq/bin
export PATH=$PATH:/Users/sanskarjaiswal/go/bin
export PATH=$PATH:/Users/sanskarjaiswal/Development/kubectl-plugins
export PATH=$PATH:/Users/sanskarjaiswal/softwares/nvim/bin
export PATH=$PATH:~/softwares/google-cloud-sdk/bin
export PATH=$PATH:/opt/homebrew/lib/ruby/gems/3.4.0/bin
export PATH=$PATH:~/Development/flutter/bin
export PATH="/opt/homebrew/bin:$PATH"
export GO111MODULE=on
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
export TREMOR_PATH=/Users/sanskarjaiswal/Development/tremor/tremor-runtime/tremor-script/lib
export MACOSX_DEPLOYMENT_TARGET=10.7
export LD_LIBRARY_PATH=/Users/sanskarjaiswal/Development/source-controller/hack/libgit2/lib
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig"
export LANG=en_US.UTF-8
export LC_AlL=en_US.UTF-8
export GPG_TTY=$(tty)
export SEATBELT_PROFILE=restrictive-open
export DO_NOT_TRACK=true

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_MODE="awesome-patched"
export BAT_THEME="ansi"
alias cluster-arch="kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.architecture}' | xargs"
alias uts="/opt/homebrew/opt/tailscale/bin/tailscale"

# fzf stuff
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --glob "!vendor/*" --glob "!target/*" --glob "!.idea/*" --glob "!*.pyc" --glob "!*.log"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# source cargo
# . "$HOME/.cargo/env"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

plugins=(git rust golang docker kubectl aws zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(pyenv init -)"

nerdctl() {
    limactl shell k3s nerdctl "$@"
}

linebr() {
  echo $1 | awk '$1=$1' ORS='\\n'
}

# render mermaid diagram from clipboard
mmdc-clip() {
  local output="${1:-diagram.png}"
  local tmpfile=$(mktemp /tmp/mermaid.XXXXXX.mmd)
  pbpaste > "$tmpfile"
  mmdc --scale 4 -i "$tmpfile" -o "$output"
  rm "$tmpfile"
}

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# (plugins are set above, before oh-my-zsh is sourced)

# source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

export WASMTIME_HOME="$HOME/.wasmtime"

export PATH="$WASMTIME_HOME/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/sanskarjaiswal/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sanskarjaiswal/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/sanskarjaiswal/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sanskarjaiswal/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

. "$HOME/.local/bin/env"
export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

# Added by Antigravity
export PATH="/Users/sanskarjaiswal/.antigravity/antigravity/bin:$PATH"

eval "$(/Users/sanskarjaiswal/.local/bin/mise activate zsh)" # added by https://mise.run/zsh

# bun completions
[ -s "/Users/sanskarjaiswal/.bun/_bun" ] && source "/Users/sanskarjaiswal/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# use podman as docker
export DOCKER_HOST="unix:///var/folders/gt/k1gsx53n54d7x6h6zrqt2srw0000gn/T/podman/podman-machine-default-api.sock"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sanskarjaiswal/.lmstudio/bin"
# End of LM Studio CLI section

source /usr/local/scripts/init-posix.sh # Safe-chain Zsh initialization script

squash_commit() {
  git add -u . && git commit -m "some random msg" && GIT_SEQUENCE_EDITOR='perl -i -pe "s/^pick/squash/ if $. == 2"' git rebase -i HEAD~2
}

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# opencode
export PATH=/Users/sanskarjaiswal/.opencode/bin:$PATH
