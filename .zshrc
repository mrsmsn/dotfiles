# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export FZF_DEFAULT_OPTS="--reverse --border"
## FIXME:何故か下記の環境変数を設定してもfzf-tmux側にデフォルトのオプションとして渡されないので解決する
##       現状は各コマンドを呼ぶ際に"fzf-tmux -p -w80%"と冗長になっているが"fzf-tmux"だけでいい感じにするように直したい
# export FZF_TMUX=1
export FZF_TMUX_OPTS='-p80%,60%'

## エイリアス
alias ll='lsd -al --group-directories-first'
alias chrome='open -a google\ chrome'
alias lg='lazygit'
alias cal='jpcal'
alias fk='fzf-kill'
alias docker='lima nerdctl'

## 関数

### ソース一覧に飛ぶやつ
function fzf-src() {
### ghq.rootを複数設定している場合に対応するため、-pオプションを使用している。一方でghq list -pでフルパスがpreview表示されるとうざいのsedで加工
    local selected_dir=$(ghq list -p | sed -e  "s#$(echo $HOME)#$HOME#" | fzf-tmux -p -w80% --query "$LBUFFER" --prompt="Repo >" --preview "lsd -1A --group-directories-first --color=always --icon=always {}" )
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-src
bindkey '^]' fzf-src

### fzfでhistory検索
function select-history() {
  BUFFER=$(history -n -r 1 | awk '!a[$0]++' | fzf-tmux -p -w80% -e --no-sort +m --query "$LBUFFER" --prompt="History > " | sed 's/\\n/\n/g')
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

### killするプロセスを選択
function fzf-kill() {
 kill `ps aux | fzf-tmux -p -w80% -e | awk '{print $2}'`
}

##tmuxを自動で起動する奴
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_osx() { [[ $OSTYPE == darwin* ]]; }
function is_screen_running() { [ ! -z "$STY" ]; }
function is_tmux_runnning() { [ ! -z "$TMUX" ]; }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONECTION" ]; }

function tmux_automatically_attach_session()
{
    if is_screen_or_tmux_running; then
        ! is_exists 'tmux' && return 1

        if is_tmux_runnning; then
        elif is_screen_running; then
            echo "This is on screen."
        fi
    else
        if shell_has_started_interactively && ! is_ssh_running; then
            if ! is_exists 'tmux'; then
                echo 'Error: tmux command not found' 2>&1
                return 1
            fi

            if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
                # detached session exists
                tmux list-sessions
                echo -n "Tmux: attach? (y/N/num) "
                read
                if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
                    tmux attach-session
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                    tmux attach -t "$REPLY"
                    if [ $? -eq 0 ]; then
                        echo "$(tmux -V) attached session"
                        return 0
                    fi
                fi
            fi

            if is_osx && is_exists 'reattach-to-user-namespace'; then
                # on OS X force tmux's default command
                # to spawn a shell in the user's namespace
                tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))
                tmux -f <(echo "$tmux_config") new-session && echo "$(tmux -V) created new session supported OS X"
            else
                tmux new-session && echo "tmux created new session"
            fi
        fi
    fi
}
tmux_automatically_attach_session

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY

eval "$(starship init zsh)"
