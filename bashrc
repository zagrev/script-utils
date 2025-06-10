#
# Steve's bashrc, without all the unnecessary crap
#

TEXT_WARN='\e[33m' # WARN
TEXT_ERROR='\e[31m' # Red
TEXT_DEFAULT='\e[0m' # default

function set_autorelabel () {
if [ -f "/.autorelabel" ]; then
    echo -e ${TEXT_ERROR}"System Reboot for ${HOSTNAME} required. Please reboot when convenient"${TEXT_DEFAULT}

    echo;
fi
}

function set_MOTD () {
  if [ -s /etc/motd ]; then
     echo -e ${TEXT_WARN}'Message of the Day:'${TEXT_DEFAULT}
     cat '/etc/motd'
     echo;
  fi
}

function set_WKSTMOTD () {
  if [ -s /opt/motd ]; then
    echo -e ${TEXT_WARN}'Local messages from /opt/motd:'${TEXT_DEFAULT}
    cat '/opt/motd'
    echo;
  fi
}

if echo $- | grep i > /dev/null
then
  echo -e ${TEXT_WARN}"System: "${TEXT_DEFAULT}${HOSTNAME}
  echo -e ${TEXT_WARN}"Uptime: "${TEXT_DEFAULT}$(uptime | sed 's/.*up \(.*\),.*user.*/\1/')
  echo -e ${TEXT_WARN}"   CPU: "${TEXT_DEFAULT}$(lscpu | grep 'CPU(s):' | head -n1 | awk '{print $2 " threads"}')
  echo -e ${TEXT_WARN}"Memory: "${TEXT_DEFAULT}$(free -h | awk 'NR==2{printf "%s/%s (%.2f%%)\n", $3,$2,$3*100/$2 }')
  echo -e ${TEXT_WARN}" Users: "${TEXT_DEFAULT}$(who | awk '!seen[$1]++ {printf $1 " "}')
  echo;
  set_autorelabel
  set_MOTD
  set_WKSTMOTD
fi

function _cd()
{
  'cd' "$@"

  export PS1='[\u@\h \w]\$ '
  if [[ -f /.dockerenv ]]
  then
    PS1="[\u@${TEXT_WARN}\h${TEXT_DEFAULT} \w]\$ "
  fi
  PWD=$(echo "${PWD}" | sed -r \
      -e 's_/home/sbetts/scitec/t1tan/viz/integrated-operations-environment_IOE_' \
    )
}
alias cd="_cd"

export PATH_ORIG=${PATH}
export SCRIPT_DIR="${HOME}/scripts"
export GCC_HOME="/usr/local/gcc-trunk"
export MVN_DIR="${HOME}/foss/apache-maven-3.9.8/bin"

export PATH="${SCRIPT_DIR}:${GCC_HOME}/bin:${MVN_DIR}:${PATH}"
export LD_LIBRARY_PATH="${GCC_HOME}/lib64:${LD_LIBRARY_PATH}"

# bash history
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoreboth
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dnfvar="/usr/libexec/platform-python -c 'import dnf, json; db = dnf.dnf.Base(); print(json.dumps(db.conf.substitutions, indent=2))'"

alias repolist='dnf -v repolist | grep -E -- "(o-id|o-size)" | awk -F: "print \$0" '
boo="\/size\/ { print $2 } \/-id\/ { printf \"%s\",$2 }\' '"

alias df="df -h"
alias vi="vim"

# ansible
alias a="ansible"
alias ap="ansible-playbook"

# docker
alias dps='docker ps --all --format="table {{.Names}}\t{{.Ports}}\t{{.Status}}"'
alias drm=fdrm
alias drmi=fdrmi
alias dim='docker images --format="table {{.Repository}}:{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}" --filter "dangling=false" | tail -n +2 | sort'
alias dip="docker inspect --format='{{range.NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "
alias dc="docker compose"

# git
alias gst="git status"
alias gco="git checkout"
alias gcm="git commit -am"
alias gpl="git pull --prune"
alias gps="git push"
alias gcl="git clone"
alias grh="git reset --hard"
alias grs="git reset --soft"
alias gf="git fetch --prune"
alias gl='git log --pretty=format:"%h %ad %s" -n 1000 --date=short --graph'
alias gd="git diff"

# Source Bash completion definitions for tab completion on commands
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [[ -f ${HOME}/.config/git_bash_completion ]]
then
  . ${HOME}/.config/git_bash_completion

  __git_complete gst _git_status
  __git_complete gco _git_checkout
  __git_complete gcm _git_commit
  __git_complete gpl _git_pull
  __git_complete gps _git_push
  __git_complete gcl _git_clone
  __git_complete grh _git_reset
  __git_complete grs _git_reset
  __git_complete gf _git_fetch
  __git_complete gl _git_log
  __git_complete gd _git_diff
fi

alias python="python3.11"
alias python3="python3.11"

function fdrm {
  if [[ -n "${1}" ]]
  then
    names=${*}
  else
    names=$(docker ps --filter "status=exited" --filter "status=created" --format "{{.Names}}")
  fi
  if [[ -n "${names}" ]]
  then
    docker rm -f ${names}
  fi
}

function fdrmi {
  local names=${1:-*}

  matches=$(docker images | tail -n +2 | grep -E -- "${names}" | awk '/<none>/ { print $3; next } { printf("%s:%s\n",$1,$2)}')
  if [[ -z "${matches}" ]]
  then
    echo "No matching images found"
    return 1
  fi

  docker rmi ${matches}
}


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Load Angular CLI autocompletion.
source <(ng completion script)
