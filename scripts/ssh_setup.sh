#!/bin/bash

# DETERMINE PLATFORM

platform=`uname`

if [[ $platform == "Darwin" ]]; then
    echo "You appear to be using a Mac."
elif [[ ${platform:0:7} == "MINGW64" ]]; then
    echo "You appear to be running bash on Windows, perhaps with Git-bash."
    platform="${platform:0:7}"
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
    echo Attempting to create a SSH folder for you:
    if mkdir ${HOME}/.ssh; then
        echo "SUCCESS"
    else
        echo "FAILED: Could not create folder ${HOME}/.ssh  Please call a helper."
        exit
    fi
fi

# PERMISSION CHECK

echo
echo "Testing if your SSH directory is accessible."
echo "This can fail if your home directory is on a network to which you are not directly connected."
echo

if touch ${HOME}/.ssh/iamatestfile123; then
    echo "SUCCESS"
    rm ${HOME}/.ssh/iamatestfile123
else
    echo "FAILED: Your SSH folder is not writable. Please call a session helper."
    exit
fi

# Implement permission check

echo
echo "Testing that I can find ssh-keygen."
if  command -v ssh-keygen $> /dev/null ; then
    echo "SUCCESS"
else
    echo "FAILED. ssh-keygen is not on your path. Install SSH or fix your PATH and retry."
    exit 1
fi

echo "Creating key:"

keyname="`date +%g%m`-SCW-key"

while [[ -e ${HOME}/.ssh/${keyname} ]]; do
    keyname="${keyname}a"
done

if ssh-keygen -f ${HOME}/.ssh/${keyname} -N "" -t ed25519; then
    echo "KEY GENERATED SUCCESSFULLY."
    echo "The public key to copy into your github profile is:"
    cat ${HOME}/.ssh/${keyname}.pub
else
    echo "FAILED."
    echo "Something went wrong at the final step. Please call a helper."
fi


