# ~/ds/env/common.sh
# 
# Aliases and default ENV vars for ALL platforms.
# May be overridden in later os, host, user -specific files.
# (keep control-flow in ~/ds/env/bashrc)
# 
# Some aliases here are never actually be used, instead they are here only as
# TAB-complete-able (or `type -a`-able) tips / reminders.
# Others haven't been used in a decade, please forgive the dusty corners.

#### Bugs
# * see ~/ds/TODO.txt
# * I `export` too many things

# Note: When changing aliases into functions: add `unalias the_name 2>/dev/null`
# as a temporary work-around needed for `bashrc` re-sourcing existing shells.

g=gossamer.no-ip.com
e=erbon.no-ip.com
p=peterb.no-ip.org
q=10.142.242.20
a=10.142.242.21
t=10.142.242.22
d=10.142.242.23
r=10.142.242.24

## Convention for vnc server ports:
# 5900 system server
# 5901 VineServer.app sytem, x11vnc-slurp of console
# 5904 VineServer.app sytem, or Xvnc headless X session
## monotone ports:
# 4691  # default (localhost)
# 4690  # Home via tunnel
# 4694  # Work via tunnel

host_log="$HOME/ds/settings/host_$host.log"
# OR Keep in site-specific version control, by changing ./<site|host>_*.sh:
# host_log="$HOME/work/$SITE/host_$host.log"

EDITOR=vim
export EDITOR

LANG=C    # Predictable sort order (unless overridden with LC_COLLATE, or LC_ALL)
# LANG=en_US.UTF-8    #
export LANG
# TODO: common functions to look at LANG, LC_*

NTP_SERVERS=north-america.pool.ntp.org
#NTP_SERVERS="time.chu.nrc.ca time.nrc.ca tick.utoronto.ca tock.utoronto.ca ntp2.usno.navy.mil"
# ...site-specific settings may add prefixes
export NTP_SERVERS

NETWORK_ADAPTER=eth0
NETWORK_ADAPTERS="eth0"
export NETWORK_ADAPTER NETWORK_ADAPTERS

PYTHONSTARTUP="$HOME/.pystartup"
PYTHONSTARTUP="$HOME/.pythonrc.py"
export PYTHONSTARTUP

alias alias-free-tip='echo "command ... # searches only PATH and builtins
builtin ... # searches only raw builtins"'

#### VNC
VNC_DISPLAY=':4'
VNC_SIZE='1260x1000'
VNC_DEPTH=16
# if $DISPLAY is already set, all hell breaks loose:
alias vnc-start='env -u DISPLAY vncserver $VNC_DISPLAY -geometry $VNC_SIZE -depth $VNC_DEPTH -name "$(hostname.sh): $LOGNAME"'
alias vnc-stop='vncserver -kill $VNC_DISPLAY'
alias vncviewer-8='vncviewer  -depth 8 -bgr233 -encodings "copyrect tight hextile zlib corre rre"'
# ...assumes 'tightvnc'
alias x11-vnc-slurp=x11vnc-slurp
alias x11vnc-slurp='x11vnc -rfbauth ~/.vnc/passwd -forever -v -localhost -rfbport 5901 -o ~/log/x11vnc.log -bg -xkb'
alias vnc-x11-slurp='x11-vnc-slurp'

#### Synergy virtual kvm
unset SYNERGY_SERVER_CONFIG_FILE 2>/dev/null
SYNERGY_SERVER=$q
export SYNERGY_SERVER
SYNERGY_USER=""
export SYNERGY_USER
function synergy-slave () {
    title "XXX-Synergy-slave"
    synergy-slave.sh
}
alias synergy-slave-window='( unset STY ; unset TITLE;  xterm $xterm_args -geom 100x20 -bg lightskyblue -e synergy-slave.sh  & disown-last )'
# killall `-s` is the simulate/dry-run flag on darwin, BUT is `-s SIGNAME` on linux
# the undocumeted `-SIGNUM` works on both
synergy-kill () {
    if killall -u $LOGNAME -0 synergyc 2>/dev/null ; then
         echo Killing synergy slave...
         # TODO: first ask nicely with SIGTERM
         killall -u $LOGNAME -9 synergyc
    fi
    if killall -u $LOGNAME -0 synergys 2>/dev/null ; then
         echo Killing synergy master...
         killall -u $LOGNAME -9 synergys
    fi
}

#### Detachable terminal sessions with `screen`
alias scr-list='screen -ls'
# Detach, Resume, OR Create consistently named screen sessions
function scr () {
    # name="${1:-${host:-`uname -n | cut -d . -f 1`}}"
    # Use fixed string, avoid conflict with G.panic tools:
    name="${1:-host}"
    if [ -n "$STY" ] ; then
      fail "Already inside a screen session: '$STY'" >&2
      return 1
      # ...but that will NOT detect: screen + ssh + screen
    fi
    # BEWARE: Order (and grouping) matters for screen -flags!!
    TITLE="$name" screen -e^Tt -A -S "$name" -t "$name" -d -RR
    # TODO: this makes TITLE exported in those shells
    # Really want it *set* but NOT *exported*.
    # SUB-process that "need" TITLE passed in env:
    # * ~/ds/bin/name
    # SUB-process that must avoid TITLE passed in env:
    # * xterm
    # * xbindkeys
    # * vncserver
    # NEEDS it:
    # * $PS1, $PROMPT_COMMAND, ~/ds/env/prompt-* 
    # * ~/ds/env/ name-auto (sourced script)
    # * ~/ds/env/name-man  (sourced script)
    # GENERATORS of TITLE env var
    # * scr (this func)
    # * ~/ds/env/xinitrc
}
# NOTE: `scr` does NOT detect screen + ssh + screen, so always detach first,
# Or name give the remote shell a FAKE screen name:
alias scr-remote-prevent='export STY=__REMOTE__'

### Typos
alias wq='echo "Youre not in vi, dummy."'
alias :wq='echo "Youre not in vi, dummy."'
alias :w='echo "Youre not in vi, dummy."'
alias :q='echo "Youre not in vi, dummy."'
alias vm='mv'
alias cd-='cd -'
## MetaFont -- be afraid.
alias mf='echo -e "No, you probably meant _mv_\n[ENTER] to continue" >&2 ; read ; false'
alias CD='cd'
alias LL='ll'
alias LS='ls'
alias LESS='less'
alias PATH=path
alias PWD='pwd'
alias EXIT='exit'

### Path Variables, finding executables
alias findbin='type -ap'
#alias bin='type -a | ~/ds/bin/bin.pl' ## TODO
alias bin='type -a'
binls () { 
    ls -l $(type -p "$@")
}

alias path='echo $PATH | path2lines'
alias classpath='echo $CLASSPATH | path2lines'
alias libpath='echo $LD_LIBRARY_PATH | path2lines'
alias manpath='echo $MANPATH | path2lines'

### Terminal / Prompt config
alias sane='stty sane'
alias text-white='. ~/ds/env/text-white'
alias text-black='. ~/ds/env/text-black'
alias prompt-bare='. ~/ds/env/prompt-bare'
alias prompt-normal='. ~/ds/env/prompt-normal'
alias prompt-fancy='. ~/ds/env/prompt-fancy'
alias prompt-pro='. ~/ds/env/prompt-pro'
alias colors='eval `dircolors /home/ddd/dircolors.db`'
function title () {
    TITLE="$*"
}
alias pswd-mode-on='stty -echo'
alias pswd-mode-off='stty echo'

