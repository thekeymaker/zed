#!/bin/bash
 
# Function to display usage:
usage() {
    scriptname=`/usr/bin/basename $0`
    echo "$scriptname: Take and rotate snapshots on a ZFS file system"
    echo
    echo "  Usage:"
    echo "  $scriptname target snap_name count"
    echo
    echo "  target:    ZFS file system to act on"
    echo "  snap_name: Base part of name used to help define snapshot"
    echo "  count:     Number of snapshots in the snap_name.number format to"
    echo "             keep at one time.  Newest snapshot ends in '.0'."
    echo
    exit
}
                                                    
# Basic argument checks:
if [ -z $COUNT ] ; then
	usage
fi
                                                          
if [ ! -z $4 ] ; then
    usage
fi

# Path to ZFS executable:
ZFS=/sbin/zfs
 
# Parse arguments:
TARGET=$1
SNAPTYPE=$2
COUNT=$3
MAXSNAP=$(($COUNT -1))

# First delete the oldest backup
$ZFS destroy -r ${TARGET}@autosnap.${SNAPTYPE}.${MAXSNAP}
 
# Rename existing snapshots:
INDEX=$(($MAXSNAP -1))
while [ $INDEX -ge 0 ] ; do
	NEWNUM=$(($INDEX +1))
    $ZFS rename -r ${TARGET}@autosnap.${SNAPTYPE}.${INDEX} ${TARGET}@autosnap.${SNAPTYPE}.${NEWNUM}
	INDEX=$(($INDEX -1))
done
 
# Create new snapshot:
$ZFS snapshot -r ${TARGET}@autosnap.${SNAPTYPE}.0
