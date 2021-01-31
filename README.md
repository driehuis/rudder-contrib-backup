# backup-rudder-contrib #

Scripts to backup Rudder to a directory. Includes

* Housekeeping
* Nagios check

## Configuration ##

The backup script itself should not need modifications (if it does,
please open up an issue).

The following settings can be modified in `/etc/rudder-backup/backup.conf`.
For the default file paths, the package install script sets up suitable
directory protections; if you change the paths you must do this yourself.

* `backup_dir`: where to store the backups. Make sure this path is included
  in your backups. Defaults to `/var/backups/rudder-backup`.

* `backup_retention`: how many days to keep backups. Used with find(1) to clean up old
  backups. Does not take backup frequency into account, i.e.
  if you want to keep 3 weekly backups, set this to 21. The included
  /etc/cron.d/rudder-agent creates daily backups; edit this file to suit.
  Defaults to 3 days.

* `last_success_marker_file`: Where to record the last successful backup.
  Used by the included nagios-style check script.
  Defaults to `/var/lib/rudder-backup/last-success.txt`.

* `backup_logs`: Whether or not to include the logs in the backup. Defaults to
  "no". Valid values are "yes" or "no".

* `pg_user`: the Postgres OS user to run the backup. Defaults to `postgres`.

## Packaging and OS support ##

The included packaging scripts generate a Debian style install package, and converts
that to RPM format. The packaging does not use the latest package configuration,
to maximize the chance that the generated package will work on old (as in really old)
flavors of Debian and Ubuntu.

## Testing for compatability ##

The scripts have been tested on Ubuntu bionic. The minimum OS requirement is a find(1) that
supports `-mmin` and `-delete`. This should be no problem on any currently supported OS release.
Let me know if you require support for older versions of find and I'll try to find a solution.
The author has not personally tested the support of Redhat flavors. To test, run the
backup script as root:

````
sudo rudder-contrib-backup
````

This should produce no output other than "backup successful".

Obviously, it is recommended to do a full restore test.
