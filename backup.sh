#!/bin/bash
################################################################################
## A bash script for keeping backups in local or remote directories using     ##
## rsync.                                                                     ##
##                                                                            ##
## Author  : Christos Tzelepis                                                ##
## Contact : null.geppetto@gmail.com                                          ##
################################################################################
# Require `notify-send` command (sudo pacman -S libnotify)

# tput formatters (part of `ncurses` package)
b=$(tput bold)
n=$(tput sgr0)
blink="\E[5m"
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

################################################################################
## rsync arguments:                                                           ##
##                                                                            ##
## -a, --archive          archive mode; equals -rlptgoD (no -H,-A,-X)         ##
## -A, --acls             preserve ACLs (implies -p)                          ##
## -X, --xattrs           preserve extended attributes                        ##
## -S, --sparse           handle sparse files efficiently                     ##
## -H, --hard-links       preserve hard links                                 ##
## -P                     same as --partial --progress                        ##
## -q, --quiet            Quiet; do not write anything to standard output.    ##
##                        Exit immediately with zero status if any match is   ##
##                        found, even  if  an  error  was detected.           ##
##                        Also see the -s or --no-messages option.            ##
## --del                  an alias for --delete-during                        ##
## --delete               delete extraneous files from dest dirs              ##
## --delete-before        receiver deletes before transfer (default)          ##
## --delete-during        receiver deletes during xfer, not before            ##
## --delete-delay         find deletions during, delete after                 ##
## --delete-after         receiver deletes after transfer, not before         ##
## --delete-excluded      also delete excluded files from dest dirs           ##
## --exclude=PATTERN      exclude files matching PATTERN                      ##
## --exclude-from=FILE    read exclude patterns from FILE                     ##
##                                                                            ##
################################################################################
RSYNC_ARGS="-aAXSHPr --quiet --delete --delete-excluded"

# Help function
usage(){
    echo "${b}Usage:${n} backup.sh -l <local_dest_dir> -r <remote_host>
${b}Options:${n}
    ${b}-l <local_dest_dir>${n} : define a local destination directory
    ${b}-r <remote_host>${n}    : define a remote host in the following form:
                            <host>:<remote_dir>, where <host> is a remote host entry in
                          ssh config file and <remote_dir> a remote directory under this
                          remote host
    " 1>&2; exit 1;

}

# Generate random alphanumeric string function
function gen_random_string(){
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

# Parse command line arguments
while getopts ":l:r:" o; do
    case "${o}" in
        l) if [ "${OPTARG: -1}" != "/" ]
           then
              OPTARG=${OPTARG}"/"
           fi
           LOCAL_DEST_DIR="${OPTARG}"
           ;;
        r) if [ "${OPTARG: -1}" != "/" ]
           then
              OPTARG=${OPTARG}"/"
           fi
           REMOTE_HOST=${OPTARG}
           ;;
        *) usage
           ;;
    esac
done
shift $((OPTIND-1))

# Check given arguments
if [ -z "${LOCAL_DEST_DIR}" ] && [ -z "${REMOTE_HOST}" ]; then
    echo "${red}[Error]${reset}: Select either a local destination dir or a remote host."
    usage
fi

if [ ! -z "${LOCAL_DEST_DIR}" ] && [ ! -z "${REMOTE_HOST}" ]; then
    echo "${red}[Error]${reset}: Select either a local destination dir or a remote host."
    usage
fi

################################################################################
## For each host (discriminated by the `$HOSTNAME`), define:                  ##
##   i) the source root directory (`SRC_ROOT_DIR`) under which dirs/files to  ##
##      be backed-up lie (typically SRC_ROOT_DIR=${HOME}"/"), and             ##
##   ii) the directories and/or files to be backed-up (`SRC_FILES`), as well  ##
##       as a list of excluded files/dirs split by ";" (see example below).   ##
##                                                                            ##
## For a new host, named "new_host", add an extra `elif` branch as follows:   ##
## ...                                                                        ##
## elif [ "${HOSTNAME}" == "new_host" ]                                       ##
## then                                                                       ##
##    SRC_ROOT_DIR=<root_dir>                                                 ##
##    SRC_FILES=(                                                             ##
##       ["<file>"]=""                                                        ##
##       ["<dir>"]="<file_1>;<file_2>;...;<file_n>"                           ##
##       ...                                                                  ##
##    )                                                                       ##
## ...                                                                        ##
##                                                                            ##
################################################################################

# ================================= GALOIS =================================== #
if [ "${HOSTNAME}" == "galois" ]
then
    # Define files and directories, (under `ROOT_DIR`) to be backed-up
    SRC_ROOT_DIR=${HOME}"/"
    declare -A SRC_FILES
    SRC_FILES=(
        [".gitconfig"]=""
        [".emacs"]=""
        [".ssh/"]=""
        [".thunderbird/"]=""
        ["LAB/"]="datasets"
        ["Education/"]=""
        ["Dropbox/"]=""
        ["Downloads"]=""
    )
