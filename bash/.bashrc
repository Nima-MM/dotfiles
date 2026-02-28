# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#autojump
if [ -f /usr/share/autojump/autojump.sh ]; then
    . /usr/share/autojump/autojump.sh
fi

#git-prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source "$HOME/.bash-git-prompt/gitprompt.sh"
fi
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

env=~/.ssh/agent.env
agent_load_env () {
    . "$env" >| /dev/null ; }
agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }
if [ ! "$SSH_AUTH_SOCK" ] || [ "$agent_run_state" = 2 ]; then
    agent_load_env
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ "$agent_run_state" = 1 ]; then
    ssh-add
fi
#android studio
export PATH=$PATH:/opt/android-studio/bin


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Load Angular CLI autocompletion.
source <(ng completion script)
export PATH="$HOME/.local/bin:$PATH"

# alias to open the pwd dir e.g. in nautilus
alias o='xdg-open'

# Gemini Smart Autocomplete v3 (Visual Preview)
# Trigger:
#   Strg+Space (1x) -> Vorschau anzeigen (unter der Zeile)
#   Strg+Space (2x) -> Vorschau annehmen (ganze Zeile)
#   Strg+PfeilRechts -> Nächstes Wort annehmen

# Hilfsfunktion: Match finden
_gemini_get_match() {
    local input="$1"
    [[ -z "$input" ]] && return
    # Suche in History (letzte 500), ignoriere führende Leerzeichen
    fc -lnr -500 | awk -v prefix="$input" '{
        gsub(/^[ \t]+/, "", $0);
        if (index($0, prefix) == 1) { print $0; exit }
    }'
}

# Variable zum Speichern des letzten Vorschlags für die "2x Drücken"-Logik
_GEMINI_LAST_SUGGESTION=""

_gemini_preview_or_accept() {
    local current_text="${READLINE_LINE:0:$READLINE_POINT}"
    [[ -z "$current_text" ]] && return

    # 1. Match suchen
    local match=$(_gemini_get_match "$current_text")
    [[ -z "$match" ]] && return

    # 2. Check: Haben wir diesen Vorschlag gerade schon angezeigt?
    if [[ "$match" == "$_GEMINI_LAST_SUGGESTION" ]]; then
        # Ja -> Annehmen (Vervollständigen)
        READLINE_LINE="$match"
        READLINE_POINT=${#READLINE_LINE}
        _GEMINI_LAST_SUGGESTION="" # Reset

        # Zeile sauber neu zeichnen (löscht die Vorschau-Zeile unten)
        echo -ne "\r\033[K" # Zeile löschen (Vorsichtshalber)
        # Bash wird die Zeile automatisch neu zeichnen
    else
        # Nein -> Nur Anzeigen (Preview)
        _GEMINI_LAST_SUGGESTION="$match"

        # Cursor speichern, Zeile runter, Grau drucken, Cursor zurück
        # \e[90m = Grau, \e[0m = Reset
        # \e7 = Save Cursor (xterm), \e8 = Restore Cursor
        # \n = Neue Zeile

        local preview_text="  (Vorschlag: ${match})"

        # Trick: Wir nutzen echo um unter die Zeile zu schreiben, ohne den Prompt zu zerstören
        echo -ne "\n\e[90m${preview_text}\e[0m"

        # Wir müssen den Prompt "neu zeichnen" erzwingen, sonst bleibt der Cursor unten
        # Aber READLINE macht das meistens selbst, wenn wir zurückkehren.
        # Wir nutzen tput, um den Cursor wieder hochzuholen
        tput cuu1 # Cursor 1 hoch
        tput cuf $READLINE_POINT # Cursor nach rechts an alte Stelle
    fi
}

_gemini_accept_word() {
    local current_text="${READLINE_LINE:0:$READLINE_POINT}"
    local match=$(_gemini_get_match "$current_text")
    [[ -z "$match" ]] && return

    local remainder="${match:${#current_text}}"
    [[ -z "$remainder" ]] && return

    local next_chunk=""
    if [[ "$remainder" =~ ^[^[:space:]]+ ]]; then
        next_chunk="${BASH_REMATCH[0]}"
    elif [[ "$remainder" =~ ^[[:space:]]+[^[:space:]]+ ]]; then
        next_chunk="${BASH_REMATCH[0]}"
    else
        next_chunk="$remainder"
    fi

    READLINE_LINE="${current_text}${next_chunk}"
    READLINE_POINT=${#READLINE_LINE}

    # Reset Preview State, da wir den Text geändert haben
    _GEMINI_LAST_SUGGESTION=""
}

# Bindings
bind -x '"\C-@": _gemini_preview_or_accept'
bind -x '"\e[1;5C": _gemini_accept_word'
bind -x '"\e[5C": _gemini_accept_word'


# gemini autovervollständigungssript ende

# gemini-cli aliases
alias gem='npx @google/gemini-cli'
alias gemp='npx @google/gemini-cli -p'
