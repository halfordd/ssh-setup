#!/bin/bash

# DETERMINE PLATFORM

platform=`uname`

if [[ $platform == "Darwin" ]]; then
    echo "You appear to be using a Mac."
else
    echo "Your platform appeas to be ${platform}."
fi

# DETERMINE USERNAME

echo
username=`whoami`

echo "Your username appers to be ${username} ."
echo

# DETERMINE HOME DIRECTORY
# (This is where things might start getting strange)

echo "Your Home Directory appears to be ${HOME} ."
echo
if [[ -d ${HOME}/.ssh ]]; then
    echo "You have a SSH folder in your home directory."
    echo
    echo "The following public keys exist in this folder:"
    echo
    ls ${HOME}/.ssh/*pub
    echo
    echo "Please make sure that you do NOT use the key names above for new keys."
    echo
else
    echo "You do NOT have a SSH folder in your home directory."
fi

# PERMISSION CHECK

echo
echo "Testing if your SSH directory is accessible."
echo "This can fail if your home directory is on a network to which you are not directly connected."

# Implement permission check

echo
echo "Testing that I can find ssh-keygen."
if  command -v ssh-keygen $> /dev/null ; then
    echo "SUCCESS"
else
    echo "FAILED. ssh-keygen is not on your path. Install SSH or fix your PATH and retry."
    exit 1
fi

echo "Creating key"