# ================================= GAUSS ==================================== #
elif [ "${HOSTNAME}" == "gauss" ]
then
    # Define files and directories, (under `ROOT_DIR`) to be backed-up
    SRC_ROOT_DIR=${HOME}"/"
    declare -A SRC_FILES
    SRC_FILES=(
        [".ssh/"]=""
        [".thunderbird/"]=""
        ["LAB/"]="Datasets"
    )

# ============================ UNKNOWN HOSTNAME ============================== #
else
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;
fi
# ============================================================================ #


echo -e "#.Backup ${red}${b}${HOSTNAME}${n}${reset}"

if [ ! -z "${LOCAL_DEST_DIR}" ];
then
    echo -e "  \__Going to backup the following dirs to ${b}${LOCAL_DEST_DIR}: ${n}"
fi

if [ ! -z "${REMOTE_HOST}" ];
then
    echo -e "  \__Going to backup the following dirs to ${b}${REMOTE_HOST}: ${n}"
fi

echo -n ${red}
cols=`tput cols`
printf '%0.s-' $(seq 1 $cols)
echo ""
for item in "${!SRC_FILES[@]}"; do
    printf "   %-8s\n" "${item}"
done | column
printf '%0.s-' $(seq 1 $cols)
echo ""
echo -n ${reset}

# Ask for confirmation
while true; do
    read -p "#.Continue (y/n)? " yn
    case ${yn} in
        [Yy] ) break;;
        [Nn] ) echo "  \__OK. Goodbye!";exit;;
          * ) echo "  ${red}\__Please answer (y)es or (n)o...${reset}";;
    esac
done

# Create destination directory (if it doesn't exist)
if [ ! -z "${LOCAL_DEST_DIR}" ];
then
    LOCAL_DEST_DIR=${LOCAL_DEST_DIR}"${HOSTNAME}.bkp/"
    mkdir -p ${LOCAL_DEST_DIR}
fi
if [ ! -z "${REMOTE_HOST}" ];
then
    IFS=':' read -ra HOST <<< "${REMOTE_HOST}"
    REMOTE_DEST_DIR="${REMOTE_HOST}${HOSTNAME}.bkp/"
    ssh ${HOST[0]} "mkdir -p ${HOST[1]}${HOSTNAME}.bkp/"
fi

# Start back-up procedure
echo "#.Backing up..."

# Get start time
date=$(date +'%Y-%m-%d %H:%M:%S')
read Y M D h m s <<< ${date//[-: ]/ };
start_time="$Y-$M-$D @ $h:$m:$s"

# === Back-up ===
for i in "${!SRC_FILES[@]}"; do
    echo -en "  \__${blink}${i}..."

    # Create temporary exclude list file
    exclude_list_tmp_filename="tmp_exclude_list.$(gen_random_string)"
    touch $exclude_list_tmp_filename
    IFS=';' read -ra array <<< "${SRC_FILES[$i]}"
    for f in "${array[@]}"
    do
        echo $f >> $exclude_list_tmp_filename
    done

    # Run rsync for a local destination
    if [ ! -z "${LOCAL_DEST_DIR}" ];
    then
        rsync ${RSYNC_ARGS} --exclude-from $exclude_list_tmp_filename ${SRC_ROOT_DIR}${i} ${LOCAL_DEST_DIR}"$i" && echo -e "\r${reset}  \__${i}...Done!" || echo -e "\r${reset}  \__${i}...ERROR!"
    fi
    # Run rsync for a remote destination
    if [ ! -z "${REMOTE_HOST}" ];
    then
        rsync ${RSYNC_ARGS} --exclude-from $exclude_list_tmp_filename ${SRC_ROOT_DIR}${i} ${REMOTE_DEST_DIR}"$i" && echo -e "\r${reset}  \__${i}...Done!" || echo -e "\r${reset}  \__${i}...ERROR!"
    fi

    # Remove temporary exclude list file
    rm -f $exclude_list_tmp_filename

done

# Get end time
date=$(date +'%Y-%m-%d %H:%M:%S')
read Y M D h m s <<< ${date//[-: ]/ };
end_time="$Y-$M-$D @ $h:$m:$s"

echo "#.Backup complete!"
echo "  -------------------------------"
echo "  Started @ "${start_time}
echo "  Ended   @ "${end_time}
echo "  -------------------------------"

# notify-send 'backup.sh' "Backup of ${HOSTNAME} is complete!" --icon=dialog-information
