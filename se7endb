#!/bin/bash
################################################################################
## se7endb.sh <flag>                                                          ##
## A bash script for mounting/unmounting the following SevenDB remote         ##
## directories (hosted on pifs) using sshfs / fusermount:                     ##
##  -- pifs:/home/sevendb/FILMS001                                            ##
##  -- pifs:/home/sevendb-plus/FILMS002                                       ##
##                                                                            ##
## Usage: se7endb.sh [options]                                                ##
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
    echo "${b}Usage:${n} se7endb.sh [-m <mount_point>] <flag>" 1>&2; exit 1;
}

# Initialize variables
OPTIND=1
SEVENDB_MOUNT_POINT=~/SEVENDB

# Parse command line arguments
while getopts ":m:" options
do
    case $options in
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
        echo "Mount SEVENDB..."
        mkdir -p $SEVENDB_MOUNT_POINT
        mkdir -p $SEVENDB_MOUNT_POINT/FILMS001
        sshfs -o idmap=user pifs:/home/sevendb/FILMS001 $SEVENDB_MOUNT_POINT/FILMS001
        mkdir -p $SEVENDB_MOUNT_POINT/FILMS002
        sshfs -o idmap=user pifs:/home/sevendb-plus/FILMS002 $SEVENDB_MOUNT_POINT/FILMS002
        mkdir -p $SEVENDB_MOUNT_POINT/SERIES
        sshfs -o idmap=user pifs:/home/series/Series $SEVENDB_MOUNT_POINT/SERIES

    elif [[ "${flag}" == "off" ]]; then
        echo "Unmount SEVENDB..."
        fusermount3 -u $SEVENDB_MOUNT_POINT/FILMS001
        fusermount3 -u $SEVENDB_MOUNT_POINT/FILMS002
        fusermount3 -u $SEVENDB_MOUNT_POINT/SERIES
        rm -r $SEVENDB_MOUNT_POINT

    else
        echo "${b}${red}[Invalid flag]${reset}${n} Choose:"
        echo " -- ${b}${red}on${reset}${n} (to mount SEVENDB on $SEVENDB_MOUNT_POINT),"
        echo " -- ${b}${red}off${reset}${n} (to unmount SEVENDB from $SEVENDB_MOUNT_POINT), or "
        echo " -- leave it ${b}${red}empty${reset}${n} for getting current status"
    fi

else
    # No flag has been given -- print status
    # --- FILMS001 ---
    mountpoint -q $SEVENDB_MOUNT_POINT/FILMS001 >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "SEVENDB/FILMS001 is mounted on ${b}${red}$SEVENDB_MOUNT_POINT/FILMS001${reset}${n}"
        lsof -w $SEVENDB_MOUNT_POINT/FILMS001
    else
        echo "SEVENDB/FILMS001 is ${b}${red}not${reset}${n} mounted on ${b}${red}$SEVENDB_MOUNT_POINT/FILMS001${reset}${n}"
    fi
    # --- FILMS002 ---
    mountpoint -q $SEVENDB_MOUNT_POINT/FILMS002 >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "SEVENDB/FILMS002 is mounted on ${b}${red}$SEVENDB_MOUNT_POINT/FILMS002${reset}${n}"
        lsof -w $SEVENDB_MOUNT_POINT/FILMS002
    else
        echo "SEVENDB/FILMS002 is ${b}${red}not${reset}${n} mounted on ${b}${red}$SEVENDB_MOUNT_POINT/FILMS002${reset}${n}"
    fi
    # --- SERIES ---
    mountpoint -q $SEVENDB_MOUNT_POINT/SERIES >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "SEVENDB/SERIES is mounted on ${b}${red}$SEVENDB_MOUNT_POINT/SERIES${reset}${n}"
        lsof -w $SEVENDB_MOUNT_POINT/SERIES
    else
        echo "SEVENDB/SERIES is ${b}${red}not${reset}${n} mounted on ${b}${red}$SEVENDB_MOUNT_POINT/SERIES${reset}${n}"
    fi
fi
