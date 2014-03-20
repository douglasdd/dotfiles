#!/bin/sh

# Check Environment variable to see if ssh-agent is correctly configured and
# running.
#
# Call with any command-line argument to work *SILENTLY* (only report via
# exit value).
#
# Verified on both Linux and MacOSX with 10.4+ special `launchd` integration.
#
# See also: ~/ds/env/ssh-agent.sh that is sourced as part of shell env config.

# TODO: 
# * Verify most portable args for /bin/ps

verbose=true
test -n "$*" && verbose=false
sock_ok=false
pid_ok=false
if "$verbose" ; then
    env | egrep '^SSH_A(UTH_SOCK|GENT_PID)' | sort -r
fi

if [ -n "$SSH_AUTH_SOCK" ] ; then
    if [ -r "$SSH_AUTH_SOCK" ] ; then
        sock_ok=true
        "$verbose" && echo "sock OK, ls: $(/bin/ls -alF "$SSH_AUTH_SOCK")"
    else
        "$verbose" && echo "sock BAD" >&2
    fi
else
    "$verbose" && echo "sock UNSET"
fi

if test -n "$SSH_AGENT_PID" ; then
    if /bin/ps -p "$SSH_AGENT_PID" 2>/dev/null | egrep '( |/)ssh-agent( |$)' >/dev/null 2>&1 ; then
        # ... `ps -h` or `--no-headers` is not universal
        pid_ok=true
        "$verbose" && echo "proc OK, ps: $(/bin/ps -fww -p "$SSH_AGENT_PID" 2>/dev/null \
                                            | perl -n -e 'print if $n++')"
    else
        "$verbose" && echo "proc BAD" >&2
    fi
else
    "$verbose" && echo "proc UNSET"
fi

# ps 2>/dev/null need to work around weird Mac bug suddenly appeared where
# suid binaries (ps, etc.) complains if LD_LIBRARY_PATH or DYLD* is set:
#     dyld: DYLD_ environment variables being ignored because main executable
#     (/...) is setuid or setgid
agent_ps="$(ps -u $LOGNAME -ww -o pid,start,args  2>/dev/null \
                | egrep '( |/)ssh-agent( |$)' | grep -v grep)"
num_agents="$(echo "$agent_ps" | wc -l)"
if [ $num_agents -gt 1 ] ; then
    "$verbose" && echo '
WARNING: You have multiple `ssh-agent`s running:
'"$agent_ps"
fi

if "$sock_ok" || "$pid_ok" ; then
    "$verbose" && echo "OK"
    "$verbose" && ssh-add -l | perl -p -e 'print "    ";' # list
    exit 0
else
    "$verbose" && echo "FAILED" >&2
    exit 1
fi
