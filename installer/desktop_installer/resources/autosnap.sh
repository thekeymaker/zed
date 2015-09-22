#!/bin/bash

set -x
 
# Path to ZFS executable:
ZFS=/sbin/zfs
 
# Parse arguments:
TARGET=$1
SNAPTYPE=$2
COUNT=$3
MAXSNAP=$(($COUNT -1))

# First delete the oldest backup
$ZFS destroy -r ${TARGET}@autobak.${SNAPTYPE}.${MAXSNAP}
 
# Rename existing snapshots:
INDEX=$(($MAXSNAP -1))
while [ $INDEX -ge 0 ] ; do
	NEWNUM=$(($INDEX +1))
    $ZFS rename -r ${TARGET}@autobak.${SNAPTYPE}.${INDEX} ${TARGET}@autobak.${SNAPTYPE}.${NEWNUM}
	INDEX=$(($INDEX -1))
done
 
# Create new snapshot:
$ZFS snapshot -r ${TARGET}@autobak.${SNAPTYPE}.0
