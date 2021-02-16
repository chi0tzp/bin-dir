#!/bin/bash
################################################################################
## sevendb-plus.sh <flag>                                                     ##
## A bash script for mounting/unmounting SEVENDB-PLUS remote directory        ##
## (hosted on pifs) using sshfs / fusermount.                                 ##
##                                                                            ##
## Usage: sevendb.sh [options]                                                ##
## Options:                                                                   ##
##    -r <remote>          : set the remote that hosts SevenDB                ##
##    -m <mount_point>     : set directory where remote sevendb will be       ##
##                           mounted on                                       ##
##    <flag>               : set either to "on", for mounting remote sevendb  ##
##                           direcotry using sshff, "off" for unmounting it   ##
##                           using fusermount, or leave it empty for getting  ##
##                           the status of mount point                        ##
##                                                                            ##
################################################################################

b=$(tput bold)
n=$(tput sgr0)
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Help function
help(){
    echo "${b}Usage:${n} sevendb-plus.sh [-r <remote>] [-m <mount_point>] <flag>" 1>&2; exit 1;
}

# Initialize variables
OPTIND=1
PIFS=pifs
SEVENDB_MOUNT_POINT=~/SevenDB-PLUS/

# Parse command line arguments
while getopts ":r:m:" options
do
    case $options in
        r ) PIFS="$OPTARG"
            ;;
        m ) SEVENDB_MOUNT_POINT="$OPTARG"
            ;;
        * ) help
            ;;
    esac
done
shift $(expr $OPTIND - 1 )

if [[ $# -gt 0 ]]; then
    # A flag has been given
    flag=$1
    if [[ "${flag}" == "on" ]]; then
        echo "Mount sevendb..."
        mkdir -p $SEVENDB_MOUNT_POINT
        sshfs -o idmap=user ${PIFS}:/home/sevendb-plus/ $SEVENDB_MOUNT_POINT

    elif [[ "${flag}" == "off" ]]; then
        echo "Unmount sevendb..."
        fusermount3 -u $SEVENDB_MOUNT_POINT
	      rm -r $SEVENDB_MOUNT_POINT
    else
        echo "${b}${red}[Invalid flag]${reset}${n} Choose:"
        echo " -- ${b}${red}on${reset}${n} (to mount sevendb on $SEVENDB_MOUNT_POINT),"
        echo " -- ${b}${red}off${reset}${n} (to unmount sevendb from $SEVENDB_MOUNT_POINT), or "
        echo " -- leave it ${b}${red}empty${reset}${n} for getting current status"
    fi

else
    # No flag has been given -- print statuss
    mountpoint -q $SEVENDB_MOUNT_POINT >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "SevenDB-PLUS is mounted on ${b}${red}$SEVENDB_MOUNT_POINT${reset}${n}"
        lsof -w $SEVENDB_MOUNT_POINT
    else
        echo "SevenDB-PLUS is ${b}${red}not${reset}${n} mounted on ${b}${red}$SEVENDB_MOUNT_POINT${reset}${n}"
    fi
fi
