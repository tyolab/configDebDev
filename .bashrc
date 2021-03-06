#       __               __             
#      / /_  ____ ______/ /_  __________
#     / __ \/ __ `/ ___/ __ \/ ___/ ___/
#  _ / /_/ / /_/ (__  ) / / / /  / /__  
# (_)_.___/\__,_/____/_/ /_/_/   \___/  
# 
# Leland Batey

# Setting flags for different versions of Unix. Since I could use this on OS
# X, Cygwin, Ubuntu, Fedora, Freebsd, or more, we need to account for the
# different ways to enable behaviours.
NIXTYPE="$(uname)"

# Default COLORFLAG. Set's as this for unknown systems.
COLORFLAG="--color=auto"
case "$NIXTYPE" in
    "Darwin" )
        COLORFLAG="-G"
        ;;

    "Linux" )
        COLORFLAG="--color=auto --group-directories-first"
        ;;

    "CYGWIN*" )
        COLORFLAG="--color=auto --group-directories-first"
        ;;
esac


# The below is a very ancient holdover from the classic TTY days. It used to be
# that you could pause the presentation of characters on a TTY by using a
# control key (Ctrl-S) so that the person using it could read things before they
# moved off the screen.
# Now though, that's wholely unnecessary, since you can scroll up in your
# terminal :). So, this little flag disables the very annoying behaviour of
# Ctrl-S freezing the terminal, requiring Ctrl-Q to unfreeze. So yay for things
# being more modern!
if [[ $- == *i* ]]; then
    stty -ixon
fi

# Append to the history file instead of over-writing it. Normally, the history
# file is read into memory by the shell, then overwritten when the shell exits.
# This can lead to a loss of history with multiple terminals open. Instead, this
# ensures the history will be appended-to, stopping loss of history.
shopt -s histappend

# Sets the term variable to be 256colors if the terminal would otherwise just
# call itself xterm. Done since MinTTY defaults to a TERM of 'xterm', which
# causes screen not to work with 256 colors.
case "$TERM" in
    xterm) export TERM="$TERM-256color";;
esac


if [ "$TERM" != "dumb" ]; then
    alias ls="ls $COLORFLAG"
fi

if [[ -f ~/.dir_colors && -n "$(which dircolors)" ]]; then
    eval `dircolors ~/.dir_colors`
fi

# If the appropriate bash_completion file exists, then source it!
if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

# Source bashmarks
if [ -f "$HOME/.local/bin/bashmarks.sh" ]; then
    . "$HOME/.local/bin/bashmarks.sh"
fi

## SSH KEYS ##
# The below handles ssh keys. It's inside a massive if block that checks if we are in an interactive vs non-interactive shell.
# This is important, since otherwise it breaks SFTP.
if [[ $- == *i* ]]
then
    ### RVM Startup! ###
    # By default RVM puts this next line into the .bash_profile line. However, 
    # this is a STUPID IDEA because .bash_profile is only exectuted for "login"
    # shells. By default, most shells opened once you've actually logged in are
    # NOT login shells. So URXVT, Gnome Terminal, etc are all non-login shells 
    # by default. However, they are interactive shells, which should be the
    # distinction. But, because the Ruby community seems to only ever do
    # anything on OS X and they don't care at all about how stuff works, they
    # plopped this down in .bash_profile and said that the way to fix this is
    # to change your terminal emulator to log in as a login shell.
    # Which is just INCREDIBLY stupid. They need to get their crap together.
    # Jerks.
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

    ### Starts ssh-agent and loads all ssh keys as needed ###
    # This excellent script was copied from http://rocksolidwebdesign.com/notes-and-fixes/ubuntu-server-ssh-agent/
    # Check to see if SSH Agent is already running
    agent_pid="$(ps -ef | grep "ssh-agent" | grep -v "grep" | awk '{print($2)}')"
     
    # If the agent is not running (pid is zero length string)
    if [[ -z "$agent_pid" ]]; then
        # Start up SSH Agent
     
        # this seems to be the proper method as opposed to `exec ssh-agent bash`
        eval "$(ssh-agent)"
     
        # if you have a passphrase on your key file you may or may
        # not want to add it when logging in, so comment this out
        # if asking for the passphrase annoys you
        ssh-add
     
    # If the agent is running (pid is non zero)
    else
        # Connect to the currently running ssh-agent
     
        # this doesn't work because for some reason the ppid is 1 both when
        # starting from ~/.profile and when executing as `ssh-agent bash`
        #agent_ppid="$(ps -ef | grep "ssh-agent" | grep -v "grep" | awk '{print($3)}')"
        agent_ppid="$(($agent_pid - 1))"
     
        # and the actual auth socket file name is simply numerically one less than
        # the actual process id, regardless of what `ps -ef` reports as the ppid
        agent_sock="$(find /tmp -path "*ssh*" -type s -iname "agent.$agent_ppid")"
     
        echo "Agent pid $agent_pid"
        export SSH_AGENT_PID="$agent_pid"
     
        echo "Agent sock $agent_sock"
        export SSH_AUTH_SOCK="$agent_sock"
        ssh-add
    fi
