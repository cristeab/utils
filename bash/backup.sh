#!/bin/bash

# Simple rsync "driver" script.  (Uses SSH as the transport layer.)
# http://www.scrounge.org/linux/rsync.html

# Demonstrates how to use rsync to back up a directory tree from a local
# machine to a remote machine.  Then re-run the script, as needed, to keep
# the two machines "in sync."  It only copies new or changed files and ignores
# identical files.

# Destination host machine name
DEST="cristea"

# User that rsync will connect as
# Are you sure that you want to run as root, though?
USER="bogdan"

# Directory to copy from on the source machine.
BACKDIR="/home/bogdan/"

# Directory to copy to on the destination machine.
DESTDIR="/home/bogdan/"

# excludes file - Contains wildcard patterns of files to exclude.
# i.e., *~, *.bak, etc.  One "pattern" per line.
# You must create this file.
EXCLUDES=/home/bogdan/excludes

#default behavior (-v)
OPTS="-v -u -a --rsh=ssh --exclude-from=$EXCLUDES --stats"

# Options.
# -n Don't do any copying, but display what rsync *would* copy. For testing.
# -a Archive. Mainly propogate file permissions, ownership, timestamp, etc.
# -u Update. Don't copy file if file on destination is newer.
# -v Verbose -vv More verbose. -vvv Even more verbose.
# See man rsync for other options.

E_WRONGARGS=65 # Bad argument error
E_SUCCESS=0
if [ $# -le 2 ] ; then
	case "$1" in
		"-n")
		# For testing.  Only displays what rsync *would* do and does no actual copying.
		OPTS="-n -vv -u -a --rsh=ssh --exclude-from=$EXCLUDES --stats --progress" ;;
		"-v")
		# Does copy, but still gives a verbose display of what it is doing
		OPTS="-v -u -a --rsh=ssh --exclude-from=$EXCLUDES --stats" ;;
		"-q")
		# Copies and does no display at all.
		OPTS="-u -a --rsh=ssh --exclude-from=$EXCLUDES --quiet" ;;
		# Specify the destination address
		"-d")
		DEST=$2 ;;
		# Unknown option
		*)
		echo "Unknown option."
		echo -e "Use\n\t -d dst for backup to dst IP address\n\t -n for a dry run\n\t -v for verbose output (default)\n\t -q for no output"
		exit $E_WRONGARGS ;;
	esac
fi

# Only run rsync if $DEST responds.
ping -s 1 -c 1 $DEST > /dev/null
if [ $? -eq 0 ]; then
    rsync $OPTS $BACKDIR $USER@$DEST:$DESTDIR
else
    echo "Cannot connect to $DEST"
fi

