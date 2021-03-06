# dvd2mkv2plex

Bash scripts to automate and speed-up the process of ripping a DVD collection into Plex using `dd, makemkvcon`

## Overview

High-level process:

1. Create ISO from DVD
2. Rip titles from ISO to MKV(s) and saving into Plex library

There are two main scripts:

1. `0copy.sh` or `0ask-name-copy.sh` - copies DVDs creating ISOs for ripping, auto ejecting DVDs when finished
2. `1rip.sh` - rips titles from ISO creating and saving MKVs into Plex Library

## Prereqs

Tested with Debian 8.9, should work with Ubuntu 14.04+ but YMMV

1. Install MakeMKV for linux: http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224&sid=a9796012caafc26c5e825afaa60647b6
2. Install tools used by the scripts:
```
sudo apt-get update
sudo apt-get install -y eject pv
```
## Config

All three scripts have config vars at the beginning of each script that need to be set for your environment before using

### Notable Config Vars

* `1rip.sh`
  * `MINIMUM_SECS_TO_SAVE` - minimum number of seconds a title should be to rip
  * `PREFIX` - controls naming of multiple titles, see [File Naming](#file-naming)
  
## Usage

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

***automatic copy***
```
./0copy.sh 0 2>&1 | tee -a copy-drive0.log
```

***confirmation copy***
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

### Loading DVDs

#### Using `0copy.sh`

1. Insert DVD to copy in drive and close
2. Monitor copy script for progress of copy
3. Remove copied DVD when disk is ejected
4. Continue with **Step 1**

#### Using `0ask-name-copy.sh`

1. Insert DVD to copy in drive and close
2. Confirm name for DVD or change to allow copy to proceed
3. Monitor copy script for progress of copy
4. Remove copied DVD when disk is ejected 
5. Continue with **Step 1**

## File Naming

By default MKV files are named from the name of the DVD when using `0copy.sh` or the confirmed/entered name when using `0ask-name-copy.sh` 

**NOTE:** Naming for MKV files/folders remove chars `-_` and replace them with ` ` as well as capitalizing the first letter of every word

### Example #1 - Default Naming

#### Single Title DVDs

* DVD Name - `RAILWAY_JOURNEYS_5`
* ISO Name - `RAILWAY_JOURNESY_5.iso`
* MKV Name - `Railway Journeys 5.mkv`

#### Multi Title DVDs

* DVD Name - `WORLDS_GREATEST_RAILROADS_2`
* ISO Name - `WORLDS_GREATEST_RAILROADS_2.iso`
* MKV Names:
```
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-part1.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-part2.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-part3.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-part4.mkv
```

### Example #2 - Custom Prefix for Multi Title DVDs

You can edit the config var `PREFIX` in `1rip.sh` to change how files with multiple titles are named

#### Setting `PREFIX="-Scene-"`

* DVD Name - `WORLDS_GREATEST_RAILROADS_2`
* ISO Name - `WORLDS_GREATEST_RAILROADS_2.iso`
* MKV Names:
```
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-Scene-1.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-Scene-2.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-Scene-3.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-Scene-4.mkv
```

#### Setting `PREFIX="-s00e0"`

* DVD Name - `WORLDS_GREATEST_RAILROADS_2`
* ISO Name - `WORLDS_GREATEST_RAILROADS_2.iso`
* MKV Names:
```
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-s00e01.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-s00e02.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-s00e03.mkv
Worlds Greatest Railroads 2/Worlds Greatest Railroads 2-s00e04.mkv
```

## Help & Issues

Please file and issue if you encounter any errors or would like additional features. Stars are always welcome!
