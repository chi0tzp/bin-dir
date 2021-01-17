#!/bin/bash
################################################################################
## series.sh <flag>                                                           ##
## A bash script for mounting/unmounting Series remote directory (hosted on   ##
## pifs) using sshfs / fusermount.                                            ##
##                                                                            ##
## Usage: series.sh [options]                                                 ##
## Options:                                                                   ##
##    -r <remote>          : set the remote that hosts Series                 ##
##    -m <mount_point>     : set directory where remote series will be        ##
##                           mounted on                                       ##
##    <flag>               : set either to "on", for mounting remote series   ##
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
    echo "${b}Usage:${n} series.sh [-r <remote>] [-m <mount_point>] <flag>" 1>&2; exit 1;
}

# Initialize variables
OPTIND=1
PIFS=pifs
SERIES_MOUNT_POINT=~/Series

# Parse command line arguments
while getopts ":r:m:" options
do
    case $options in
        r ) PIFS="$OPTARG"
            ;;
        m ) SERIES_MOUNT_POINT="$OPTARG"
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
        echo "Mount Series..."
        mkdir -p $SERIES_MOUNT_POINT
        sshfs -o idmap=user ${PIFS}:/home/series/Series/ $SERIES_MOUNT_POINT

    elif [[ "${flag}" == "off" ]]; then
        echo "Unmount Series..."
        fusermount3 -u $SERIES_MOUNT_POINT
	    rm -r $SERIES_MOUNT_POINT
    else
        echo "${b}${red}[Invalid flag]${reset}${n} Choose:"
        echo " -- ${b}${red}on${reset}${n} (to mount Series on $SERIES_MOUNT_POINT),"
        echo " -- ${b}${red}off${reset}${n} (to unmount Series from $SERIES_MOUNT_POINT), or "
        echo " -- leave it ${b}${red}empty${reset}${n} for getting current status"
    fi

else
    # No flag has been given -- print statuss
    mountpoint -q $SERIES_MOUNT_POINT >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "Series is mounted on ${b}${red}$SERIES_MOUNT_POINT${reset}${n}"
        lsof -w $SERIES_MOUNT_POINT
    else
        echo "Series is ${b}${red}not${reset}${n} mounted on ${b}${red}$SERIES_MOUNT_POINT${reset}${n}"
    fi
fi