stty-backspace () { 
    if [ -z "$1" ] ; then
        echo -e "Needs argument char\n\tTIP: use ^V + key"
        return 1
    fi
    char="$1";
    stty sane;
    stty erase "$char"
}
function stty-save () {
    stty -g > ~/tmp/stty."$host"-"${1:-save}"
}
function stty-restore () {
    stty "$(cat "$1")"
}

#### XEmacs
alias gc='gnuclient -q'
gc-all () {
  for f in "$@"; do
    gnuclient.xemacs21 -q "$f";
  done
}
alias gc-wait='gnuclient'
alias gc-wait-finish='echo "C-x #"'
alias gc-nox='gc -nw'
alias gc-nox-finish='echo "C-X 5 0 (delete-frame)"'

#### GNU Emacs
alias ec='emacsclient -n'
ec-all () {
  for f in "$@"; do
    emacsclient -n "$f";
  done
}
alias ec-wait='emacsclient'
alias ec-wait-finish='echo "C-x #"'
alias ec-nox='emacsclient -nw'
alias ec-nox-finish='echo "C-X 5 0 (delete-frame)"'

# Try to use native tool:
alias gg='gnuclient'
alias ee='emacsclient'  ## 
alias ee-tips='echo "wait for C-x # unless -n
-n no-wait (wont be a server buffer waiting for C-x #)
-nw No X-Window / in current terminal (?? not in 10.5 /usr/bin/ (22.1) )
-c create frame NEW X window          (?? not in 10.5 /usr/bin/ (22.1) )"'

### Misc Command-line
## Safe / sanity check before ^p^a^d[Enter] (to *really* `rm -rf`)
unalias arm 2>/dev/null
arm () {
    if [ "$1" == "-rf" ] ; then 
        shift
    fi
    du -sm -- "$@"
}
rm-if-symlink () { 
    # silently succeeds when file do not exist at all
    for f in "$@"; do
        test -L "$f" && rm "$f";
    done
}
alias vim-vimrc-only-mine='vim -u $HOME/.vimrc'  ## no /etc/vimrc
alias vim-vimrc-none='vim -u /dev/null'
alias vim-at-eof='vim +'
alias rwd='/bin/pwd'
alias cdr='cd `rwd`'
alias cdd='cd "$PWD"'
alias tar-extract-as-root-BUT-no-preserve-tip='echo "tar --no-same-owner -xzf ..."'
alias touch-with-time-tip='echo "touch -t \"[[CC]YY]MMDDhhmm[.ss]\""'
# Sortable, and filename-able date+time string
alias ddatetime='date "+%Y-%m-%d_%H-%M-%S"'
alias ddate='date "+%Y-%m-%d"'
alias ttime='ddatetime ; time'
alias gzcat='zcat'
alias cls='clear'
# LS_CLR setup in bashrc where we do terminal type detection
alias ls='LC_COLLATE="C" ls -F $LS_CLR'
# See `locale` for LANG, LC_ALL, and more specific LC_COLLATE, LC_TIME, etc.
alias ls-colours-off='LS_CLR='
alias l.='ls -dF .??* $LS_CLR'
alias lat='clear;pwd;ls -AF $LS_CLR'
alias ll='ls -lF $LS_CLR'
alias llt='clear;pwd;ls -lAF $LS_CLR'
alias lt='clear;pwd;ls -F $LS_CLR'
alias sendmail='/usr/lib/sendmail'
# prevent `find` from crossing filesystems
#alias find='find -x'    ## bsd
#alias find='find -xdev' ## linux / cygwin
alias all.files='find . -type f | fgrep -v /CVS/ | fgrep -v "/\\.svn/" | cut -c 3- | sort > all.files'
alias all.dirs='find . -type d  | grep -v /CVS$ | grep -v "/\\.svn$" | cut -c 3- | grep -v ^$ | sort > all.dirs'
alias all.dirs2='find . -type d | cut -c 3- | sort > all.dirs'
alias all.files2='find . -type f | cut -c 3- | grep -v ^$ | sort > all.files'
alias zip='zip -q -r'
alias zip-example='zip -q -r foo[.zip] dir1 ...'
alias unzip='unzip -q'
alias unzip-t='unzip --q -t'
alias bunzip='bunzip2'
alias sort-ignore-case='sort -f'
alias cp-a='cp -Rp'      ## if no gnufileutils w/o `cp -a`
alias info-apropos='info --apropos'
alias info-to-text='info -o - --subnodes'
alias line-number='nl -b a'
alias number-lines='nl -b a'
alias number-sequence-generator-tip='echo num.pl, or seq'
alias pdf-viewer='evince'
alias less-raw-tail='less -r +F'
alias echo-no-newline='echo -n'
alias disown-last='disown $!'
alias dirs-depth='echo "${#DIRSTACK[*]}"'
alias shlvl='echo "$SHLVL"'
alias unset-function='unset -f'
alias tf='echo True || (echo False ; false)'   # some_cmd && tf
# Report & log the exit status of the prev command (or background | pipeline ; TF )&
function TF () {
  prev_status="$?"
  if [ $prev_status == 0 ] ; then
    echo -e "\nOK $*"
  else
    echo -e "\nFAILED $*"
  fi
  # Allow chaining commands with && / ||
  return $prev_status
}
TF-logged () {
    if [ $? == 0 ]; then
        # Leading \n so completing background tasks don't intermix with other STDOUT lines
        echo -e "\nOK $*\t$(ddatetime)" | tee -a TF.$1
        # Allow chaining-on with && / ||
        true
    else
        echo -e "\nFAILED $*\t$(ddatetime)" | tee -a TF.$1
        false
    fi
}
fail () {
    # Beware: will NOT return from the caller
    echo -e "Failed: $*" >&2
    return 1
}
fail-pause () {
    # Beware: will NOT return from the caller
    echo -e "Failed: $*\n\tPaused: [Enter] to continue" >&2
    read
    return 1
}
alias choke=fail-pause
die () {
    # TODO: optionally: if [ $1 -eq $(( 1 + $1 ))  ## ARGV 1 is numeric
    # consider using that as the return code instead of `return 1`
    echo -e "Died: $*" >&2
    exit 1
}

mkcd () {
    if [ "x$2" != "x" ] ; then
        echo "ignoring multiple arguments: $*" >&2
    fi
    mkdir -p "$1";
    cd "$1"
}
timesrepeat () { 
    n="$1"; shift;
    for i in $(num.pl $n) ; do
        eval "$*";
    done
}
is-valid-y-m-d () { 
    y=$1 m=$2 d=$3
    # Use `test` instead of `[` for better non-integer error handling
    # BUT: now that we're using `$var -ge $low -a $var -le $high` instead of 
    #      `$var -ge $low -a $var -le $high` could we revert to `[`???
    if ! test $y -ge 1998 -a $y -le 2036 ; then
        echo -e "ERROR:\n\tLazy programmer ignored before 1998 and after 2036." >&2
        return 1
    fi
    if ! test "$m" -ge 1 -a "$m" -le 12 ; then
        return 1
    fi
    if ! test "$d" -ge 1 -a "$d" -le 31 ; then
        return 1
    fi
    # from here on we know that y,m,d are integers so `[` is fine
    if [ "$m" -eq 4 -o "$m" -eq 6 -o "$m" -eq 9 -o "$m" -eq 11 ]; then
        if [ "$d" -gt 30 ]; then
            return 1
        fi
    fi
    if [ "$m" -eq 2 ]; then
        if [ "$y" -eq 2000 -o "$y" -eq 2004 -o "$y" -eq 2008 -o "$y" -eq 2012 -o "$y" -eq 2016 -o "$y" -eq 2020 -o "$y" -eq 2024 -o "$y" -eq 2028 -o "$y" -eq 2032 -o "$y" -eq 2036 ]; then
            if [ "$d" -gt 29 ]; then
                return 1
            fi
        else
            if [ "$d" -gt 28 ]; then
                return 1
            fi
        fi
    fi
    return 0
}

### History
# See 'uber-history' block in ./bashrc
alias h='history'
alias h-file='echo "$HISTFILE"'
alias h-with-times='HISTTIMEFORMAT="%F %T " history'
alias h-recent='h | less +G'
alias h-recent-eternal='less +G "$HIST_ETERNAL_FILE"'
alias h-few='h ${LINES:-40}'
alias h-delete-entry-num='h -d'
alias h-state='set | grep ^HIST ; echo -e "PROMPT_COMMAND:  $PROMPT_COMMAND\nPS1:  $PS1" | col -b | cat -vet'

function h-grep-recent () {
    history | egrep "$@" | tail -n ${LINES:=40}
}
function h-grep-all () {
    history | grep "$@" | less
}
function h-grep-eternal () {
    egrep "$@" "${HIST_ETERNAL_FILE}" | less +G
}
function h-save () {
    h-with-times > $HISTFILE.txt.${1:-save}
}
# TODO: otr still appears in $HISTFILE, but not $HIST_ETERNAL_FILE since no
# next prompt will be displayed (eternal is via PROMPT_COMMAND).
# Perhaps flush to disk, unset HISTFILE, then exec?
alias otr='echo -e "about to exec &\n\tREPLACE\ncurrent shell\nOK? (or ^c): " ; read ; echo -e "May need cleanup: \n\t$HISTFILE" ; H=none exec bash --login'
alias h-panic='vim $HIST_ETERNAL_FILE ; echo -e "see also $HISTFILE\n(afer read & kill...)" ; read ; kill -9 $$'

# The ETERNAL format is already nicely combine-able & sort-able,
# BUT IF you need to merge that with PLAIN DEFAULT bash history,
# first transform it into a minimal common sort-able format.
# BUG: HH:MM:SS != HH-MM-SS
function history-combine-default-into-sortable-summary () {
    HISTTIMEFORMAT="%F %T " history |    \
        perl -p -e 's{(\s)\s*}{$1}g;' |  \
        perl -l -n -e '@a = split(/\s+/, $_); print join(" ", ' \
            -e '$a[2], $a[3], "USER\@HOST", "??=", $a[1], "<?>", @a[4..99]);'
}
# See also: ~/ds/bin/history-annotate-bash.pl 
function history-combine-eternal-into-sortable-summary () {
    perl -l -p -e 'if (m{^[|]4 }) { @a = split(/\s+/, $_); '  \
    -e '$_ = join(" ", $a[1], $a[2], "$a[4]$a[3]", $a[10], $a[12], $a[9], @a[13..999]);}'
}

### Text
alias crlf='perl -pi -e '\''s(\x0d\x0a?|\x0d?\x0a)(\n)g'\'''
alias wordstolines='perl -nae "print join qq(\n), @F;"'
alias sprintf-test='perl -l -e "print sprintf(q{%3.3f}, 1);"'

function checkcrlf () {
    cat -ve "$@" | grep -v '\^M\$$'
}

### CVS
CVS_RSH=ssh
export CVS_RSH
alias cvs-status='cvs-status.pl -n 2>&1 | tee cvs.status'
alias cvs-status-all='cvs-status.pl -nu 2>&1 | sort | tee cvs.status.all'
alias cvs-local="perl -p -e 's{(\t[\-\+\d\.]+).+?$}{$1}' cvs.status.all > cvs.local"
alias cvs-status-local='find . \( -type d -name CVS -prune -false \) -o -type f -newer cvs.status'
alias cvs-nup='cvs -n up 2>&1 | grep -v ignored$'
alias cdiff='cvs diff'
alias conflict-resolve='tkdiff -conflict'

function deconflict () {
    for f in "$@"; do
        tkdiff -conflict "$f" -o "$f"
    done
}
# tkdiff (above) must be a function, not an alias

function release () {
    cvs -Q release -d "$@"
    rm -rf     "$@"
}
function rmup() {
    # TODO: backup file(s) first to *.rmup-$$
    # (but, we still want to do all files in ONE cvs command)
    rm -rf     "$@"   ## do in for
    cvs up -Pd "$@"   ## && rm -r "${@}.rmup-$$"
}
alias cvs-up='cvs update -Pd 2>&1 | tee cvs.update'
alias cvs-rc='less ~/.cvsrc'
function cvs-check-update () {
    grep -v '^[PU] ' cvs.update                  \
        | egrep -vi '^cvs \w+: .+ pertinent$' \
        | grep  -vi '^cvs \w+: Updating '     \
        | egrep -v '^cvs \w+: .+ lock in '    \
        | egrep -v ' is no longer in the repository$'
}
function cvs-check-checkout () {
    grep -v '^U ' "$@"                           \
        | grep  -vi '^cvs server: Updating '     \
        | egrep -v '^cvs server: .+ lock in '
}
function cvs-is-binary () {
    if [ ! -f "$1" ] ; then
        echo "no such file $1" 1>&2
        return
    fi
    cvs stat "$1" | fgrep 'Sticky Options:' | fgrep -- '-kb' >/dev/null
}
alias cvs-convert-root='for c in $(find . -type d -name CVS); do echo "$CVSROOT" > $c/Root; done'

### Perforce
alias pp4=p4
alias p4-client='pp4 client -o | grep -i ^client: | cut -f 2'
alias p4-root='pp4 client -o | grep -i ^root: | cut -f 2'
function  g4-is-active-client () {
    g4 info | grep '^Client root:' > /dev/null
}

### Diff / Patch
diff-file-vs-dir () {
    diff "${1}" "${2}/${1}"
}
alias diff-dirs='diff -Naur'
alias unpatch='patch -R'
function patch-files () {
    grep '^Index: ' "$@" | cut -c 8-
}
# Apparently some newer versions of `diff` have a different idea of what
# the 'unified' format is...
function patch-files2 () {
    egrep '^\+\+\+ .' "$@" | cut -c 5- | cut -f 1
}

### Compile, Make
alias makei='nice make -j 4 idl'
alias makej='nice make -j 4'
alias makeij='makei && makej'
alias clean='make veryclean'

### Java
alias antlr='java antlr.Tool'
alias findj='find . -type d -name CVS -prune -false -o -type f -name "*.java"'
alias findjg='findj | xargs egrep -i'
alias findc='find . -type f \( -name "*.cpp" -o -name "*.h" \) | grep -v CVS/'
alias findcg='find . \( -name "*.cc" -o -name "*.h" \) | grep -v CVS/ xargs egrep -i'
alias rmclass='find . -name "*.class" -type f -exec rm -f {} \;'
function java-files () {
    find . -type f -name "*.java" | cut -c 3- > java.files
}
function jar-contents () {
    rm -f jar.contents
    for f in $(find . -type f -name "*.jar" | cut -c 3-) ; do
        jar -tf "$f" 2>&1 | prefix "$f	" >> jar.contents
    done
}

### Perl
alias cw='find . -name "*.pl" -exec perl -cw {} \;'
alias cw1='find . -name "*.pl" -maxdepth 1 -exec perl -cw {} \;'

## Processses
alias psa='ps -efww'
alias psu='ps -efww -u$LOGNAME'
alias psg='psa | fgrep -v "grep " | egrep -i'
alias psug='psu | fgrep -v "grep " | egrep -i'
alias psugx='psu | fgrep -v "grep " | fgrep -v bash | fgrep -v xterm | egrep -i'
alias killmy='killall -u $LOGNAME'
alias hup='kill -s HUP'
alias toplist='top -b -d 1 999'
#while true ; do ps -efww --forest | fgrep -v " grep" |fgrep -v "ps -efww --forest" > $num.ps; prev=$((num -1 )); if ! diff $prev.ps $num.ps ; then rm $num.ps; <last> ; num=$(($num + 1)); done
alias ps-forest='ps-forest.sh'
alias load-log='wait-for-idle.sh -1'
# TODO(douglasdd): consider ping1.sh which does `tail-cut` to cut off the summary
# statistics (useless when there was only 1), but returns the exit value from
# ping, not from head.  See PIPE_STATUS array in bash
function wait-for-any-host () {
    # WhyTF can I ssh to $q, but not $g from my home network (dd-wrt?)
    # This isn't really helpful becuase both are pingable :-(
    start="$(ddatetime)"
    while true ; do
        for h in "$@" ; do
            ping -c 1 "$h" >/dev/null && echo "$h" && return 0
        done
        echo -n "."
        sleep 2
    done  ## | progress-dots.pl
}

### Users
alias w='w | sort | cut -c 1-80'
alias whos='who -i | cut -c 1-9,17- | sort'
alias wl='w | sort'

### X Windows
alias disp='echo $DISPLAY'
alias disp-none='unset DISPLAY'
function disp-save () {
    echo "$DISPLAY" > ~/tmp/X-"$LOGNAME-$host"-"${1:-save}"
}
function disp-restore () {
    DISPLAY="$(cat ~/tmp/X-"$LOGNAME-$host-${1:-save}")";
    export DISPLAY
}
alias disp-list='ls -lrt ~/tmp/X-"$LOGNAME-$host"* | perl -p -e "s{[^ ]+tmp/X-$LOGNAME-$host-}{** }"'
alias xx='startx >~/logs/startx.log 2>&1 &'
# Nope. instead use `timesrepeat 10 xterm ...`
#alias xt10='for d in 1 2 3 4 5 6 7 8 9 10 ; do ( xterm -geom 80x10 & ) done'
#alias xt5='for d in 1 2 3 4 5 ; do ( xterm & ) done'
alias rgb='less $XDIR/lib/X11/rgb.txt'
#alias rgb='less $XDIR/share/X11/rgb.txt'
alias snap-window='xwd -root -screen | xwdtopnm 2>/dev/null | ppmtojpeg > ~/snapshot-`date +%Y-%m-%dT%H:%M:%S%z`.jpg'
alias xload='xload -hl red -geom 110x60 -name "xload `hostname`" -title "xload `hostname`"'
alias xload-bare='xload -hl red -geom 110x60 -name "xload `hostname`" -title "xload `hostname`" -nolabel'
alias xman='xman -notopbox'
alias xt='xterm &'
# I *think* that `-fb 6x13bold` is inferred from `-fn 6x13`
# If not add it back on the broken machine host_*.sh configs
# NOT specifying it makes it easier to override by only saying `-fn other_font`
# ...BUT leaving it unspecified w/ 6x10 (has no 'bold' version) results in:
#  * V.ugly doubling
# Instead if we leave it mismatched (-fn 6x10 -fb 6x13bold) it looks nice and 10p hight!
# Weird!
xterm_args="-geom 100x40 -fn 6x13 -fb 6x13bold -rw -j -sb -sl 5000 -si -sk -bg lightgray -fg black -cr red"
export xterm_args
alias xterm='xterm $xterm_args'
TERMCMD="xterm $xterm_args"
export TERMCMD
alias xclock='xclock -hl red -update 1'
function xterm-named () {
    xterm $xterm_args -e "name $1 ; $2 2>&1 | tee \"$1\".log" &
}

### Network
alias ip='/sbin/ifconfig $NETWORK_ADAPTER | grep inet'
# ...TODO try that for each item in ordered list of adapters (darwin: networksetup -... to get ordered list)
alias lookupme="perl -e 'use Socket; print gethostbyaddr(inet_aton('\$(ip)'), AF_INET) . qq(\n);'"
function ipof () {
    # TODO: loop for "$@" (since `host` can only handle 1 arg)
    # TODO: what is the portability/POSIXness of `host`?
    host "$1" | perl -n -l -e 'print $1 if m{ has address (.+)$}'
}
alias curl-headers='curl -I'
# See: <ds/doc/wget*.txt>
alias wget-load-cookies='wget --load-cookies="$moz_ff_profile"/cookies.txt'

### Music
alias genres='mp3info -G'
alias mpii='mp3info -r a -p '\''%a\t%l\t%n\t%t\t%g\t%m:%02s \t%.2r kbps\t%Q kHz\t%c\n'\'''
alias mp3-genres='id3v2 --list-genres'
# ... TODO: replace `genres`
# mp3-genres | postfixToWith " " +2 | columns
# Defaults for mp3-rip.sh, mac-rip-cd.sh
# See detailed notes & analysis in ~/ds/doc/mp3-rip.txt
LAME_STEREO="-m j"
LAME_QUALITY="--vbr-new -b 128 -B 320 -q 0 -V 1"
LAME_QUALITY_FRAGMENT="--vbr-new -b 128 -B 320 -q 0"
LAME_FILTER="--lowpass 19.7"
LAME_BACKGROUND="--silent"
# ...TODO: delete LAME_QUALITY (after searching)
# replace with:
LAME_VBR_BASE="--vbr-new -b 128 -B 320 -q 0"
LAME_VBR_QUALITY="-V 0"
function mp3-sample-encode-wav () {
    ## for desktop sounds and pager tones
    file "$1"
    ( set -x
      lame -m m -b 128 --cbr --resample 44.1 ${2:+ -s $2} "$1" "${1%.wav}.mp3"
    )
}

### Print
alias a2ps='a2ps -s 2 --chars-per-line=90 --line-numbers=5'

### Fun
alias yow='/tools/lib/xemacs-21.1.14/i686-pc-linux/yow -f /tools/lib/xemacs/xemacs-packages/etc/yow.lines'

#### Monotone version control
MTN_KEY=
export MTN_KEY
# ...override to '-k user@host' when user has multiple keys
alias mtn='mtn $MTN_KEY'
# ...TODO use bash var substitution instead of forcing all of the overrides
#    to include "-k "

mtn-stat () {
  mtn status
  mtn list missing | prefix '!	'
  mtn list unknown | prefix '?	'
}

cvs-message-annotation () {
  # Include $* in message if it was non-empty

  # Odd, echo -e with \n instead of <NEWLINE> does NOT work here
  # (when used inside other `` commands).

  echo "${*:+"$*
"}user:$user host:$host os:$os ($os_ver3) site:$SITE when:$(ddatetime)"
}

mtn-ci() {
  mtn-stat
  # TODO: ...if that was empty don't bother committing(?)
  # TODO: if $* is empty prompt for message (unless flag?)
  # TODO: loop through $@ splitting into $comment & $files (test -e)
  # TODO: mtn automate approach to this

  mtn ci -m "$(cvs-message-annotation "$@")"
  mtn sync
}

mtn-ci-one-file() {
  file="$1"
  shift;
  # TODO: Neither of these would work (right?):
  #     test -e "$file" || (echo "No such (single) file: '$file'" >&2 ; return 1)
  #     test -e "$file" || (echo "No such (single) file: '$file'" >&2 ; exit 1)
  test -e "$file" || fail "No such (single) file: '$file'"
  test -e "$file" || return 1
  mtn ci -m "$(cvs-message-annotation "$@")" "$file"
}

alias mtn-refresh_inodeprints='mtn refresh_inodeprints'
# TODO: mtn-stop-inodeprints
alias mtn-tip-start-tracking-existing-cvs-project=' echo "cd .../proj/
mtn db init --db ~/work/monotone/proj.mtn
mtn --db ~/work/monotone/proj.mtn --branch com.acme.proj[.feature] setup [.]
mtn add [--recursive] <files|dirs>
#   add [--no-respect-ignore]
mtn ci -m \"Initial commit\"
echo _MTN >> .cvsignore
echo \"RegExpr\" >> .mtn-ignore
echo .*/CVS/.* >> .mtn-ignore
mtn ls unknown
mtn sync --set-default localhost[:(4691|4690|...)] \"branch*\"
"'
alias mtn-tip-new-copy-of-existing-monotone-project=' echo "cd .../parent/
mtn db init --db ~/work/monotone/proj.mtn
ssh -L 4691:internal_host:port user@bastion
mtn --db ~/work/monotone/proj.mtn sync localhost[:(4691|4690|...)] \"com.acme.proj[.feature]*\"
mtn --db ~/work/monotone/proj.mtn ls branches
mtn --db ~/work/monotone/proj.mtn --branch com.acme.proj[.feature] co dir_to_create
"'
alias mtn-tip-branch-new='echo "mtn commit --branch \"...proj.new-sub-branch\" -m \"Purpose\""'
alias mtn-tip-branch-switch-current-workspace='echo "mtn update --revision \"h:...other-branch\""'
mtn-filter-add-already-accounted-for () {
    # pipe `mtn add --recursive dir_we_already_track` into this,
    # so we focus output on new & ignored:
    egrep -v 'already accounted for in workspace$'
}
# See also: `mtn-server-start.sh`
alias mtn-server-stop='kill $(cat ~/log/mtn-serve.pid)'

#### ~/ds management
function ds-arrive () {
  # 2010+ UNUSED. Instead see `ddd-sync`
  ( cd "$HOME"/ds;
    mtn-ci "ds-arrive-pre"  ## don't care if this fails
    mtn sync                ## don't care if this fails
    mtn heads
    mtn merge     \
      && mtn up
    mtn-stat
  )
}
function ds-leave () {
  # 2010+ UNUSED. Instead see `ddd-sync`
  ( pushd "$HOME"/ds
    mtn-ci "ds-leave" ## don't care if this fails
    mtn sync          ## don't care if this fails
    mtn-stat
  )
}
alias ds-list-unknown-site='mtn list unknown | fgrep -v -f ~/ds/cfg/ds-ignore-$SITE.files'

#  506  for d in $(echo "$MTN_ROOTS" | path2lines ) ; do ( cd $d; rwd; mtn $MTN_KEY ci -m "user:$user host:$host os:$os site:$SITE when:$(ddatetime) leave" ; mtn sync; ) ; done
# TODO: check for tunnels (.pid left by synergy-slave.sh)
#### generic leave/arrive that does {ds, work/$SITE, others...}
MTN_WORK_DIRS="$HOME/ds"
export MTN_WORK_DIRS
path_append MTN_WORK_DIRS "$HOME/work/$SITE"
#path_append MTN_WORK_DIRS "$HOME/work/rsk"

# TODO: if [ -n `mtn list unknown` ] ; then
#    abort?  or add to list to report at end
function ddd-sync () {
  for sync_dir in $(echo "$MTN_WORK_DIRS" | path2lines ) ; do
    if [ -d "$sync_dir"/_MTN ] ; then
      ( cd $sync_dir
        echo -e '\n#### ' $(rwd)
        # TODO mtn-all() for this
        mtn-ci ddd-sync
        mtn heads
        mtn merge && mtn up
        mtn-ci "ddd-sync post-merge"
      )
    fi
  done
}
# TODO for d in ~/work/* ; if [ -d $d/_MTN ]

#### work-log
# Keep in site-specific version control
dlog_work="$HOME/work/$SITE/work.log"
function dlog-work() {
  # TODO: Add extra \n if this is a new day
  builtin echo -e "$(hdatetime)" "<$(dirs)>${STY:+" [$STY]"}" "$@" >> "$dlog_work"
}
alias dlog-work-file='echo    "$dlog_work"'
alias dlog-work-tail='tail    "$dlog_work"'
alias dlog-work-less='less +G "$dlog_work"'
alias dlog-work-edit='vim  +  "$dlog_work"'
# TODO: `history` output includes `# trailing comments`.  How can we use this?

#### dlog-host (new name for former host-log)

function dlog-host() {
    builtin echo -e "$(hdatetime), ($(uptime | perl -pe 's{^.* up }{up }'))" \
       "{$(uname -r)} <$PWD>${STY:+" [$STY]"}${TITLE:+" \"$TITLE\""}" "$@" >> "$host_log"
}
alias dlog-host-file='echo "$host_log"'
alias dlog-host-tail='tail "$host_log"'
alias dlog-host-less='less +G "$host_log"'
alias host-log=dlog-host
alias host-log-file=dlog-host-file
alias host-log-tail=dlog-host-tail
alias host-log-less=dlog-host-less

