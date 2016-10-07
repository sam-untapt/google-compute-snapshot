#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/:/usr/bin

if [ $# -eq 0 ]
  then
    echo "Please pass the instance name"
    return 
fi

#
# CREATE DAILY SNAPSHOT
#

# set the device name
DEVICE_NAME="$1"

# get the zone  for this device
INSTANCE_ZONE="$(gcloud compute instances list $DEVICE_NAME | grep $DEVICE_NAME | cut -d " " -f 3)"

# get the device id for this device
DEVICE_ID="$(gcloud compute instances describe $DEVICE_NAME --zone ${INSTANCE_ZONE} | grep id: | sed s/id:// | sed s/"'"//g | sed -e 's/^[ \t]*//')"

# create a datetime stamp for filename
DATE_TIME="$(date "+%s")"

# create the snapshot
gcloud compute disks snapshot ${DEVICE_NAME} --no-user-output-enabled --snapshot-names gcs-${DEVICE_NAME}-${DEVICE_ID}-${DATE_TIME} --zone ${INSTANCE_ZONE}


#
# DELETE OLD SNAPSHOTS (OLDER THAN 7 DAYS)
#

# get a list of existing snapshots, that were created by this process (gcs-), for this vm disk (DEVICE_ID) and save to file for reference
gcloud compute snapshots list --regexp "(.*gcs-${DEVICE_NAME}-.*)" --uri > snapshot_list_$DEVICE_NAME.txt

# loop through the snapshots
cat snapshot_list_$DEVICE_NAME.txt | while read line ; do

# DELETE OLD SNAPSHOTS (OLDER THAN 7 DAYS)
   SNAPSHOT_NAME="${line##*/}"

   # get the date that the snapshot was created
   SNAPSHOT_DATETIME="$(gcloud compute snapshots describe ${SNAPSHOT_NAME} | grep "creationTimestamp" | cut -d " " -f 2 | tr -d \')"

   # format the date
   SNAPSHOT_DATETIME="$(date -d ${SNAPSHOT_DATETIME} +%Y%m%d)"

   # get the expiry date for snapshot deletion (currently 7 days)
   SNAPSHOT_EXPIRY="$(date -d "-7 days" +"%Y%m%d")"

   # check if the snapshot is older than expiry date
if [ $SNAPSHOT_EXPIRY -ge $SNAPSHOT_DATETIME ];
        then
         # delete the snapshot
         echo "$(gcloud compute snapshots delete ${SNAPSHOT_NAME} --quiet --no-user-output-enabled)"
   fi
done
