#!/bin/bash

ROOT_UID=0 # Only users with $UID 0 have root privileges.
E_NOTROOT=67 # Non-root exit error.

# Run as root
if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Must be root to install the kernel."
    exit $E_NOTROOT
fi

make 

make modules_install install 
