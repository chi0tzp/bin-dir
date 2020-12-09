#!/bin/bash
################################################################################
## redirect.sh: A bash script for redirecting traffic from a remote server to ##
##              localhost.                                                    ##
##                                                                            ##
## Usage: redirect.sh [options]                                               ##
## Options:                                                                   ##
##    -s SERVER        : SSH host entry for remote server (e.g., as defined   ##
##                       in ~/.ssh/config) or in the form of:                 ##
##                                  <username>@<remote_host>                  ##
##    -r <remote_port> : remote port                                          ##
##    -l <local_port>  : local port                                           ##
##                                                                            ##
################################################################################

b=$(tput bold)
n=$(tput sgr0)
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Help function
help(){
    echo "${b}Usage:${n} redirect.sh -s <server> -l <local_port> -r <remote_port>" 1>&2; exit 1;
}

# Parse command line arguments
OPTIND=1
while getopts ":s:r:l:" options
do
    case $options in
        s ) SSH_SERVER="$OPTARG"
            ;;
        r ) REMOTE_PORT="$OPTARG"
            ;;
        l ) LOCAL_PORT="$OPTARG"
            ;;
        * ) help
            ;;
    esac
done
shift $(expr $OPTIND - 1 )

echo "SSH_SERVER:${SSH_SERVER}"
echo "REMOTE_PORT:${REMOTE_PORT}"
echo "LOCAL_PORT:${LOCAL_PORT}"

exit_with_help=0
if [ -z "${SSH_SERVER}" ]; then
    echo "${red}[Error]${reset}: SSH server missing."
    exit_with_help=1
fi

if [ -z "${REMOTE_PORT}" ]; then
    echo "${red}[Error]${reset}: Remote port missing."
    exit_with_help=1
fi

if [ -z "${LOCAL_PORT}" ]; then
    echo "${red}[Error]${reset}: Local port missing."
    exit_with_help=1
    # help
fi

((exit_with_help)) && help || :