#### todo.txt-cli <todotxt.com>
DROPBOX_DIR="$HOME/Dropbox"
TODO_TXT_CONFIG="$DROPBOX_DIR/todo/config"
alias t='todo.sh -a -d $TODO_TXT_CONFIG'
alias ta='t a'
alias t-dump='t -p ls | sort -n'
alias t-last='t-dump | tail -n $LINES'
alias t-tail='t-dump | tail -n $LINES'
t-file () {
  ( . "$TODO_TXT_CONFIG"; echo "$TODO_FILE" )
}
t-dir () {
  ( . "$TODO_TXT_CONFIG"; echo "$TODO_DIR" )
}
t-env () {
  ( . "$TODO_TXT_CONFIG" ; env | grep ^TODO )
}
alias t-file-ls='ls -l $(t-file)'
t-edit () {
  vim + `t-file`
}
alias t-file-edit=t-edit
t-status () {
  ( . "$TODO_TXT_CONFIG"
    ls -lrt "$TODO_FILE"                \
            "$TODO_DIR"/*conflict* 2>&1 \
        | fgrep -v "*conflict*"
    if ls "$TODO_DIR"/*conflict* >/dev/null 2>&1 ; then
      echo -e "Warning:\n\tConflicts found." >&1
    else
      echo -e "OK:  No conflicts."
    fi
    if psug dropbox >/dev/null ; then
      echo "OK:  Dropbox running."
    else
      echo -e "Error:\n\tNo 'dropbox' process found." >&2
      false
    fi
  )
}
t-backup () {
    if [ ! -r "$TODO_TXT_CONFIG" ] ; then
        echo "No such todo.txt config file: $TODO_TXT_CONFIG" >&2
        return 1
    fi
    cp -Rp $(dirname "$TODO_TXT_CONFIG")/* ~/ds/settings/todo-txt-backup/ \
        && ( cd ~/ds/settings/todo-txt-backup/
             mtn ci -m "todo.txt backup" . )
}
t-diff-from-backup () {
    if [ ! -r "$TODO_TXT_CONFIG" ] ; then
        echo "No such todo.txt config file: $TODO_TXT_CONFIG" >&2
        return 1
    fi
    base="$(basename "$(t-file)")"
    diff ~/ds/settings/todo-txt-backup/"$base" "$(t-file)"
}
alias t-xterm='xterm $xterm_args -fn 6x10 -geom 100x100 -ls -e "todo.sh -a -d $TODO_TXT_CONFIG listpri ; exec bash" &'

# Not sure if this is a good idea, or not, best to keep everything in 1 place, right?
WORK_TODO_TXT_CONFIG="$HOME/work/$SITE/todo/config"
alias wk='todo.sh -a -d ~/work/$SITE/todo/config'
wk-file () {
  ( . "$WORK_TODO_TXT_CONFIG"; echo "$TODO_FILE" )
}
wk-file-edit () {
  vim + `wk-file`
}

#### Bookmark Management
# WARN: Obsolete. Chrom(e|ium) w/ bookmark-sync rocks!
# WARN: Firefox3.0+ uses a totaly new SQLite/JSON version
#       that makes all this crud obsolete.
# NOTE: Google Browser sync obsoletes all of this (yay!)
#       BUT it is being end-of-life'ed -- dammit!!
# NOTE: host/user -specific files must define $bkmk_moz, $bkmk_ff
# BUG: when copying the FireFox bookmarks to  Mozilla, the toolbar-ness of the
#      'toolbar folder' is lost
# TODO: perl script to convert bookmarks.html to Bookmarks.plist
# TODO: support Konqueror (SuSE default: no Netscape or Mozilla) (.xbel?)
bkmk_moz=
bkmk_ff=
bkmk_konq=
export bkmk_moz bkmk_ff bkmk_konq
# New-Style
moz_ff_profile=
moz_profile=
export moz_ff_profile moz_profile
# Recover from stale NFS files on reboot
alias moz-ff-unlock-profile='rm -i "$moz_ff_profile"/.parentlock "$moz_ff_profile"/lock'
bkmk-install () {
  if [ -z "${bkmk_ff}${bkmk_moz}" ] ; then
    echo "no bkmks declared for this host/user" >&2
    return
  fi
  running="$(psug -i mozilla)$(psug -i firefox)"
  if [ ! -z "$running" ] ; then
    echo -e "browsers still running:\n${running}\n" >&2
    return 2
  fi

  if [ ! -z "$bkmk_ff" -a -f "$bkmk_ff" ] ; then
    bookmark-install-helper "ff" "$bkmk_ff"
  fi
  if [ ! -z "$bkmk_moz" -a -f "$bkmk_moz" ] ; then
    bookmark-install-helper "moz" "$bkmk_moz"
  fi
}
bookmark-install-helper() {
  app="$1"
  dest="$2"
  now="$(ddatetime)"
  backup="$HOME"/backup/bookmarks-$app-$now.html
  echo "$app: $dest"
  cp -p "$dest" "$backup"
  cp -p "$HOME"/ds/settings/bookmarks.html "$dest"
}
bkmk-copy () {
  ## Note disparity between copy and install bookmark operations
  # copy only respects ff (no automatable way to determine which to respect)
  if [ -z "${bkmk_ff}" ] ; then
    echo "\$bkmk_ff not defined for this host" >&2
    return 1
  fi
  echo  "$bkmk_ff"
  cp -p "$bkmk_ff" "$HOME"/ds/settings/bookmarks.html
}

### DTX, Documentation
alias confluent-toc='perl -ne '\''print if s{^h(\d)\.\s+}{"  " x $1}ei;'\'''
function dtx-publish-if-newer () {
    src="$1"
    dest="$2"
    if [ \( ! -f "$dest" \) -o \( "$src" -nt "$dest" \) ] ; then
        echo "$src" \> "$dest"
        dtx-filter.pl < "$src" > "$dest"
        chmod a+r "$dest"
    fi
}
# TODO: if on windows(cygwin) chmod +x "$dest"
#       ... or even better add if(cygwin) logic into xhtml

function tt () {
    return 0
}

function ff () {
    return 1
}

kerberos-refresh () {
    # Fancified version of: klist || kinit  OR  kinit -R || kinit
    echo -n "kerberos renew:  "
    kinit -R && echo "OK" || (
        echo -n "kerberos login:  "
        kinit
    )
}
use_kerberos=""
alias kerveros-you-know-what-i-meant=kerberos-refresh 

ping-log () {
  # BUG: If `-c <NUM>` is in $* you're screwed, so:
  # TODO: Re-do this as a shell script with getopt allowing -c --> $n
  n=10
  while true ; do
    ( ( ping -c $n "$@" | cgrep.pl -f 2 'ping statistics' | head-cut.pl -n 1
            exit ${PIPESTATUS[0]} \
      ) || sleep 10
      ## append each time, not outside the while loop, so that others can
      ## `echo ... >> ping.log` so as to inter-mix output into the log file.
    ) 2>&1 | prefix "$(ddatetime)$TAB" >> ping.log
    ## >> append
    sleep 1
  done
}

ping-log-to-tab-filter () {
    perl -n -e 'print "\n$1\t$2\t" if m{^([0-9_-]+).*?(\d+(?:[.]\d+))%}; print join("\t", m{([0-9.]+)(?:/| ms)}g );'
}

# ...TODO: ddate[time]-to-spreadsheet-compatible-format-filter() {...}

#### SSH
# See ./ssh-agent.sh and `ssh-env-check.sh`
alias ssh-auto-accept-remote-host-key-tip='echo ssh -o "StrictHostKeyChecking=no" ...'
# ^ vs v ??
alias ssh-lax='ssh -o StrictHostKeyChecking=false'
alias ssh-tunnel-tip='echo ssh[.sh] [-Y] -L HERE_PORT:inside_host:inside_port user@SSH_BASTION_HOST'
alias ssh-add-list='ssh-add -l'
alias ssh-add-delete-all='ssh-add -D'
alias ssh-add-delete-dflt-or-one='ssh-add -d'
alias ssh-add-all-ids='ssh-add $(/bin/ls "$HOME"/.ssh/id_* | egrep -v "\.pub$")'
alias sshow='psg "ssh "'
alias ssh-env-echo=ssh_env_echo
alias pave-private-file=pave_private_file

# Generates same signature from both .pub and private keys of a keypair
alias ssh-key-fingerprint='ssh-keygen -l -f'

function ssh-key-fingerprints () {
  for f in ${@:-/etc/ssh/*.pub /etc/ssh*.pub "$HOME"/.ssh/*.pub} ; do
    # BEWARE: Error text is sent to STDOUT from ssh-keygen
    # BEWARE: Some versions of ssh-keygen include the host name, so
    # output format is NOT uniform accross platforms
    test -r "$f" || continue
    fingerprint_and_type=$(ssh-keygen -l -f "$f")
    if [ $? == 0 ] ; then 
      echo -e "${f}\t${fingerprint_and_type}"
    fi
  done
}
# See format warning above
alias ssh-key-fingerprints-save='ssh-key-fingerprints | prefix "$host$TAB" >> "$HOME"/ds/settings/fingerprints-ssh.txt'
fingerprints-check-ssh () { 
    egrep "$@" "$HOME"/ds/settings/fingerprints-ssh.txt
}

function ssh-forever () {
    user_at_host="$1"
    shift
    flags="$@"
    host=${user_at_host##*@}
    while true ; do
        before=$(date "+%s")
        wait-for-host.sh $host  ## NOTE always returns immediately for localhost,
        # ... even if we request -p port_num that is NOT yet ssh-port-forwarded.
        ssh ${flags} $user_at_host
        after=$(date "+%s")
        let "elapsed = $after - $before"
        # Don't inserting sleep unless we are spinning quickly:
        if [ $elapsed -lt 2 ] ; then
            # ...most common when $host==localhost, but the port is NOT ssh-forwarded,
            # so wait-for-host
            sleep 2
        fi
    done
}

function _dtunnel-home-once() {
  target="${1}"
  shift
  title "XXX-TTT-..."
  name "XXX-TTT-..."
  echo -e "\ttitle \"TTT ${SITE}/${host} ->\""
  # From EXternal: -p 44 -> tiny
  # From EXternal: -p 66 -> rowan
  # From INternal:  [22] -> tiny
  # TODO: EXT :22 -> rowan *AFTER* it's the 24/7 server
  time (
      set -x
       ssh                           \
           -Y                        \
           -L 4690:$t:4691           \
           -L 5920:$t:5900           \
           -L 5921:$t:5901           \
           -L 4699:$r:4691           \
           -L 5911:$r:5901           \
           -L 2200:$r:22             \
           -L 5919:$a:5900           \
           -o ConnectTimeout=10      \
           "$@"                      \
           ddd@$target
  ) ; ddatetime
}
#           -L 5910:$q:5900           \
#           -L 5911:$q:5901           \
#           -L 5912:$q:5902           \
#           -L 5913:$q:5903           \
#           -L 5914:$q:5904           \

dtunnel-home () {
  # TODO this does not update XTerm title between connections.
  # (consider echoing PS1 or running PROMPT_CMD?  Yuck! Maybe use TITLE directly?)
  name "XXX-TTT-..."
  title "XXX-TTT-..."
  while true ; do
   # TODO: adde $elapsed check from `ssh-forever`
    wait-for-host.sh "$g"            ## ping-able from both    Internal and External
    if ifconfig | fgrep 'inet 10.142.242.' >/dev/null ; then
        _dtunnel-home-once "$t" "$@"  ## reachable only from    Internal
    fi
    ## Always try external addr, we might be somewhere that only looks internal
    ## Hostname reverse resolution check can make $g un-ssh'able from internal
    _dtunnel-home-once "$g" "$@" 
    ## Try both the usual port-forwarded hosts
    _dtunnel-home-once "$g" -p 44 "$@"
  done
}

ssh-known-hosts-remove () {
    # TODO: Run in sub shell w/ ( set -o errexit ; cd ~ ; .... )
    # TODO: consider version that reports what entries were removed.
    # TODO: consider version that refreshes w/ `ssh u@h "echo ok."`
    pattern="$1"
    orig="$HOME/.ssh/known_hosts"
    back="$HOME/.ssh/known_hosts.bak-$(ddatetime)"
    cp -p "$orig" "$back"
    echo "was: $(wc -l "$back")"
    egrep -v "$pattern" "$back" > ~/.ssh/known_hosts
    echo "now: $(wc -l ~/.ssh/known_hosts)"
}
ssh-xload () { 
    ssh -Yf2 "$@" 'xload -hl red -geom 110x60 -name "xload `hostname`" -title "xload `hostname`"'
}
alias kssh='killmy ssh'

#############################################################################
#### To-be-Filed

alias password-gen-tip='builtin echo -e "man apg\n\tapg -m 10 -M LNS -t"'
alias narrow='cut -c 1-79'
alias prog='progress-dots.pl -n 20'

alias start='open'
# TODO: xdg-open instead of `open` or `gnome-open` (& move to Linux?)
function open-all () {
  ## Linux `open` is dumb and can only handle one at a time
  for f in "$@" ; do
    gnome-open "$f";
  done
}
alias xhtml='chmod +x *.html'
alias xhtml-r='find . -type f -name "*.html" -print0 | xargs -0 chmod +x'

alias tkcvs-tree='tkcvs -log'
# hex-to-ascii $ for n in  63 00 6d 00 64 00 20 00 2f 00 6b 00 00 ; do
# if [ "$n" != "00" ] ; then perl -e "print chr 0x$n;"; fi ; done

#  1019  unzip-t foo.zip | perl -ne 'if (m{^\s*testing:\s*(.+?)[^\/]\s+OK\s*$}) {print "$1\n";}'

#  1020  unzip-t config-upload-dev-localunix-2007-01-10.zip | perl -ne 'if (m{^\s*testing:\s*(.+?[^\/])\s+OK\s*$}) {print "$1\n";}'

alias limits='ulimit -a'
alias limits-kernel='sudo sysctl -a'
#...modify on SuSE LES 9.x: /etc/sysctl.conf (or /etc/sysconfig/sysctl??)
#kernel.sem=250	32000	100	128

alias svn-last-rev='svn info file:///svn | grep '\''^Last Changed Rev:'\'' | cut -d : -f 2- | trim-whitespace.pl'
alias svn-diff-no-ws='svn diff --diff-cmd ~/ds/bin/diff-no-ws.sh'
#...looses exit value fm diff, so you cannot use it in an `if` :-P
alias svn-stat='svn status -u | tee cvn.stat'
alias svn-stat-all='svn status -uv | tee svn.stat.all'

alias netstat-an='netstat -a -n|less'
alias netstat-ports='netstat -tulanp'
alias ip='ifconfig | egrep "(^[^ 	])|inet[^6]"'
alias ip2host='dig -x'

# Add comments to the ongoing bash history log file
alias ok=':'
alias bad=':'

alias g4-changes='g4 changes -u $LOGNAME -l -m 100'

alias mkisofs-tip='echo mkisofs -dvd-video  -udf  -V VOL_NAME  -o DISK_IMG_FILE.img src_fldr'
alias 3gp-to-ffmpeg='ffmpeg -i data-2012-4-26-18-06-31.3gp data-2012-4-26-18-06-31.mp3'
alias screen-cast-desktop='ffmpeg -f x11grab -s 800x600 -r 25 -i :0.0 -sameq'

alias mv-to-target-all='mv --target-directory'
# ...sorry, only gnu mv (not mac)
alias mtu-discovery='ping -c 2 -D  -s 1500 www.apple.com'

alias chown-hint='echo chown -R user[:group]'
alias less-bail-on-1-screen='less -F'
alias number-lines='nl -b a'
alias curl-headers='curl -o - -k -I -s'
alias curl-head='curl -o - -k -I -s'

# TODO: Dammit `env -u` is not portable (not on mac 10.6! ?only gnu/linux?)
# TODO: work-around in many places in ~/ds/env/: `STY= TITLE= ...`
alias screen-free='env -u STY -u TITLE'
alias screen-free-tip='echo -e "LINUX: \`env -u STY -u TITLE ...\`\nOTHERS: \`STY= TITLE= ...\`"'

alias xbindkeys-from-screen='screen-free xbindkeys'
alias xkeybindings-tip='echo -e "Did you mean:\n\txbindkeys\n?"'

alias who-else='who | grep -v $LOGNAME'

alias snip='tail -n $((2 * ${LINES:-40})) | cut -c 1-$((10 + 2 * ${COLUMNS:-80}))'
alias brief=snip
backup-new-over-old () {
    for f in *.new ; do
        cp -p $f ${f/%.new/.old};
    done
}
flags-to-newlines () {
    perl -p -e 's{\s+([-]+)}{\n$1}g'
}
alias argv-filter='perl -pe '\''s< ([-]{1,})><\n$1>g'\'''
alias nfs-tab-complete-check='for d in $(path) ; do if [ -d $d ] ; then ( cd $d ; df . ); fi ; done'

alias xbindkeys='env -u STY -u TITLE xbindkeys'
alias chrome='/opt/google/chrome/google-chrome ----user-data-dir=$HOME/.config/host/$host/google-chrome --proxy-pac-url="http://proxyconfig.corp.google.com/wpad.dat" > $HOME/log/chrome.log 2>&1 &'
alias chrome='/opt/google/chrome/google-chrome ----user-data-dir=$HOME/.config/host/$host/google-chrome > $HOME/log/chromium.log 2>&1 &'

replace-file () {
    ( test -f "$1" || die "Not a normal file: $1"
      set -x
      mv "$1" "$1".orig            \
          && cp -p "$1".orig "$1"  \
          && diff "$1".orig "$1"   \
          && rm "$1".orig )
}
alias nfs-unlock=replace-file

function tkdiff-all-old-new () {
    for f in *.new; do
        tkdiff ${f%.new}.old $f &
    done
}
function ls-up-to-root () {
    # BUG: does not check that arg is an ABSOLUTE path
    # TODO: accept multiple args
    local d="$1";
    local dev=`stat -c "%D" "$d"`
    while [ "${#d}" -ge 1 ]; do
        local dev2=`stat -c "%D" "$d"`
        if [ "$dev" != "$dev2" ] ; then
            echo "# crossed to device: $dev2"
            dev="$dev2"
        fi
        /bin/ls -ld "$d";
        if [ "$d" == "/" ] ; then
            break
        fi
        d=$(dirname $d);
    done
}
alias mysql-load-from-file='mysql5 -u root -p --local-infile -e "load data local infile '\''saw.data'\'' into table tbl_name" db_name'
alias dmesg-tail-f='sudo true && while true ; do ( ddatetime ; sudo dmesg -c ) | tee -a dmesg.log ; sleep 10 ; done'
alias cat-veT='cat -veT'
alias routing-table='netstat -rn'
alias sudo-preserve-environment='sudo -E'

function generate-variable-set () {
    var=$1  # No "" on purpose!
    # TODO: check no more args
    echo -n $var='"'
    eval 'echo -n $'$var
    echo '"'
}
alias fix-env='. ~/FIX.env'
function fix-env-add () {
  for v in $* ; do
    generate-variable-set $v >> ~/FIX.env
  done
}
alias time_t='epoch-sec-now.sh'

id3-images-to-dir () { 
    dir="$1";
    shift;
    for f in "$@"; do
        eyeD3 -i "$dir" --no-color "$f";
    done
}
id3v2-album () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TALB [^:]+:\s+(.*));';
    done
}
id3v2-performer-band () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TPE2 [^:]+:\s+(.*));';
    done
}
id3v2-performer-composer () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TCOM [^:]+:\s+(.*));';
    done
}
id3v2-performer-lead () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TPE1 [^:]+:\s+(.*));';
    done
}
id3v2-title () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TIT2 [^:]+:\s+(.*));';
    done
}
id3v2-year () { 
    for f in "$@"; do
        id3v2 -l "$f" | perl -n -l -e 'print $1 if m(^TYER [^:]+:\s+(.*));';
    done
}
alias shopt-set='shopt -s'
alias shopt-unset='shopt -u'
alias shopt-list='shopt'
# apt is not just for Linux, it also appears in Mac with Fink
alias dpkg-list-installed='dpkg -l'
alias apt-get-list-installed-tip='echo dpg -l'
# mtn-attr-drop-bulk () {   for f in "$@" ; do     mtn attr drop "$f" "$1";   done; }
localtime-filter () {
    perl -nl -e 'print scalar localtime $_;'
}
# Note `VAR=value cmd` DOES still evaluate cmd for aliases.
alias xt-large='( cd ; STY= TITLE= xterm -geom 100x75 &)'
alias xt-100=xt-large

alias env-dump='env | sort'
alias mtn-ssh_agent_add='mtn ssh_agent_add'

sum-by-column-1 () {
    perl -l -n -a -F/\\t/ -e 'END { while (($k, $v) = each %p) { print "$k\t$v"; } } $p{$F[0]} += $F[1];'
}
cut-reorder-2-1 () {
    # TODO: generalize this into cut.pl -f 3,1 (normal `cut` has to be
    # monotonically increasing field numbers, it cannot re-order them).
    perl -a -F/\\t/ -l -p -e '$_= join("\t", $F[1], $F[0]);'
}

count-fields () {
    perl -n -e '@m = m{\t}g; printf("%d\n", 1 + scalar(@m))'
}

alias dialog-gtk='zenity'

alias caps-lock-to-control-reset='setxkbmap -option ""'
alias caps-lock-to-control-swap='setxkbmap -option "ctrl:swapcaps"'
# Normal case:
alias caps-lock-to-control='setxkbmap -option "ctrl:nocaps"'
alias CAPS-LOCK-TO-CONTROL='echo -e -n "First turn *OFF* caps-lock,\n\tthen [Enter]..."; read; caps-lock-to-control'

alias dhcp-network-interface-down-up='( set -x ; sudo ifdown eth0 && sudo ifup eth0 && sudo /etc/init.d/network restart )'
alias dhcp-networking-all='( set -x ; /etc/init.d/networking restart )'
alias calc='bc -l'
alias mount-formatted='mount | column -t'

mtn-attr-set () { 
    if [ "$#" -lt 3 ]; then
        echo -e "Usage:\n\t mtn-attr-set NAME VALUE file1 file1 ..." 1>&2
        return 1
    fi
    attr_name="$1"; attr_value="$2"; shift 2
    for f in "$@"; do
        mtn $MTN_KEY attr set "$f" "$attr_name" "$attr_value";
    done
}
mtn-chmod-plus-x () {
    mtn-attr-set 'mtn:execute' 'true' "$@"
}
alias flv-to-gif-animation-tip='echo "avconv -1 INPUT_FILE -r 5 -pix_fmt rgb24 OUTPUT.gif"'
alias db='dropbox.py'
alias dhcp-release+renew='sudo dhclient -r && sudo dhclient'
alias xresize='eval `resize`'
alias scr-hostname='scr $host'
alias tcp-test=nuttcp
alias tcp-http-ping=hping3
journal () { 
    echo -e "\n#### $(ddatetime)" >> ~/ds/settings/journal.txt;
    vi + ~/ds/settings/journal.txt
}
alias dev-random-entropy-available='cat /proc/sys/kernel/random/entropy_avail'
alias mount-tip-cd-iso='echo "sudo mount -o loop [-t msdos] ~/work/SpinRite/FreeDos_1.1.iso /media/freedos_1.1_iso/"'
ssh_noStrictHostKeyChecking="-o StrictHostKeyChecking=no"
alias mtn-tip-branch-get-changes-from-mainline='echo "mtn propagate ...proj.main ...proj.this-branch"'
alias mtn-tip-branch-send-changes-back-to-mainline='echo "mtn propagate ...proj.this-branch ...proj.main"'
alias mount-tip-nfs='echo "mount -t nfs -o user,rw,rsize=8192,wsize=8192 moria:/opt/ddd-data /opt/ddd-data"'
alias ddrescue-tip='echo "sudo ddrescue --no-split      -v --sparse --cluster-size=128 /dev/source drive.img drive.state-log
sudo ddrescue --max-retries=3 -v --sparse --cluster-size=128 /dev/source drive.img drive.state-log"'
alias smartd-force-check-now='sudo killall -s USR1 smartd'
alias hdparm-status-check='hdparm -C'
alias hdparm-force-standby='hdparm -y'
alias hdparm-force-sleep='hdparm -Y'
alias gst='git status'
alias gb='git branch'
alias ln-replace-symlink-to-dir='ln -shfFv'
