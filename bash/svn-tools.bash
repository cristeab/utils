#!/bin/bash

#*******************************************************************#
#                          svn-tools.bash                           #
#                    written by Bogdan Cristea                      #
#                       March 08, 2008                              #
#                                                                   #
#          Tools for subversion repository manipulation             #
#*******************************************************************#

# Exit codes
E_WRONGARGS=65 # Bad argument error
E_SUCCESS=0

# Internal variables
TMP_DIR_NAME=/tmp
SVNADMIN_REPO_PATH=/home/bogdan/svnrepo
#REPO_PATH=file:///home/bogdan/svnrepo
REPO_PATH=http://localhost/svn
#REPO_OWNER=svnadmin

# Internal functions
makedir() # prepares a new project for svn repository, input parameter is project name
{
	read -p "Items to include into project trunk ? " FILES_TO_COPY
	mkdir -pv "$TMP_DIR_NAME"
	mkdir -pv "$TMP_DIR_NAME"/"$1"/
	mkdir -pv "$TMP_DIR_NAME"/"$1"/trunk
	mkdir -pv "$TMP_DIR_NAME"/"$1"/tags
	mkdir -pv "$TMP_DIR_NAME"/"$1"/branches
	mv -v $FILES_TO_COPY "$TMP_DIR_NAME"/"$1"/trunk
}

import() # import project into an already created repository (aka project category: Matlab, C++ etc.), first input parameter is project category, second input parameter is project name
{
	svn import "$TMP_DIR_NAME"/"$2" "$REPO_PATH"/"$1"/"$2" -m "initial import"
}

checkout() # initial checkout of created project from trunk into current directory, first input parameter is project category, second input parameter is project name
{
	svn co "$REPO_PATH"/"$1"/"$2"/trunk .
	svn up
	svn log
}

# Check for inputs
case "$1" in
    "at") # auto option, execute sequentially md, im and co
	read -p "Repository name ? " REPO_NAME
	read -p "Project name ? " PRJ_NAME
	makedir "$PRJ_NAME"
	import "$REPO_NAME" "$PRJ_NAME"
	checkout "$REPO_NAME" "$PRJ_NAME" ;;
    "md") # prepares a new project for svn repository
	read -p "Project name ? " PRJ_NAME
	makedir "$PRJ_NAME" ;;
    "mt") # make tag
	read -p "Repository name ? " REPO_NAME
	read -p "Project name ? " PRJ_NAME
	read -p "Tag name ? " TAG_NAME
	svn copy "$REPO_PATH"/"$REPO_NAME"/"$PRJ_NAME"/trunk \
		 "$REPO_PATH"/"$REPO_NAME"/"$PRJ_NAME"/tags/"$TAG_NAME" \
		 -m "`echo Tagging "$TAG_NAME" release of the "$PRJ_NAME" project`" ;;
    "mb") # make branch
	read -p "Repository name ? " REPO_NAME
	read -p "Project name ? " PRJ_NAME
	read -p "Branch name ? " BRANCH_NAME
	svn copy "$REPO_PATH"/"$REPO_NAME"/"$PRJ_NAME"/trunk \
		 "$REPO_PATH"/"$REPO_NAME"/"$PRJ_NAME"/branches/"$BRANCH_NAME" \
		 -m "`echo Branch "$BRANCH_NAME" of the "$PRJ_NAME" project`" ;;
    "im") # import project into an already created repository
	read -p "Repository name ? " REPO_NAME
	read -p "Project name ? " PRJ_NAME
	import "$REPO_NAME" "$PRJ_NAME" ;;
     "co") # initial checkout of created project from trunk into current directory
	read -p "Repository name ? " REPO_NAME
	read -p "Project name ? " PRJ_NAME
	checkout "$REPO_NAME" "$PRJ_NAME" ;;
     "cr") # create repository
	read -p "Repository name ? " REPO_NAME
	svnadmin create "$SVNADMIN_REPO_PATH"/"$REPO_NAME"
	sudo chown -R wwwrun "$SVNADMIN_REPO_PATH"/"$REPO_NAME" ;;
#	sudo -u "$REPO_OWNER" svnadmin create "$SVNADMIN_REPO_PATH"/"$REPO_NAME"
#	sudo -u "$REPO_OWNER" chmod -R g+w "$SVNADMIN_REPO_PATH"/"$REPO_NAME" ;;
     "ls") #list existing projects in a given repository
	read -p "Repository name ? " REPO_NAME
	svn list -R "$REPO_PATH"/"$REPO_NAME" ;;
     "-h") # help messages
	echo "Available commands:"
	echo "at - auto option, execute sequentially md, im and co"
	echo "md - prepares a new project for svn repository"
	echo "mt - makes tag of a project with given name (no spaces allowed)"
	echo "mb - makes branch of a project with given name (no spaces allowed)"
	echo "im - import project into an already created repository"
	echo "co - initial checkout of created project from trunk into current directory" 
	echo "cr - create repository" 
	echo "ls - list existing projects in a given repository" ;;
     *) # unknown option
	echo "Unknown command"
	$0 -h
	exit $E_WRONGARGS
esac
exit $E_SUCCESS
