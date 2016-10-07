# Google (gcloud) Compute Engine Snapshot

## Overview
* Takes a daily snapshot of a compute instance disk (that is accessible on the network) without any user input
* Deletes all snapshots that are older than 7 days (default)

## Prerequisites
* The VM must have the sufficient gcloud permissions, including "compute" set to "enabled":

	[	http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399](http://stackoverflow.com/questions/31905966/gcloud-compute-list-networks-error-some-requests-did-not-succeed-insufficie#31928399)

## Limitations
* Only manages snapshots created by the script

## Recommended Setup
* Load the script on to the VM (do not run it from a remote source)
* I use cronic - http://habilis.net/cronic/
* Run the script from a cron job.  Note this must be done as a user that has access to `gcloud compute`:

        0 05 * * * /usr/local/bin/cronic /path/to/snapshot.sh [INSTANCE_NAME] | tee /path/to/snapshot.log
      
* Add the `/var/log/cron` directory folder to logrotate: `/etc/logrotate.d/cron`

        /var/log/cron/*.log {
            daily
            missingok
            rotate 14
            compress
            notifempty
            create 664 root adm
            sharedscripts
        }


### Downloading the script and opening in Windows?

If you download the script and open it on a Windows machine, that may add windows character's to the file: https://github.com/Forward-Action/google-compute-snapshot/issues/1.
