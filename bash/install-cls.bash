#!/bin/bash

#*****************************************************************#
#                        install_cls.bash                         #
#                    written by Bogdan Cristea                    #
#                        August 11, 2007                          #
#                                                                 #
#                      Installs LaTeX class                       #
#*****************************************************************#

ROOT_UID=0 # Only users with $UID 0 have root privileges.
E_NOTROOT=67 # Non-root exit error.
E_WRONGARGS=65 # Bad argument error
E_SUCCESS=0

BASE_DIR=/usr/share/texmf/ # LaTeX base directory 
CLS_DIR=tex/latex/ # directory for class installation
BIB_DIR=bibtex/bib/ # directory for *.bib file(s) installation
BST_DIR=bibtex/bst/ # directory for *.bst file(s) installation
SRC_CLS_DIR="" # source directory for file(s) to install

# Run as root
if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Must be root to run this script."
    exit $E_NOTROOT
fi

# Check for inputs
case "$1" in
    "") # no parameter
        echo "One parameter required! Use: `basename $0` class_name"
	exit $E_WRONGARGS ;;
    *) # get class name and ask for directory to look in for file(s) to install
        CLS_NAME=$1
	read -p "Path to the LaTeX class you want to install ? " SRC_CLS_DIR
esac

#install *.cls files if any (search in the current directory and in the directories below)
find "$SRC_CLS_DIR" -maxdepth 2 -name \*.cls -exec mkdir -p "$BASE_DIR""$CLS_DIR""$CLS_NAME" \; -exec cp -u -v '{}' "$BASE_DIR""$CLS_DIR""$CLS_NAME" \;

#install *.sty files if any (search in the current directory and in the directories below)
find "$SRC_CLS_DIR" -maxdepth 2 -name \*.sty -exec mkdir -p "$BASE_DIR""$CLS_DIR""$CLS_NAME" \; -exec cp -u -v '{}' "$BASE_DIR""$CLS_DIR""$CLS_NAME" \;

#install *.bib files if any (search in the current directory and in the directories below)
find "$SRC_CLS_DIR" -maxdepth 2 -name \*.bib -exec mkdir -p "$BASE_DIR""$BIB_DIR""$CLS_NAME" \; -exec cp -u -v '{}' "$BASE_DIR""$BIB_DIR""$CLS_NAME" \;

#install *.bst files if any (search in the current directory and in the directories below)
find "$SRC_CLS_DIR" -maxdepth 2 -name \*.bst -exec mkdir -p "$BASE_DIR""$BST_DIR""$CLS_NAME" \; -exec cp -u -v '{}' "$BASE_DIR""$BST_DIR""$CLS_NAME" \;

#update database
texhash

exit $E_SUCCESS
