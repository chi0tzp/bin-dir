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

################################################################################
##                               GET DESTINATION                              ##
################################################################################
DEST_DIR=""
while getopts d: opt; do
  case $opt in
  d)
      if [ "${OPTARG: -1}" != "/" ]
      then
        OPTARG=${OPTARG}"/"
      fi
      DEST_DIR="${OPTARG}${HOSTNAME}/"
      ;;
  esac
done
shift $((OPTIND - 1))

# -- Check if the destination option (-d) is given --
if [[ -z "${DEST_DIR}" ]]
then
    echo "${red}Destination option (-d) missing. Abort!${reset}"
    exit;
fi


# RIEMANN
# -------
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
            ".ssh"
            ".bashrc"
            ".emacs"
            ".gitconfig"
            ".pdbrc"
            ".tmux.conf"
            ".xbindkeysrc" )

# HILBERT
# -------
elif [ "${HOSTNAME}" == "hilbert" ]
then
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;

# UNKNOWN HOSTNAME
# ----------------
else
    echo "## Error: Unknown hostname: ${HOSTNAME}. Goodbye!"
    exit;
fi

# Ask for confirmation
echo "Hostname:${red}" ${HOSTNAME} "${reset}"
echo ">> Gonna backup the following dirs to ${DEST_DIR}:"
echo -n ${red}
for item in "${DIRS[@]}"; do
    printf "   %-8s\n" "${item}"
done | column
echo -n ${reset}

while true; do
    read -p ">> Continue (y/n)?" yn
    case ${yn} in
        [Yy]* ) break;;
        [Nn]* ) echo ">> OK. Goodbye!";exit;;
            * ) echo "## Please answer (y)es or (n)o...";;
    esac
done

# Start back-up procedure
echo ">> Backing up..."

# Create destination directory (if it doesn't exist)
# This doesn't work when destination is a remote machine
# mkdir -p ${DEST_DIR}${HOSTNAME}

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

# Append to a log file under `LOG_DIR`
LOG_DIR=".log/"
mkdir -p ${DEST_DIR}${LOG_DIR}
LOG_FILE=${DEST_DIR}${LOG_DIR}${HOSTNAME}"_backup.log"
echo "* BACKUP ${HOSTNAME}" >> ${LOG_FILE}
echo "  --------------------------------"  >> ${LOG_FILE}
echo "  Started @ "${start_time}           >> ${LOG_FILE}
echo "  Ended   @ "${end_time}             >> ${LOG_FILE}
echo "  --------------------------------"  >> ${LOG_FILE}
