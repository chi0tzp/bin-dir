#!/bin/bash
################################################################################
## getopts demo: get a directory                                              ##
################################################################################

DIR=""
while getopts d: opt; do
  case $opt in
  d)
      if [ "${OPTARG: -1}" != "/" ]
      then
        OPTARG=${OPTARG}"/"
      fi
      DIR="${OPTARG}"
      ;;
  esac
done
shift $((OPTIND - 1))

if [[ -z "${DIR}" ]]
then
    echo "Option -d missing. Abort!"
    exit;
fi
echo "Given dir: ${DIR}"
