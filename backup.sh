#!/bin/bash
################################################################################
## A bash script for backups using rsync                                      ##
##                                                                            ##
################################################################################
# Require `notify-send` command (sudo pacman -S libnotify)

# -- List of months --
MONTHS=(null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

b=$(tput bold)
n=$(tput sgr0)
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

usage(){ echo "${b}Usage:${n} backup.sh -l <local_dest_dir> -r <remote_machine> [-p <remote_port> [-d <remote_dest_dir>]]" 1>&2; exit 1; }

# Parse command line arguments
REMOTE_PORT=22
REMOTE_DEST_DIR="${HOSTNAME}.bkp/"
while getopts ":l:r:p:d:" o; do
    case "${o}" in
        l)
            if [ "${OPTARG: -1}" != "/" ]
            then
                OPTARG=${OPTARG}"/"
            fi
            LOCAL_DEST_DIR="${OPTARG}"
            ;;
        r)
            REMOTE_MACHINE=${OPTARG}
            ;;
        p)
            REMOTE_PORT=${OPTARG}
            ;;
        d)
            if [ "${OPTARG: -1}" != "/" ]
            then
                OPTARG=${OPTARG}"/"
            fi
            REMOTE_DEST_DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${LOCAL_DEST_DIR}" ] && [ -z "${REMOTE_MACHINE}" ]; then
    usage
fi

if [ ! -z "${LOCAL_DEST_DIR}" ] && [ ! -z "${REMOTE_MACHINE}" ]; then
    echo "${red}[Error]${reset}: Select either a local destination dir or a remote one."
    usage
fi

################################################################################
# For each host (discriminated by the `$HOSTNAME`), define:                    #
#   i) the root directory under which dirs/files to be backed-up lie           #
#      (`ROOT_DIR`), and                                                       #
#   ii) the directories and/or files to be backed-up (array `DIRS`).           #
#                                                                              #
# For a new host, named "new_host", add an extra `elif` branch as follows:     #
# ...                                                                          #
# elif [ "${HOSTNAME}" == "new_host" ]                                         #
# then                                                                         #
#    ROOT_DIR=<root_dir>                                                       #
#    DIRS=( <dir1> <dir2> <file1> <file2> )                                    #
# ...                                                                          #
################################################################################

# ================================= GALOIS =================================== #
if [ "${HOSTNAME}" == "galois" ]
then
    # Define files and directories, (under `ROOT_DIR`) to be backed-up
    SRC_ROOT_DIR=${HOME}"/"
    declare -A array
    array=(
        [".gitconfig"]=""
        [".emacs"]=""
        [".ssh/"]=""
        [".thunderbird/"]=""
        ["LAB/"]="datasets"
        ["temp_dir/"]="test_1.txt"
    )
# ============================================================================ #

# ============================ UNKNOWN HOSTNAME ============================== #
else
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;
fi
# ============================================================================ #

echo -e "Hostname: ${red}${b}${HOSTNAME}${n}${reset}"
if [ ! -z "${LOCAL_DEST_DIR}" ];
then
    echo -e ">> Gonna backup the following dirs to ${b}${LOCAL_DEST_DIR}${HOSTNAME}: ${n}"
fi
if [ ! -z "${REMOTE_MACHINE}" ];
then
    echo -e ">> Gonna backup the following dirs to \e[5m${REMOTE_MACHINE}:${REMOTE_DEST_DIR} (port:${REMOTE_PORT})\e[25m:"
fi

echo -n ${red}
cols=`tput cols`
printf '%0.s-' $(seq 1 $cols)
echo ""
for item in "${!array[@]}"; do
    printf "   %-8s\n" "${item}"
done | column
printf '%0.s-' $(seq 1 $cols)
echo ""
echo -n ${reset}

# Ask for confirmation
while true; do
    read -p ">> Continue (y/n)? " yn
    case ${yn} in
        [Yy] ) break;;
        [Nn] ) echo ">> OK. Goodbye!";exit;;
          * ) echo "   ${red}Please answer (y)es or (n)o...${reset}";;
    esac
done

# Create destination directory (if it doesn't exist)
if [ ! -z "${LOCAL_DEST_DIR}" ];
then
    mkdir -p ${LOCAL_DEST_DIR}"${HOSTNAME}.bkp/"
    DEST_DIR=${LOCAL_DEST_DIR}"${HOSTNAME}.bkp/"
fi
if [ ! -z "${REMOTE_MACHINE}" ];
then
    ssh ${REMOTE_MACHINE} -p ${REMOTE_PORT} "mkdir -p ${REMOTE_DEST_DIR}"
    DEST_DIR=${REMOTE_MACHINE}:${REMOTE_DEST_DIR}
fi

# Start back-up procedure
echo ">> Backing up..."

# Get start time
date=$(date +'%Y-%m-%d %H:%M:%S')
read Y M D h m s <<< ${date//[-: ]/ };
start_time="$Y-$M-$D @ $h:$m:$s"

# === Back-up ===
for i in "${!array[@]}"; do
    echo -n "   --" ${i}" ..."
    if [ ! -z "${LOCAL_DEST_DIR}" ];
    then
        rsync -aAXSHPrq --numeric-ids --delete --delete-excluded --exclude "${array[$i]}" ${SRC_ROOT_DIR}${i} ${DEST_DIR}"$i" && echo "Done!"
    fi
    if [ ! -z "${REMOTE_MACHINE}" ];
    then
        rsync -aAXSHPrq --numeric-ids --delete --exclude "${array[$i]}" -e "ssh -p ${REMOTE_PORT}" ${SRC_ROOT_DIR}${i} ${DEST_DIR}"$i" && echo "Done!"
    fi
done

# Get end time
date=$(date +'%Y-%m-%d %H:%M:%S')
read Y M D h m s <<< ${date//[-: ]/ };
end_time="$Y-$M-$D @ $h:$m:$s"

echo ">> Backup complete!"
echo "   -------------------------------"
echo "   Started @ "${start_time}
echo "   Ended   @ "${end_time}
echo "   -------------------------------"

notify-send 'backup.sh' "Backup of ${HOSTNAME} is complete!" --icon=dialog-information
