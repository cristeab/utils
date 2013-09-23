#!/bin/bash

# Wrapper script around mysqladmin and mysql utilities.
# The following commands are available:
# - "-p" set password for root user of MySQL server (this shall work only when no password was set for mysql server)
# - "-c" change the password for root user
# - "-l" list all databases
# - "-n" create new database
# - "-d" drop given database
# - "-a" load all database dumps from given folder
# - "-u" upload given database to mysql database (a second argument can be specified as the database name)
# - "-g" grant access to a given user to a database from any machine (including localhost)
# - "-r" grant read only access to a given user to a database from any machine (including localhost)
# - "-b" backup (dump) a given database
# - "-h" display this help message

E_SUCCESS=0
E_FAILURE=1
E_WRONGARGS=65

case "$1" in
	"-p") #this shall work only when no password was set for mysql server
		read -s -p "Password for root user of MySQL server: " NEW_PWD
		echo
		read -s -p "Confirm password: " PWD_CONFIRM
		echo
		if [ $NEW_PWD == $PWD_CONFIRM ] 
		then
			echo -n "Setting password "
			mysqladmin -u root password $NEW_PWD
			if [ $? -eq $E_SUCCESS ]
			then
				echo -e "\t\t\tdone"
			fi
		else
			echo "Passwords don't match"
			exit $E_FAILURE
		fi ;;
	"-c") #this shall work when a password was already set and you want to change it
		read -s -p "Old password for root user of MySQL server: " OLD_PWD
		echo
		read -s -p "New password: " NEW_PWD
		echo
		read -s -p "Confirm new password: " PWD_CONFIRM
		echo
		if [ $NEW_PWD == $PWD_CONFIRM ] 
		then
			echo -n "Setting password "
			mysqladmin -u root --password=$OLD_PWD password $NEW_PWD
			if [ $? -eq $E_SUCCESS ]
			then
				echo -e "\t\t\tdone"
			fi
		else
			echo "Passwords don't match"
			exit $E_FAILURE
		fi ;;
	"-l") #list all databases
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		mysql -u root --password=$MYSQL_PWD -e "show databases" ;;
	"-n") #create new database
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		read -p "Database name: " DB_NAME
		echo -n "Creating database $DB_NAME "
		mysql -u root --password=$MYSQL_PWD -e "create database $DB_NAME"
		if [ $? -eq $E_SUCCESS ]
		then
			echo -e "\t\t\tdone"
		fi ;;
	"-d") #drop database
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		mysql -u root --password=$MYSQL_PWD -e "show databases"
		if [ $? -ne $E_SUCCESS ]
		then
			exit $E_FAILURE
		fi
		read -p "Database name to drop: " DB_NAME
		echo -n "Droping database $DB_NAME "
		mysql -u root --password=$MYSQL_PWD -e "drop database $DB_NAME"
		if [ $? -eq $E_SUCCESS ]
		then
			echo -e "\t\t\tdone"
		fi ;;
	"-a") #load all database dumps from given folder
		read -p "Folder where MySQL dump files reside: " DB_FOLDER
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		for file in $DB_FOLDER/*.sql
		do
			if [ -f $file ]
			then
				echo -n "Loading $file "
				db_name=`basename $file .sql`
				mysql -u root --password=$MYSQL_PWD $db_name < $file
				if [ $? -eq $E_SUCCESS ]
				then
					echo -e "\t\t\tdone"
				fi
			fi
		done ;;
	"-u") #upload given database to mysql database (a second argument can be specified as the database name)
		read -p "MySQL dump file name: " DB_FILE
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		echo -n "Loading $DB_FILE "
		if [ $# == 2 ]
		then
			mysql -u root --password=$MYSQL_PWD $2 < $DB_FILE
		else
			mysql -u root --password=$MYSQL_PWD < $DB_FILE
		fi
		if [ $? -eq $E_SUCCESS ]
		then
			echo -e "\t\t\tdone"
		fi ;;
	"-g") #grant full access to a given user to a database from any machine (including localhost)
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		read -p "User name: " USER_NAME
		read -s -p "User password: " USER_PWD
		echo
		read -s -p "Confirm user password: " PWD_CONFIRM
		echo
		if [ $USER_PWD != $PWD_CONFIRM ] 
		then
			echo "Passwords don't match"
			exit $E_FAILURE
		fi
		mysql -u root --password=$MYSQL_PWD -e "show databases"
		while [ 0 ]; do
		  read -p "Database name: " DB_NAME
		  echo -n "Granting all privileges on $DB_NAME to $USER_NAME "
		  mysql -u root --password=$MYSQL_PWD -e "grant all privileges on $DB_NAME.* to $USER_NAME@'%' identified by '$USER_PWD'"
		  RESULT=$?
		  mysql -u root --password=$MYSQL_PWD -e "grant all privileges on $DB_NAME.* to $USER_NAME@localhost identified by '$USER_PWD'"
		  if [ $RESULT -eq $E_SUCCESS ] && [ $? -eq $E_SUCCESS ]
		  then
			  echo -e "\t\t\tdone"
		  fi
		done ;;
	"-r") #grant read only access to a given user to a database from any machine (including localhost)
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo		
		read -p "User name: " USER_NAME
		read -s -p "User password: " USER_PWD
		echo
		read -s -p "Confirm user password: " PWD_CONFIRM
		echo
		if [ $USER_PWD != $PWD_CONFIRM ] 
		then
			echo "Passwords don't match"
			exit $E_FAILURE
		fi
		mysql -u root --password=$MYSQL_PWD -e "show databases"
		while [ 0 ]; do
		  read -p "Database name: " DB_NAME
		  echo -n "Granting read only privileges on $DB_NAME to $USER_NAME "
		  mysql -u root --password=$MYSQL_PWD -e "grant select on $DB_NAME.* to $USER_NAME@'%' identified by '$USER_PWD'"
		  RESULT=$?
		  mysql -u root --password=$MYSQL_PWD -e "grant select on $DB_NAME.* to $USER_NAME@localhost identified by '$USER_PWD'"
		  if [ $RESULT -eq $E_SUCCESS ] && [ $? -eq $E_SUCCESS ]
		  then
			  echo -e "\t\t\tdone"
		  fi 
		done ;;
	"-b") #backup (dump) a given database
		read -s -p "Password for root user of MySQL server: " MYSQL_PWD
		echo
		mysql -u root --password=$MYSQL_PWD -e "show databases"
		while [ 0 ]; do
		  read -p "Database name: " DB_NAME
		  echo -n "Backing up database $DB_NAME to file $DB_NAME.sql"
		  mysqldump -u root --password=$MYSQL_PWD $DB_NAME > "$DB_NAME".sql 
		  if [ $? -eq $E_SUCCESS ]
		  then
		    echo -e "\t\t\tdone"
		  fi 
		done ;;
	"-h")
		head -n 15 $0 ;;
	*) # unknown option
		echo "Unknown command"
		$0 -h
		exit $E_WRONGARGS ;;
esac
exit $E_SUCCESS
