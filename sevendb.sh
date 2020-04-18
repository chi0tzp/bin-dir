#!/bin/bash
################################################################################
## sevendb.sh <flag>                                                          ##
## A bash script for mounting/unmounting sevendb remote directory (hosted on  ##
## rpi4) using sshfs / fusermount3.                                           ##
################################################################################

b=$(tput bold)
n=$(tput sgr0)
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

flag=$@
if [[ "${flag}" == "on" ]]; then
    echo "Mount sevendb..."
    mkdir -p ~/sevendb
    sshfs -p 1312 -C chi@rpi4:/home/sevendb/ ~/sevendb/ -o idmap=user
elif [[ "${flag}" == "off" ]]; then
    echo "Unmount sevendb..."
    fusermount3 -u ~/sevendb/
else
    echo "${b}${red}[Invalid flag]${reset}${n} Choose ${b}${green}on${reset}${n} (to mount sevendb) or ${b}${red}off${reset}${n} (to unmount sevendb)"
fi
