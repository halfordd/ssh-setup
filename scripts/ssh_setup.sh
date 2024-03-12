#!/bin/bash

# TODO:
# 1. Capture user name and email,  and include email in cert DONE
# 2. Set git defaults for platform DONE
# 3. Open github new key page
# 4. Work on automated workarounds for broken home folders

echo "******************************"
echo "**                          **"
echo "** GIT / SSH SETUP UTILITY  **"
echo "**          FOR             **"
echo "**   SOFTWARE CARPENTRIES   **"
echo "**                          **"
echo "**        TU Delft          **"
echo "**                          **"
echo "******************************"

echo

echo "Please enter your First and Last Name (e.g. Alice Smith)"
read -r name
echo "Thank you ${name}"
echo
confirm="n"
while [[ ${confirm} != "y" && ${confirm} != "Y" ]]; do
    echo "Please enter your email address (e.g. A.Smith@tudelft.nl)"
    read -r email
    echo "You entered ${email}. Is this correct? (y/n)"
    read -r confirm
done


# DETERMINE PLATFORM

platform=`uname`

if [[ $platform == "Darwin" ]]; then
    echo "You appear to be using a Mac."
    echo "Setting Unix line-end style."
    git config --global core.autocrlf input
elif [[ ${platform:0:7} == "MINGW64" ]]; then
    echo "You appear to be running bash on Windows, perhaps with Git-bash."
    platform="${platform:0:7}"
    echo "Setting Windows line-end style. If this is not Windows, you should change this by typing:"
    echo "git config --global core.autocrlf input"
    git config --global core.autocrlf true
else
    echo "Your platform appeas to be ${platform}."
    echo "Setting Unix line-end style. If this is some version of Windows, you should change this by typing:"
    echo "git config --global core.autocrlf true"
    git config --global core.autocrlf input
fi


echo "Setting other Git global options:"
echo
echo "Setting git global user name to ${name}"
git config --global user.name "${name}"
echo
echo "Setting git global user email to ${email}"
git config --global user.email "${email}"
echo
if command -v nano $> /dev/null ; then
    echo "Nano editor found. Making it your degault editor for git."
    git config --global core.editor nano
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

if ssh-keygen -f ${HOME}/.ssh/${keyname} -N "" -t ed25519 -C "${email}"; then
    echo "KEY GENERATED SUCCESSFULLY."
    echo "The public key to copy into your github profile is:"
    echo
    cat ${HOME}/.ssh/${keyname}.pub
    echo
else
    echo "FAILED."
    echo "Something went wrong at the final step. Please call a helper."
fi


# Open Github page to paste the new key

echo "Opening the github 'Add new key' page."
echo "In the 'Title field enter: ${keyname}"
echo "In the 'Key' field copy and paste the EXACT public key contents as shown above."
echo "Then click 'Add SSH Key'."
echo
echo "Press enter when you have successfully added the key."


# FIX FOR NON-MACS
open https://github.com/settings/ssh/new


read -r confirm2

echo 
echo "Doing final test that the key works:"
ssh -T git@github.com;
