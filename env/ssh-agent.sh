# Configure ssh-agent

# BUG: On Ubuntu /bin/sh --> /bin/dash and that doesn't understand functions, so:
#    0 $ scp dl/win98boot.zip ddd@$r:dl/
#    /home/ddd/ds/env/ssh-agent.sh: line 76: ssh-env-backup: command not found
#    win98boot.zip                            100%  669KB 669.4KB/s   00:00    

# Needs to be in basic Bourne shell dialect, since xinitrc may use dumb shell.
# Also should not assume ~/ds/env/ setup (f/ex sourced from xinit/.xprofile).

# Does the right thingn on Mac OS X where launchd creates _SOCK at start,
# but only launches the `ssh-agent` process on-demand (upon socket read).
# That instance from launchd is better integrated w/ Aqua and Keychain!
# TODO: Found in 10.5+, but did this behavior start further back in 10.4?

# Does the right thing on Linux regardless of what order you login from 
# various sources (a) ssh, (b) console (c) X-console
# IF  ~/.xprofile contains:
#    dssh="$HOME"/ds/env/ssh-agent.sh
#    test -r "$dssh" && . "$dssh"

# TODO: check ~/g/bin/ssx-agents (now that it is ssh-only) to see how (if?)
# it does the right thing.

#### Config
: ${host:=$(uname -n | cut -d . -f 1 | tr '[:upper:]' '[:lower:]')}
ssh_agent_config="${HOME}/.ssh-agent-${host}"
export ssh_agent_config

if test -z "${host}" ; then
    host="`uname -n | cut -d . -f 1 | tr '[:upper:]' '[:lower:]'`"
fi

if ! type -a ssh-env-check.sh > /dev/null 2>&1 ; then
    PATH="$PATH:$HOME/ds/bin"
fi

#### Helpers (for use in this script AND for interactive shells too)
alias ssh-env-restore='. "${ssh_agent_config}"'
alias ssh-env-backup='cp -a "${ssh_agent_config}" "${ssh_agent_config}".bak.`date "+%Y-%m-%d_%H-%M-%S"` 2>/dev/null'
alias ssh-env-unset='unset SSH_AUTH_SOCK ; unset SSH_AGENT_PID'

ssh_env_echo () {
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK
test -n \"\$SSH_AUTH_SOCK\"  && export SSH_AUTH_SOCK
test -n \"\$SSH_AUTH_SOCK\"  || unset  SSH_AUTH_SOCK
SSH_AGENT_PID=$SSH_AGENT_PID
test -n \"\$SSH_AGENT_PID\"  && export SSH_AGENT_PID
test -n \"\$SSH_AGENT_PID\"  || unset  SSH_AGENT_PID"
}

pave_private_file () {
    file_name="$1"
    saved_umask=$(umask)
    umask 0077
    > "${file_name}"
    umask $saved_umask
    # then apend (>>) to the file to keep the permissions
}

alias ssh-env-save-current='ssh-env-backup ; pave_private_file "${ssh_agent_config}" ; ssh_env_echo >> "${ssh_agent_config}" ; ls -l "${ssh_agent_config}"*'

#### Main
if ssh-env-check.sh quiet ; then
    # Current ENV is valid, keep it, and ensure it is saved

    tmp_file="${ssh_agent_config}.$$"
    pave_private_file "$tmp_file"
    ssh_env_echo   >> "$tmp_file"
    if diff           "$tmp_file" "${ssh_agent_config}" >/dev/null 2>&1 ; then
        # same, keep existing
        rm -f "$tmp_file"
    else
        # different, keep new one
        mv -f "$tmp_file" "${ssh_agent_config}"
    fi
else
    # Current ENV is NOT valid, load the existing config (which might be valid)
    . "${ssh_agent_config}" 2>/dev/null

    if ! ssh-env-check.sh quiet ; then
        # Loaded config is NOT valid, start a new one, and save the config.
        ssh-env-backup
        pave_private_file "${ssh_agent_config}"
        ssh-agent -s | grep -v "^echo " >> "${ssh_agent_config}"
        . "${ssh_agent_config}" 2>/dev/null
    fi
fi
