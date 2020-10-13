#!/bin/bash
################################################################################
## datasets.sh <flag>                                                         ##
## A bash script for mounting/unmounting datasets remote directory (hosted on ##
## pifs) using sshfs / fusermount.                                            ##
##                                                                            ##
## Usage: datasets.sh [options]                                               ##
## Options:                                                                   ##
##    -r <remote>          : set the remote that hosts datasets               ##
##    -m <mount_point>     : set directory where remote datasets will be      ##
##                           mounted on                                       ##
##    <flag>               : set either to "on", for mounting remote datasets ##
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
    echo "${b}Usage:${n} datasets.sh [-r <remote>] [-m <mount_point>] <flag>" 1>&2; exit 1;
}

# Initialize variables
OPTIND=1
PIFS=pifs
DATASETS_MOUNT_POINT=~/Datasets/

# Parse command line arguments
while getopts ":r:m:" options
do
    case $options in
        r ) PIFS="$OPTARG"
            ;;
        m ) DATASETS_MOUNT_POINT="$OPTARG"
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
        echo "Mount datasets..."
        mkdir -p $DATASETS_MOUNT_POINT
        sshfs ${PIFS}:/home/datasets/ $DATASETS_MOUNT_POINT -o idmap=user

    elif [[ "${flag}" == "off" ]]; then
        echo "Unmount datasets..."
        fusermount3 -u $DATASETS_MOUNT_POINT
	      rm -r $DATASETS_MOUNT_POINT
    else
        echo "${b}${red}[Invalid flag]${reset}${n} Choose:"
        echo " -- ${b}${red}on${reset}${n} (to mount datasets on $DATASETS_MOUNT_POINT),"
        echo " -- ${b}${red}off${reset}${n} (to unmount datasets from $DATASETS_MOUNT_POINT), or "
        echo " -- leave it ${b}${red}empty${reset}${n} for getting current status"
    fi

else
    # No flag has been given -- print statuss
    mountpoint -q $DATASETS_MOUNT_POINT >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "Datasets are mounted on ${b}${red}$DATASETS_MOUNT_POINT${reset}${n}"
        lsof -w $DATASETS_MOUNT_POINT
    else
        echo "Datasets are ${b}${red}not${reset}${n} mounted on ${b}${red}$DATASETS_MOUNT_POINT${reset}${n}"
    fi
fi