fi

# These copied from Lane Aasen (https://github.com/aaasen/config/blob/master/home/.bashrc)
#alias ls="ls --color=auto --group-directories-first"
alias la="ls -a" #all files
# Removed for better alternative below  alias ll="ls -l" #long listing format
# Lists all files in verbose form with human readable numbers/permissions.
alias lk="ls -alh" 
alias ll="ls -lhL" # lists files in long form, and in a more human readble 
                   # format. Additionally, the capital L makes `ls` regard
                   # symlinks as normal directories so they'd get grouped
                   # first as well.\

# The following aliases do not work on OS X.
# Grouped by file extension.
alias lx="ls -x"
# Lists only folders
alias ld="ls -d */"
# Lists in nice human readble form, sorts directories first, then groups files with similar formats together.
alias lo="ll --sort=extension"

alias netrestart="sudo service networking restart"

alias lguf="git ls-files --other --exclude-standard" # Lists all untracked files in a repository (alias name is a bit verbose)'
alias grpax="ps aux | grep" # Shortcut for searching for running processes
alias lesn="less -N" # Less now shows line numbers on the left hand side.
alias gca="git commit -am" # Makes commits faster!

# Automatically "pull" all github repos in the current users home directory
alias gpa="find ~/ -name .git -type d | sed 's,/*[^/]\+/*$,,' | xargs -L1 bash -c 'cd \$1 && git pull; echo -ne \ : \$1 \\\n' _"

alias gshow="git show --color --pretty=format:%b" # Pretty-printing of a commit in git

alias vnv="source ~/bin/venv/bin/activate"

function lag(){ # Stands for "list all gits" and it just lists all the git repos in current dir
    find $PWD -name ".git" -type d | sed 's,/*[^/]\+/*$,,'
}

# Function for quickly making latex-pdfs via Pandoc easier.
function mkPd(){
    echo $2 "what" $1
    pandoc --webtex -s -o $2 $1
}

# Function for splitting a string on a delimiter using python.
function pSplit(){
    #echo -e "1: $1\n2: $2"
    python -c "from __future__ import print_function
for x in \"\"\"$1\"\"\".split(\"$2\"): print(x);"
}

function mp(){
    x="$1"
    rawfile="${x%.*}" # Gets all items before first period
    outfile=""
    extension=".html"

    if [[ -z "$2" ]]; then
        outfile="$rawfile$extension"
    else
        outfile="$rawfile.$2"
    fi
    pandoc -s -o "$outfile" "$1"
}

function azbuild(){
    original_location="$PWD"

    # The below is super specific to my environment and not portable at all.
    cd "/home/bate136/projects/aztec_build/" 
    ./azbuild.py
    cd "$original_location"
}


#Increases the size of the .bash_history file to 5000 lines
HISTSIZE=50000

# Changes the prompt to have striking colors and a nice layout.
export PS1='\[\e[0;36m\]${debian_chroot:+($debian_chroot)}\u\[\e[1;33m\]@\[\e[0;35m\]\h:\[\e[0;32m\]\n\w\[\e[0m\] \n$ '

if [[ -n "$(which rvm)" ]]; then
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
fi

# Does rbenv specific setup
if [[ -n "$(which rbenv)" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi


# If terminal launched inside X, the DISPLAY variable will already be set.
# However, if launched without X (such as in CYGWIN) then DISPLAY will not be
# set. In these cases, we set it to a sane default.
if [ -z "$DISPLAY" ]; then
    DISPLAY=":0.0"
fi

