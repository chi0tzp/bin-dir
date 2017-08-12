#!/bin/bash
################################################################################
## backup.sh -d <destination>                                                 ##
## A bash script for backups using rsync                                      ##
##                                                                            ##
##                                                                            ##
################################################################################
#                                                                              #
# RSYNC Options:                                                               #
#                                                                              #
# -a : --archive               archive mode; equals -rlptgoD (no -H,-A,-X)     #
#      --no-OPTION             turn off an implied OPTION (e.g. --no-D)        #
#                                                                              #
# -v : --verbose               increase verbosity                              #
#      --info=FLAGS            fine-grained informational verbosity            #
#      --debug=FLAGS           fine-grained debug verbosity                    #
#      --msgs2stderr           special output handling for debugging           #
#                                                                              #
# -e : --del                   an alias for --delete-during                    #
#      --delete                delete extraneous files from dest dirs          #
#      --delete-before         receiver deletes before xfer, not during        #
#      --delete-during         receiver deletes during the transfer            #
#      --delete-delay          find deletions during, delete after             #
#      --delete-after          receiver deletes after transfer, not during     #
#      --delete-excluded       also delete excluded files from dest dirs       #
#                                                                              #
################################################################################

# -- rsync command and options --
rsync_cmd="rsync"
rsync_opt="-azq --delete-after"

# -- List of months --
MONTHS=(null Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

usage(){ echo "Usage: backup.sh -d <dest_dir> [-r <remote>]" 1>&2; exit 1; }

# Parse command line arguments
while getopts ":d:r:" o; do
    case "${o}" in
        d)
            if [ "${OPTARG: -1}" != "/" ]
            then
                OPTARG=${OPTARG}"/"
            fi
            DEST_DIR="${OPTARG}${HOSTNAME}/"
            ;;
        r)
            REMOTE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${DEST_DIR}" ]; then
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
# elif [ "${HOSTNAME}" == "new_host" ]                                          #
# then                                                                         #
#    ROOT_DIR=<root_dir>                                                       #
#    DIRS=( <dir1> <dir2> <file1> <file2> )                                    #
# ...                                                                          #
################################################################################


# RIEMANN
if [ "${HOSTNAME}" == "riemann" ]
then
    # Define root directory
    ROOT_DIR=${HOME}"/"
    # Define directories (under `ROOT_DIR`) to be backed-up
    DIRS=( "bin/"
            "LAB/"
            "Dropbox/"
            "SpiderOak Hive/"
            ".icedove/"
            ".ssh/"
            ".bashrc"
            ".emacs"
            ".gitconfig"
            ".pdbrc"
            ".tmux.conf"
            ".xbindkeysrc" )

# HILBERT
elif [ "${HOSTNAME}" == "hilbert" ]
then
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;

# UNKNOWN HOSTNAME
else
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;
fi

echo -e "Hostname:${red} \e[4m${HOSTNAME}\e[24m ${reset}"
if [ ! -z "${REMOTE}" ];
then echo -e ">> Gonna backup the following dirs to \e[5m${REMOTE}:${DEST_DIR}\e[25m:"
else echo -e ">> Gonna backup the following dirs to \e[5m${DEST_DIR}\e[25m:"
fi
echo -n ${red}
cols=`tput cols`
printf '%0.s-' $(seq 1 $cols)
echo ""
for item in "${DIRS[@]}"; do
    printf "   %-8s\n" "${item}"
done | column
printf '%0.s-' $(seq 1 $cols)
echo ""
echo -n ${reset}

# Ask for confirmation
while true; do
    read -p ">> Continue (y/n)?" yn
    case ${yn} in
        [Yy]* ) break;;
        [Nn]* ) echo ">> OK. Goodbye!";exit;;
            * ) echo "## Please answer (y)es or (n)o...";;
    esac
done

# Create destination directory (if it doesn't exist)
if [ -z "${REMOTE}" ]; then
    mkdir -p ${DEST_DIR}${HOSTNAME}
else
    ssh ${REMOTE} "mkdir -p ${DEST_DIR}"
    DEST_DIR="${REMOTE}:${DEST_DIR}"
fi

# Start back-up procedure
echo ">> Backing up..."

# Get start time
date=$(date +'%Y-%m-%d %H:%M:%S')
read Y M D h m s <<< ${date//[-: ]/ };
start_time="$Y-$M-$D @ $h:$m:$s"

# Back-up
for i in "${DIRS[@]}"
do
    echo -n "   --" ${i}" ..."
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}"$i" ${DEST_DIR}"$i" && echo "Done!"
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
