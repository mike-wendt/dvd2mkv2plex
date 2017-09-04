#!/bin/bash

### START CONFIG ###

# number of seconds to wait before checking for a disc
SLEEP=30

# file to keep track of copied discs
COMPLETEDFILE="0done.list"

# working dir for copying DVD to ISO
WORKDIR="$PWD/0COPYING"

# location to save ISOs
OUTPUTDIR="/data/mirror0/ripping"

### END CONFIG ###

# grab drive number to use
DRIVE=$1

# setup environment
touch $COMPLETEDFILE
mkdir -p $WORKDIR

function logger {
  TS=`date`
  echo "[${TS}] $@"
}

function ejectdisc {
  sudo eject /dev/sr${DRIVE}
}

function waitfordisc {
  CHECKDISC=`ls -la /dev/disk/by-label/ | grep sr${DRIVE}`
  
  if [ $? -eq 0 ]; then
    logger "INFO: Disc detected... Processing..."
    processdisc
  else
    logger "INFO: No disc found... Sleeping ${SLEEP} sec..."
    sleep $SLEEP
  fi
  waitfordisc
}

function processdisc {
  # check if disc processed
  NAME=`ls -la /dev/disk/by-label/ | grep sr${DRIVE} | awk '{ print $9 }'`
  PROCESSED=`grep $NAME ${COMPLETEDFILE}`

  if [ $? -eq 0 ]; then
    logger "ERROR: Disc already processed... $PROCESSED"
    ejectdisc
    sleep $SLEEP
    waitfordisc
  else
    echo "DISC NAME: $NAME"
    echo -n "Enter new name or press [ENTER] to continue: "
    read NEWNAME
    if [ "$NEWNAME" != "" ]; then
      NAME="${NEWNAME}"
    fi
    logger "INFO: Disc not copied... Starting process for disc '$NAME'"
  fi

  # mount to get size
  sudo mkdir -p /media/cdrom${DRIVE}
  sudo mount /dev/sr${DRIVE} /media/cdrom${DRIVE} &> /dev/null
  SIZE=`df | grep sr${DRIVE} | awk '{ print $2 }'`
  sudo umount /dev/sr${DRIVE}
  
  # start copy
  sudo dd if=/dev/sr${DRIVE} | pv -s ${SIZE}K | dd of=${WORKDIR}/${NAME}.iso bs=2048 conv=noerror,notrunc

  # disc processed
  logger "INFO: Disc copied... Ejecting disc..."
  logger "$NAME" >> ${COMPLETEDFILE}

  # eject disc
  ejectdisc
  
  # move ISO
  logger "INFO: Moving ISO..."
  mv ${WORKDIR}/${NAME}.iso ${OUTPUTDIR}
  logger "INFO: ISO moved..."

  #wait for next disc
  sleep $SLEEP
  waitfordisc
}

# main process kick off
waitfordisc
