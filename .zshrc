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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/Users/sanskarjaiswal/Development/softwares/google-cloud-sdk/bin
export PATH=$PATH:/Users/sanskarjaiswal/Development/softwares
export PATH=$PATH:/opt/homebrew/opt/libpq/bin
export PATH=$PATH:/Users/sanskarjaiswal/go/bin
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/Users/sanskarjaiswal/Development/kubectl-plugins
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
export DOCKER_CONTEXT=amd
export KUBECONFIG="/Users/sanskarjaiswal/.lima/kind-arm/conf/kubeconfig.yaml"
export DOCKER_HOST="unix:///Users/sanskarjaiswal/.lima/kind-arm/sock/docker.sock"

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_MODE="awesome-patched"
export BAT_THEME="ansi"
alias cluster-arch="kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.architecture}' | xargs"

# fzf stuff
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*" --glob "!vendor/*" --glob "!target/*" --glob "!.idea/*" --glob "!*.pyc" --glob "!*.log"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyy-mm-dd"

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sanskarjaiswal/Development/softwares/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sanskarjaiswal/Development/softwares/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sanskarjaiswal/Development/softwares/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sanskarjaiswal/Development/softwares/google-cloud-sdk/completion.zsh.inc'; fi

nerdctl() {
    limactl shell k3s nerdctl "$@"
}
