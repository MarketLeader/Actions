#!/bin/bash

# ls /
echo -e "\n$hr\nROOT DIR\n$hr"
cd / && pwd && ls -al /

# root
echo -e "\n$hr\nROOT PROFILES\n$hr"
echo "/root"
[[ "$(whoami)" == "root" ]] && ls -alL /root || sudo bash -c 'ls -alL /root'

# root ssh
echo -e "\n$hr\nSSH FILES\n$hr"
echo "/root/.ssh"
mkdir /root/.ssh
[[ "$(whoami)" == "root" ]] && ls -alL /root/.ssh || sudo bash -c 'ls -alL /root/.ssh'

# home
echo -e "\n$hr\nHOME DIR\n$hr"
echo ${HOME}
ls -al ${HOME}

# git/config
cd ${WORKING_DIR}
echo -e "\n$hr\nGIT PROFILES\n$hr"
ls -al .git

echo -e "\n$hr\nGIT CPNFIG\n$hr"
chown -R $(whoami) .git/config
git config --unset http.https://github.com/.extraheader
git config --unset-all http.https://github.com/.extraheader
git config --global --unset http.https://github.com/.extraheader
git config --system --unset http.https://github.com/.extraheader
cat .git/config

# environtment
echo -e "\n$hr\nENVIRONTMENT\n$hr"
printenv | sort

# Generate a Gemfile.lock
# $ docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app combos/ruby_node:3_16 bundle install
