#!/bin/bash

# *Changelog*
# [1.0] [MLA] [16/06/2021]  : Creation of this script

# ! SCRIPTS VARIABLES ! #
sName="launch-gs"
sDesc="Launch the get-started script automaticaly"
sLang="bash"
sVers="1.0"

# Variables legend
# c = color variables (ex : cRed = Red Color)
# s = scripts variables (ex : command format, date, etc.)
# v = standard variables (ex : vVar = string)

# *VARIABLES* #

# [c] - Color varaibles
cRed="\e[31m" # Print string in red
cGreen="\e[32m" # Print string in green
cBlue="\e[34m" # Print string in blue
cYellow="\e[33m" # Print string in yellow
cNone="\e[39m" # Print string with standard foreground color

# [s] - Scripts variables
sUser=$(who am i | awk '{print $1}') # Print elevated user
sDateLog=$(date +'%d/%m/%d %H:%M') # Format date for log : 01/01/10 10:10
sDateFile=$(date +'%d%m%d') # Format date for file name : 010110
sLogFile="/var/log/${sName}_${sDateFile}.log"

# [v] - Standard variables

# *FUNCTIONS* #

getPrintOk () {
    echo -e "[${cGreen}OK${cNone}] $*"
}

getPrintInfo () {
    echo -e "[${cBlue}INFO${cNone}] $*"
}

getPrintError () {
    echo -e "[${cRed}ERROR${cNone}] $*"
}

getPrintWarn () {
    echo -e "[${cYellow}WARNING${cNone}] $*"
}

getCheckError () {
    if [ $? == 0 ]; then
        getPrintOk "The task was successfully completed"
    else
        getPrintError "The task could not be completed"
        exit 1
    fi
}

# *SCRIPT* #
if [ ! -f ~/.ssh/id_ed25519 ]; then
    getPrintInfo "Generation keys for GitHub ----------------------- [PR]"
    ssh-keygen -q -t ed25519 -b 4096 -N "" -f ~/.ssh/id_ed25519
    getCheckError
else
    vGitHubKey="yes"
fi

if [ "${vGitHubKey}" != "yes" ]; then
    getPrintWarn "Display the public key ------------------------ [PR]"
    echo ""
    echo "###########################################################"
    echo "#                     Your public key                     #"
    echo "# Please retrive it and paste it into your GitHub account #"
    echo "###########################################################"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
    read -n 1 -r -s -p "Press enter to continue..."
    echo ""
fi

getPrintInfo "Add gh-cli repository ---------------------------- [PR]"
sudo dnf config-manager --quiet -y --add-repo https://cli.github.com/packages/rpm/gh-cli.repo > /dev/null 2>&1
getCheckError

getPrintInfo "Install gh-cli ----------------------------------- [PR]"
sudo dnf install --quiet -y gh > /dev/null 2>&1
getCheckError

getPrintInfo "Configuration of gh-cli -------------------------- [PR]"
gh config set git_protocol ssh -h github.com
getCheckError

getPrintInfo "Enter your access token -------------------------- [PR]"
read -s -e -p "Please enter your access token : " vAccessToken
echo $vAccessToken > access-token.txt
echo ""

getPrintInfo "Github login ------------------------------------- [PR]"
gh auth login --with-token < access-token.txt
getCheckError
rm -f access-token.txt

if [ -d /tmp/get-started ]; then
    getPrintInfo "Remove old source -------------------------------- [PR]"
    rm -Rf /tmp/get-started
    getCheckError
fi

getPrintInfo "Clone get-started sources ------------------------ [PR]"
cd /tmp
gh repo clone V1rtualAx3/get-started > /dev/null 2>&1
getCheckError

getPrintInfo "Execution of get-started ------------------------- [PR]"
sudo bash /tmp/get-started/get-started.sh
getCheckError

echo""
echo -e "############## ${cYellow}AFTER RUN TASKS${cNone} ##############"
echo""

getPrintInfo "Delete get-started sources ----------------------- [AR]"
cd ~/
sudo rm -Rf /tmp/get-started

getPrintInfo "Update system ------------------------------------ [AR]"
sudo dnf update --quiet -y > /dev/null 2>&1
getCheckError

getPrintWarn "Reboot in 30 seconds -------------------------- [AR]"
sleep 30s && reboot