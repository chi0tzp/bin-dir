#!/bin/bash
################################################################################
## mount_backup.sh [options] <flag>                                           ##
## A bash script for mounting/unmounting BACKUP remote directory (hosted on   ##
## pifs) using sshfs / fusermount.                                            ##
##                                                                            ##
## Usage: mount_backup.sh [options]                                           ##
## Options:                                                                   ##
##    -r <remote>          : set the remote that hosts BACKUP                 ##
##    -p <remote_ssh_port> : set ssh port used for accessing remote           ##
##    -m <mount_point>     : set directory where remote BACKUP will be        ##
##                           mounted on                                       ##
##    <flag>               : set either to "on", for mounting remote BACKUP   ##
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
    echo "${b}Usage:${n} mount_backup.sh [-r <remote>] [-p <remote_ssh_port>] [-m <mount_point>] <flag>" 1>&2; exit 1;
}

# Initialize variables
OPTIND=1
PIFS_IP=192.168.0.28
PIFS_SSH_PORT=1312
BACKUP_MOUNT_POINT=~/BACKUP/

# Parse command line arguments
while getopts ":r:p:m:" options
do
    case $options in
        r ) PIFS_IP="$OPTARG"
            ;;
        p ) PIFS_SSH_PORT="$OPTARG"
            ;;
        m ) BACKUP_MOUNT_POINT="$OPTARG"
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
        echo "Mount backup..."
        mkdir -p $BACKUP_MOUNT_POINT
        sshfs -p $PIFS_SSH_PORT -C chi@$PIFS_IP:/home/backup0/ $BACKUP_MOUNT_POINT -o idmap=user
    elif [[ "${flag}" == "off" ]]; then
        echo "Unmount backup..."
        fusermount3 -u $BACKUP_MOUNT_POINT
	      rm -r $BACKUP_MOUNT_POINT
    else
        echo "${b}${red}[Invalid flag]${reset}${n} Choose:"
        echo " -- ${b}${red}on${reset}${n} (to mount backup on $BACKUP_MOUNT_POINT),"
        echo " -- ${b}${red}off${reset}${n} (to unmount backup from $BACKUP_MOUNT_POINT), or "
        echo " -- leave it ${b}${red}empty${reset}${n} for getting current status"
    fi

else
    # No flag has been given -- print status
    mountpoint $BACKUP_MOUNT_POINT >> /dev/null
    status=$?
    if [[ $status -eq 0 ]]; then
        echo "BACKUP is mounted on ${b}${red}$BACKUP_MOUNT_POINT${reset}${n}"
        lsof -w $BACKUP_MOUNT_POINT
    else
        echo "BACKUP is ${b}${red}not${reset}${n} mounted on ${b}${red}$BACKUP_MOUNT_POINT${reset}${n}"
    fi
fi
