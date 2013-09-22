#!/bin/bash

# This script must be run on a host computer
# Creates a new partition table on compact flash (CF)
# Populates CF with a file system tree for Multi-Function Driver (MFD):
# $MOUNT_POINT/bin
# $MOUNT_POINT/lib
# $MOUNT_POINT/mfd/bin
# $MOUNT_POINT/mfd/lib
# $MOUNT_POINT/mfd/send
# $MOUNT_POINT/mfd/recv
# $MOUNT_POINT/mfd/log

#help message
if [ $# -eq 1 ] && [ $1 == "help" ]
then
  head -n 13 $0
  exit 0
fi

# device related variables
DEFAULT_DEVICE=/dev/sdc
DEFAULT_MOUNT_POINT=/media/cf
FS_TYPE=ext2

# path to system utilies and applications
DEFAULT_MFD_PATH=/pub/nfsroot/home/mfdriver/workspace # below this path lib and bin folders must reside
DEFAULT_MFD_CONFIG_FILE=/home/bogdan/Programs/SiLabs/mfd/config.xml 
LIB_PATH=/pub/nfsroot/lib
LIBS="libtiff.so.3.8.2 libxml2.so.2.6.17 libjpeg.so.62"
BIN_PATH=/pub/nfsroot/bin
BINS="lsof strace vi ldd"
DEFAULT_TIFF_PATH=/pub/nfsroot/var/spool/mfd/send #should contain TIFF files to be send
SCRIPT_FILES="/home/bogdan/BashScript/setupViper.sh /home/bogdan/BashScript/setTime.sh"

# environment related variables
ROOT_UID=0 # Only users with $UID 0 have root privileges.
E_NOTROOT=67 # Non-root exit error.
E_SUCCESS=0

# run as root
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

# get path to device
read -p "Path to device [$DEFAULT_DEVICE]: " DEVICE
if [ -z $DEVICE ]
then
  DEVICE=$DEFAULT_DEVICE
fi

#unmount function definition
umount_CF ()
{
  mount | grep "${DEVICE}1" > /dev/null
  if [ $? -eq $E_SUCCESS ] #device already mounted
  then
    umount ${DEVICE}1
  fi
}

# create a new partition table on device
echo -n -e "\nCreate a new partition table on $DEVICE [Y/n]: " 
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER == "y" ] || [ $ANSWER == "Y" ]
then
  echo "Use d to erase existing partitions"
  echo "    n to create a new partition"
  echo "    p to create a primary partition"
  echo "    1 (one) to set the partition number"
  echo "    press ENTER two times to accept default values"
  echo "    w to write current changes"
  umount_CF
  fdisk $DEVICE

  # format the newly created partition table
  echo -e "\nFormating the newly created partition table with $FS_TYPE\n"
  umount_CF
  mkfs.$FS_TYPE ${DEVICE}1
fi

# create a new folder where the CF should be mounted
echo -n -e "\nCreate mount point [$DEFAULT_MOUNT_POINT]: "
read MOUNT_POINT
if [ -z $MOUNT_POINT ]
then
  MOUNT_POINT=$DEFAULT_MOUNT_POINT
fi
mkdir -p $MOUNT_POINT

# mount CF if needed
mount | grep "${DEVICE}1" > /dev/null
if [ $? -ne $E_SUCCESS ] #device not mounted
then
  echo -n "Mounting CF to $MOUNT_POINT"
  mount -t $FS_TYPE ${DEVICE}1 $MOUNT_POINT
  if [ $? -eq 0 ]
  then
    echo -e "\t\t\tdone"
  fi
fi

# get path where MFD libraries and binaries reside on host
echo -n -e "\nCopy MFD libraries and binaries from\n[$DEFAULT_MFD_PATH]:\n"
read MFD_PATH
if [ -z $MFD_PATH ]
then
  MFD_PATH=$DEFAULT_MFD_PATH
fi

# get path to MFD configuration file
echo -n -e "\nCopy MFD configuration file from\n[$DEFAULT_MFD_CONFIG_FILE]:\n"
read MFD_CONFIG_FILE
if [ -z $MFD_CONFIG_FILE ]
then
  MFD_CONFIG_FILE=$DEFAULT_MFD_CONFIG_FILE
fi

# get path to TIFF files to send
echo -n -e "\nCopy TIFF files from\n[$DEFAULT_TIFF_PATH]:\n"
read TIFF_PATH
if [ -z $TIFF_PATH ]
then
  TIFF_PATH=$DEFAULT_TIFF_PATH
fi

# creating CF file system
echo -n -e "\nCreating file system on $MOUNT_POINT "

#system libraries and binaries
mkdir -p $MOUNT_POINT/lib
for lib in $LIBS
do
  cp $LIB_PATH/$lib $MOUNT_POINT/lib
done
mkdir -p $MOUNT_POINT/bin
for bin in $BINS
do
  cp $BIN_PATH/$bin $MOUNT_POINT/bin
done

#MFD libraries and binaries
mkdir -p $MOUNT_POINT/mfd
cp -r $MFD_PATH/lib $MOUNT_POINT/mfd
cp -r $MFD_PATH/bin $MOUNT_POINT/mfd
cp $MFD_CONFIG_FILE $MOUNT_POINT/mfd/bin
mkdir -p $MOUNT_POINT/mfd/send
cp $TIFF_PATH/*.tif $MOUNT_POINT/mfd/send
mkdir -p $MOUNT_POINT/mfd/recv
mkdir -p $MOUNT_POINT/mfd/log

#copy Viper setup scripts
for script in $SCRIPT_FILES
do
  cp $script $MOUNT_POINT
done

echo -e "\t\tdone"

#force changes to take effect
echo -n "Unmounting CF"
umount ${DEVICE}1
if [ $? -eq 0 ]
then
  echo -e "\t\t\t\t\tdone"
fi

