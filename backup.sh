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
    echo "Destination option (-d) missing. Abort!"
    exit;
fi


################################################################################
##                                  RIEMANN                                   ##
################################################################################
if [ "${HOSTNAME}" == "riemann" ]
then
    # -- Source directories --
    ROOT_DIR=${HOME}"/"
    BIN_SRC="bin/"
    LAB_SRC="LAB/"
    DROPBOX_SRC="Dropbox/"
    SPIDEROAK_SRC='SpiderOak Hive/'
    ICEDOVE_SRC=".icedove/"

    # -- Ask for confirmation --
    echo "Hostname:" ${HOSTNAME}
    echo ">> Gonna backup the following dirs to:" ${DEST_DIR}
    echo "   -- " ${BIN_SRC}
    echo "   -- " ${LAB_SRC}
    echo "   -- " ${SPIDEROAK_SRC}
    echo "   -- " ${ICEDOVE_SRC}

    while true; do
        read -p ">> Continue (y/n)?" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo ">> OK. Goodbye!";exit;;
            * ) echo "## Please answer (y)es or (n)o...";;
        esac
    done

    # -- Back Up DIRs --
    echo ">> Backing up..."

    mkdir -p ${DEST_DIR}${HOSTNAME}

    # -- Get start time --
    date=$(date +'%Y-%m-%d %H:%M:%S')
    read Y M D h m s <<< ${date//[-: ]/ };
    start_time="$Y-$M-$D @ $h:$m:$s"

    # -- BIN_SRC --
    echo -n "   -- " ${BIN_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}${BIN_SRC} ${DEST_DIR}${BIN_SRC} && echo "done!"

    # -- LAB_SRC --
    echo -n "   -- " ${LAB_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}${LAB_SRC} ${DEST_DIR}${LAB_SRC} && echo "done!"

    # -- DROPBOX_SRC --
    echo -n "   -- " ${DROPBOX_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}${DROPBOX_SRC} ${DEST_DIR}${DROPBOX_SRC} && echo "done!"

    # -- SPIDEROAK_SRC --
    echo -n "   -- " ${SPIDEROAK_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}"${SPIDEROAK_SRC}" ${DEST_DIR}"${SPIDEROAK_SRC}" && echo "done!"

    # -- ICEDOVE_SRC --
    echo -n "   -- " ${ICEDOVE_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}"${ICEDOVE_SRC}" ${DEST_DIR}"${ICEDOVE_SRC}" && echo "done!"

    # -- Get end time --
    date=$(date +'%Y-%m-%d %H:%M:%S')
    read Y M D h m s <<< ${date//[-: ]/ };
    end_time="$Y-$M-$D @ $h:$m:$s"

    # -- Append to a log file --
    echo ""
    echo ">> Backup complete!"
    echo "   -------------------------------"
    echo "   Started @ "${start_time}
    echo "   Ended   @ "${end_time}
    echo "   -------------------------------"

    LOG_DIR=".log/"
    mkdir -p ${DEST_DIR}${LOG_DIR}
    LOG_FILE=${DEST_DIR}${LOG_DIR}"riemann_backup.log"
    echo "* BACKUP RIEMANN" >> ${LOG_FILE}
    echo "  --------------------------------"  >> ${LOG_FILE}
    echo "  Started @ "${start_time}           >> ${LOG_FILE}
    echo "  Ended   @ "${end_time}             >> ${LOG_FILE}
    echo "  --------------------------------"  >> ${LOG_FILE}

################################################################################
##                                  HILBERT                                   ##
################################################################################
elif [ "${HOSTNAME}" == "hilbert" ]
then
    # -- Source directories --
    ROOT_DIR=${HOME}"/"
    LAB_SRC="LAB/"

    # -- Ask for confirmation --
    echo "Hostname:" ${HOSTNAME}
    echo ">> Gonna backup the following dirs to:" ${DEST_DIR}
    echo "   -- " ${LAB_SRC}

    while true; do
        read -p ">> Continue (y/n)?" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo ">> OK. Goodbye!";exit;;
            * ) echo "## Please answer (y)es or (n)o...";;
        esac
    done

    # -- Back Up DIRs --
    echo ">> Backing up..."

    mkdir -p ${DEST_DIR}${HOSTNAME}

    # -- Get start time --
    date=$(date +'%Y-%m-%d %H:%M:%S')
    read Y M D h m s <<< ${date//[-: ]/ };
    start_time="$Y-$M-$D @ $h:$m:$s"

    # -- LAB_SRC --
    echo -n "   -- " ${LAB_SRC}...
    ${rsync_cmd} ${rsync_opt} ${ROOT_DIR}${LAB_SRC} ${DEST_DIR}${LAB_SRC} && echo "done!"

    # -- Get end time --
    date=$(date +'%Y-%m-%d %H:%M:%S')
    read Y M D h m s <<< ${date//[-: ]/ };
    end_time="$Y-$M-$D @ $h:$m:$s"

    # -- Append to a log file --
    echo ""
    echo ">> Backup complete!"
    echo "   -------------------------------"
    echo "   Started @ "${start_time}
    echo "   Ended   @ "${end_time}
    echo "   -------------------------------"

    LOG_DIR=".log/"
    mkdir -p ${DEST_DIR}${LOG_DIR}
    LOG_FILE=${DEST_DIR}${LOG_DIR}"riemann_backup.log"
    echo "* BACKUP RIEMANN" >> ${LOG_FILE}
    echo "  --------------------------------"  >> ${LOG_FILE}
    echo "  Started @ "${start_time}           >> ${LOG_FILE}
    echo "  Ended   @ "${end_time}             >> ${LOG_FILE}
    echo "  --------------------------------"  >> ${LOG_FILE}

################################################################################
##                              UNKNOWN HOSTNAME                              ##
################################################################################
else
    echo " ## Error: Unknown hostname: ${HOSTNAME}"
    echo "    -- Goodbye!";
    exit;
fi
