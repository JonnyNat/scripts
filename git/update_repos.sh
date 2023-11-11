#!/bin/bash

#
# Runs the "git pull" command on each git repository in a directory.
# The execution directory is the directory in which the script is launched.
# 
# With the argument "--ssh" (abbreviated "-s") the user's private key (private_key) is added 
# to the ssh-agent, for connecting to git via ssh.
# 
# With the argument "--fetch" (abbreviated "-f") "git fetch" is executed instead of "git pull".
#

private_key="$HOME/.ssh/id_ed25519"

git_command=pull
git_repos=0
successful_updates=0

for arg in $@
do
    case $arg in
        --ssh | -s)
		    eval $(ssh-agent -s)
            ssh-add $private_key
            ;;
        --fetch | -f)
            git_command=fetch
            ;;
        *)
            script_name=$(basename $0)
            echo "$script_name: unknown option $arg"
            echo "Usage: $script_name [-s | --ssh] [-f | --fetch]"
            exit 1
            ;;
    esac
done

for dir in $(ls -d */ | cut -f1 -d'/')
do
    cd $dir

    if [[ -d ".git" ]]
    then
        git_repos=$(($git_repos + 1))
        printf "\n>>> updating ($git_command) $dir\n"
        git $git_command && successful_updates=$(($successful_updates + 1))
    else
        printf "\n>>> $dir is not a git repository!\n"
    fi
    
    sleep 1
    cd ..
done

printf "\n>>> $successful_updates out of $git_repos git repos updated!\n"