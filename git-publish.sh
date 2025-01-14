#!/bin/bash 
DIR="${1:-$PWD}" 

function maye_rebase {
    if [[ $1 == 'pull' ]] 
    then
        git pull --rebase || fail "Please resolve conflicts before continuing." 
    fi

    if [[ $1 == 'rebase' ]] 
    then
        rebase
    fi
}

function rebase {
    # if jungle is available and we can assume fetches were already done by just and so we rebase, otherwise we rebase pull
    command -v jungle && git rebase || git pull --rebase || fail "Please resolve conflicts before continuing." 
}

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}


echo "Checking ($2) for changes in $DIR"

cd $DIR

git config core.fileMode false

# add all changes (including untracked files)
git add --all .

set +e  # Grep succeeds with nonzero exit codes to show results.

if LC_ALL=en_GB git status | grep -q -E 'Changes|modified|ahead'
then
    set -e

    # if there are changes, commit them (needed before being able to rebase)
    git diff-index --quiet HEAD || git commit --verbose --all || echo Skipped...

    # if [[ $2 == 'pull' ]] 
    # then
    #     git fetch
    # fi

    # merge/rebase local changes
    maye_rebase $2

    if [[ $3 != 'only' ]] 
    then
        git push && echo "Published changes!" 
    fi

else
    set -e
    echo "No local changes to push"

    maye_rebase $2
fi
