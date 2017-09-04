#!/bin/bash

### START CONFIG ###

# secs to wait before scanning for new files
SLEEP=90

# file to keep list of processed files
COMPLETEDFILE="1done.list"

# working dir for titles ripped
WORK_DIR="$PWD/1RIPPING"

# location to search for '*.iso' files
ISO_DIR="/data/mirror0/ripping"

# location to move processed ISO files
ISO_DONE_DIR="${ISO_DIR}/1RIPPED"

# directory to save MKV files and folders
PLEX_DIR="/data/mirror0/plex/pennsy"

# do not rip titles shorter than
MINIMUM_SECS_TO_SAVE=240

# for ISOs with multiple titles what is the prefix to the number
## example: <ISO_NAME>/<ISO_NAME>-<PREFIX><TITLE_NUMBER>.mkv
#PREFIX="-Scene-"
PREFIX="-part"

### END CONFIG ###


# environment setup
touch $COMPLETEDFILE
mkdir -p $ISO_DONE_DIR

function logger {
  TS=`date`
  echo "[${TS}] $@"
}

function listfiles {
  for FILE in ${ISO_DIR}/*.iso; do
    processfile $FILE
  done
  logger "INFO: Scan complete, waiting $SLEEP secs before rescanning..."
  sleep $SLEEP
  listfiles
}

function processfile {
  FILEPATH=$1
  FILENAME=`basename $FILEPATH`

  # capitalize first letters of each word
  RAWNAME=`echo $FILENAME | tr '.' ' ' | tr '-' '_' | awk '{ print $1 }' | tr '_' ' ' | tr '[:upper:]' '[:lower:]'`
  B=( $RAWNAME )
  NAME="${B[@]^}"
  
  # check if file processed
  PROCESSED=`grep $FILENAME ${COMPLETEDFILE}`
  if [ "$RAWNAME" == "*" ]; then
    logger "ERROR: No files found..."
    return
  elif [ "$PROCESSED" != "" ]; then
    logger "ERROR: File already processed... $PROCESSED"
    mv $FILEPATH /data/mirror0/ripping/0DONE
    return
  fi
  
  # clean working dir
  rm -rf $WORK_DIR
  mkdir $WORK_DIR

  # rip titles
  logger "INFO: Starting ripping for DVD - '$NAME'" 
  makemkvcon --minlength=$MINIMUM_SECS_TO_SAVE mkv iso:$FILEPATH all $WORK_DIR
  NUMTITLES=`ls $WORK_DIR | wc | awk '{ print $1 }'`
  logger "INFO: $NUMTITLES title(s) ripped..."
  
  # remove current data
  rm -rf "$PLEX_DIR/${NAME}"
  rm -f "$PLEX_DIR/${NAME}.mkv"

  # make directory if multiple titles
  if [ "$NUMTITLES" != "1" ]; then
    mkdir "$PLEX_DIR/${NAME}"
    chmod 775 "$PLEX_DIR/${NAME}"
  fi

  # process each title
  COUNTER=1
  for TITLE in $WORK_DIR/*.mkv; do
    if [ "$NUMTITLES" == "1" ]; then
      SAVENAME="${NAME}.mkv"
    else
      SAVENAME="${NAME}/${NAME}-${PREFIX}${COUNTER}.mkv"
    fi
    
    # file processed
    logger "INFO: Moving to Plex (${COUNTER}/${NUMTITLES})..."
    mv ${TITLE} "$PLEX_DIR/${SAVENAME}"
    chmod 664 "$PLEX_DIR/${SAVENAME}"
    (( COUNTER++ ))
  done
  
  # move ISO
  logger "INFO: Marking ISO ripped and moving..."
  logger "$FILENAME" >> ${COMPLETEDFILE}
  mv $FILEPATH $ISO_DONE_DIR
}

# main process kick off
listfiles
