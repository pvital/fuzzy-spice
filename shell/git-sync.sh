#!/bin/bash
#
# Copyright (c) 2015 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script synchronizes a fork repository with it's upstream or source.
# It assumes the fork repository was cloned locally as 'origin' and an 
# additional remote to source repository was added as 'upstream'. Also all sync
# will happen on top of local 'master' branch and pushed to 'origin/master'.

# Checkout (move) to local master branch
git checkout master > /dev/null 2>&1
[ ${?} -ne 0 ] && { echo -e "Error while checking out master branch."; exit 1; }

# Check if there's a remote called 'upstream'
RES=$(git remote | grep -w upstream | wc -l)
[ ${RES} -ne 1 ] && { echo -e "There is no remote named 'upstream'."; exit 1; }

# Fetch from upstream remote
git fetch upstream > /dev/null 2>&1
[ ${?} -ne 0 ] && { echo -e "Could not fetch from upstream remote."; exit 1; }

REBASED="Fast-forwarded master to upstream/master."
UP2DATE="Current branch master is up to date."
TEMP=$(mktemp)

# Rebase local master with updates from 'upstream/master'
git rebase upstream/master > ${TEMP}

# Check if rebase was executed and see if there're updates or not.
grep "${REBASED}" ${TEMP} > /dev/null 2>&1
if [ ${?} -ne 0 ]; then
    grep "${UP2DATE}" ${TEMP} > /dev/null 2>&1
    if [ ${?} -ne 0 ]; then
        echo -e "Could not fetch from upstream remote."
        exit 1
    else
        echo -e "${UP2DATE} Nothing to do."
        exit 0
    fi
fi

# Push to 'origin/master'
echo -e "Pushing updates to origin/master."
git push origin master > /dev/null 2>&1
[ ${?} -ne 0 ] && { echo -e "Could not push updates to origin/master."; exit 1;}

# Updated! 
echo -e "origin/master is up to date."
exit 0
