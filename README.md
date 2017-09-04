# dvd2mkv2plex

Bash scripts to automate and speed-up the process of ripping a DVD collection into Plex using `dd, makemkvcon`

## Overview

High-level process:

1. Create ISO from DVD
2. Rip titles from ISO to MKV(s) and saving into Plex library

There are two main scripts:

1. `0copy.sh` or `0ask-name-copy.sh`
2. `1rip.sh` - rips titles from ISO creating and saving MKVs into Plex Library

## Prereqs

Tested with Debian 8.9, should work with Ubuntu 14.04+

Install some useful tools:

```
sudo apt-get update
sudo apt-get install eject pv
```

Install MakeMKV for linux: http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224&sid=a9796012caafc26c5e825afaa60647b6

## Setup

Helpful tips:
* It is a good idea to run the following commands in `screen` in case there is a disconnect
* Also good to add `2>&1 | tee -a progress.log` to commands, changing the log file so you can track progress or see where errors occurred

### Start Copy Process

Decide on which method to use: **automatic copy** or **confirmation copy** 

* **automatic copy** uses `0copy.sh` and uses the DVD's name as a way to check if the DVD has been copied & what name to save the ISO as
* **confirmation copy** uses `0ask-name-copy.sh` and will prompt the user to confirm the DVD name that was read or enter a new one
 * This is helpful when you have a lot of home movies or other non standard DVDs with the same name

#### Determine Drives

For Debian the DVD drives are listed as `/dev/sr#` where `#` is a number starting at `0` and increasing for every additional DVD drive

Run the following to list the drives in your system

```
ls /dev/sr*
```

#### Single DVD System

**automatic copy**

```
./0copy.sh 0 2>&1 | tee -a copy-drive0.log
```

**confirmation copy**

```
./0ask-name-copy.sh 0 2>&1 | tee -a copy-drive0.log
```

#### Multi DVD System

Use the same commands as in **Single DVD System** but start an additional copy script for each drive number

For example a 2 drive system would have the following commands run in separate `screen` windows:

```
./0copy.sh 0 2>&1 | tee -a copy-drive0.log

./0copy.sh 1 2>&1 | tee -a copy-drive1.log
```

### Start Ripper

Only one instance of this script needs to run, be sure to run this in `screen` as well so it can continue to rip new ISOs as they are created

```
./1rip.sh 2>&1 | tee -a rip.log
```

## Usage

### Using `0copy.sh`

1. Insert DVD to copy in drive and close
2. Monitor copy script for progress of copy
3. Remove copied DVD when disk is ejected
4. Continue with **Step 1**

### Using `0ask-name-copy.sh`

1. Insert DVD to copy in drive and close
2. Confirm name for DVD or change to allow copy to proceed
3. Monitor copy script for progress of copy
4. Remove copied DVD when disk is ejected 
5. Continue with **Step 1**

## Help & Issues

Please file and issue if you encounter any errors or would like additional features. Stars are always welcome!
