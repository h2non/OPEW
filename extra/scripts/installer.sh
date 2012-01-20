#!/bin/bash
#
# OPEW auto-installer bash script
# This is a part of the OPEW project <http://opew.sourceforge.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	1.4 beta - 16/01/2012
#
# Copyright (C) 2011 - Tomas Aparicio
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

#
# THIS CODE STILL BETA
#

# config variables
VERSION="1.0.0 Beta RC4"
LOG="$PWD/opew-install.log"
FILES="$PWD/opew-files.log"
OPEW="/opt/"
LINES=40862
ERROR=0

# check PATH environment variable
if [ -z $PATH ]; then
	echo "The PATH environment variable is empty. Cannot continue with the installation process..."
	echo "Must be defined in order to run the installer properly. "
	echo "Please, copy and ejecute this (or your customized PATH environment): " 
	echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
	exit 1
fi

# clear old installation log files
function _debuglog(){
	if [ -s $LOG ]; then
		rm -f $LOG
		touch $LOG
	fi
	if [ -s $FILES ]; then
		rm -f $FILES
		touch $FILES
	fi 
}

function _welcome(){
	clear
	_debuglog
	echo "##############################################"
	echo "     OPEW - Open Web Development Stack " 
	echo "##############################################"
	echo " "
	echo "Version: $VERSION"
	echo " "
	echo "NOTICE: "
	echo "This is a beta public release candidate just for testing and experimental proposals and some packages maybe expected to be broken."
	echo "If you like OPEW, feel free to give me some feedback via <tomas@rijndael-project.com>. "
	echo " "
	read -p "Press enter to continue..."
	echo " "
	echo "OPEW is a complete, independent and extensible open distribution stack for GNU/Linux based OS."
        echo "Its goal is to provides a powerful and portable ready-to-run development environment focused on modern and robust (mainly web) programming languages. "
        echo "You can read more at the project page: <http://opew.sourceforge.net>"
	echo " "
	echo "Using OPEW you can deploy natively with the following open-source programming languages:"
	echo "- PHP "
	echo "- Perl "
	echo "- Python (experimental)"
	echo "- Ruby (experimental)"
	echo "- Node.js"
	echo "- Go (experimental)"
	echo "- Lua (experimental)"
	echo " "
	echo "Also is provided the following open-source database management systems:"
	echo "- MySQL "
	echo "- PostgreSQL"
	echo "- SQLite3"
	echo "- MongoDB"
	echo "- Redis"
	echo " "
	read -p "Press enter to continue..."
	echo "This script will install OPEW in this system ("`hostname`")" 
	echo "This installer will check and prepare the system properly before install"
	echo " "
	echo "* You can review the code behind this script installer simply typing: "
	echo '$ vi '$0' | head -n 746'
	echo "Or via web from the public Git repository: "
	echo "https://raw.github.com/h2non/OPEW/master/extra/scripts/installer.sh "
	echo " "
	echo "* Also, if you experiment any issue during the installation, please report it here:"
	echo "http://github.com/h2non/opew/issues"
	echo " "
	echo "This installer will generate the following both log files: "
	echo "$LOG > Some output commands log about the installation process"
	echo "$FILES > Installed files extraction log"
	echo " "
}

function _die(){
	echo "ERROR: $1"
	exit 1
}

function _cexists () {
    type "$1" &> /dev/null ;
}

function _requirements(){
	echo "OPEW minimal requirements:"
	echo " "
	echo "* x64 based (64 bits) compatible processor"
	echo "* Minimum of 256 MB of RAM"
	echo "* Minimum of 512 MB of hard disk free space (so 1GB is recommended)"
	echo "* At once a mininal GNU/Linux (64 bits) based OS"
	echo "* TCP/IP protocol support" 
	echo "* Root access level"
	echo " "
	read -p "Press enter to continue... "
}

function _testenv(){
	echo " "
	echo "Testing system requirements..."
	echo " "

	# test 64 bits support
	if  [ ! $(uname -m | grep '_64') ]; then
		echo "ERROR: "
		echo "OPEW only supports 64 bits compatible operative system."
		echo "Can't continue with the installation process..."
		exit 1
	fi
	echo "OK: 64 bits support"

	# check if run as root
	if [ "`id -u`" -ne 0 ];	then
        	echo "ERROR: "
		echo "You must run the installer like a root user. You can't continue..."
	       	exit 1
	fi
	echo "OK: running as root user"

	# check if /opt dir exists 
	if [ ! -d "/opt" ]; then
		echo "NOTE: seems the /opt directory don't exists..., so, the installer will create the directory /opt"
		`mkdir /opt`
	fi

	# verify bin tools for used by the installer script
	for i in $(echo "awk;head;tail;wc;tar;df" | tr ";" "\n")
	do
		if ! _cexists $i ; then
			echo " "
			echo "ERROR:"
			echo "The binary tool '$i' not found in the system (using PATH env variable)"
			echo "Install '$i' via your package manager and try again with the installation"
			echo " "
			ERROR=1
		fi
	done
	if [ $ERROR -ne 1 ]; then
		echo "OK: binary tools found"
	else 
		_die "Cannot continue with the installation process..."
	fi
	ERROR=0

	# check system RAM capacity
	if _cexists free ; then
	if [ $(free -t -m | grep 'Mem:' | awk '{ print $2 }') -le 255 ]; then
		echo " "
		echo "ALERT:"
		echo "Seems you have less than 256MB of RAM in this system." 
		echo "OPEW needs at once 256 MB of RAM capacity to work properly, so 512MB is recomended."
		echo "You can continue with the installation process, but take that into account."
		echo " "
		read -p "Press enter to continue... "
	else
		echo "OK: this system have more than 256MB of RAM capatity"
	fi
	fi

	# check /opt has in an indepent partition
	DISK=`df -P --sync | grep '/opt$' | awk '{print $6}'`
	if [ -z $DISK ]; then
		echo "OK: the /opt folder hasn't been detected as an independent partition."
		PARTITION=0
	else
		echo "OK: the /opt folder has been detected as an independent disk partition."
		PARTITION=1
	fi

	# check if exists a symbolic link
	if [ -h "/opt/opew" ]; then
        	echo " "
	        echo "NOTICE: "
                echo "Seems already exists another OPEW installation with a custom path: "
                echo `ls -ali /opt/ | grep "opew ->"`
		echo " "
                echo "Take into account the new installation will turn inoperative the old OPEW installation."
                echo "You should stop all of the services running at the old OPEW stack before continue with the new installation. "
                echo " "
                read -p "Do you want automatically stop all the services running at the OPEW old installation: (y/n) " response
                if [ $response = "y" ] || [ $response = "Y" ]; then
                        if [ ! -x "/opt/opew/scripts/opew" ]; then
                                _die "Can't ejecute the OPEW script to stop the services. Can't continue... "
                        fi
                        echo "Stoping old OPEW installation services..."
                        /opt/opew/scripts/opew stop >> "$LOG"
                fi

                echo " "
                read -p "Do you want automatically remove the symbolic link to the old OPEW installation? (just the symbolic link): (y/n) " response
                if [ $response = "y" ] && [ $response = "Y"]; then
                        if test `rm -f "/opt/opew"` -eq 1 ; then
                                _die "Cannot remove the symbolic link to the old OPEW installation path. Can't continue... "
                        else
                                echo "Symbolic link removed successfully. Can continue the installation..."
                        fi
                else
                        echo "Remove manually the symbolic link at '/opt/opew' path and try again to install OPEW"
                        exit
                fi
                OLD=1

	# check if opew native path is valid
	elif [ -d "/opt/opew" ] && [ -d "/opt/opew/stack" ]; then
		echo " "
		echo "NOTICE: "
		echo "Detected another OPEW installation located in '/opt/opew' "
		echo "The new OPEW installation needs '/opt/opew' path free to work "
		echo "You should move the old OPEW stack to other location to continue with the new installation"
		echo " "
		read -p "Do you want to stop all the services running at the OPEW old installation?: (y/n) " response
		if [ $response = "y" ] || [ $response = "Y" ]; then
			if [ ! -x "/opt/opew/scripts/opew" ]; then
				_die "Can't ejecute the OPEW script to stop the services. Can't continue... "
			fi
			echo "Stoping old OPEW installation services..."
			/opt/opew/scripts/opew stop >> "$LOG"
			STOPED=1
		fi

		echo " "
		read -p "Do you want move the old OPEW to new location (p.e '/opt/opew_old'): (y/n) " response
		if [ $response = "y" ] || [ $response = "Y"]; then
			while : ; do
                        read -p "Please, enter the new location to move the old OPEW installation: " response
	                if [ -z $respone ] && [ -d $response ]; then
                                echo "Invalid path or the directory already exists. Enter a new valid path... (CTRL+C to exit): "
                                echo " "
                        else
        			if [ ! `mv /opt/opew $respone` ]; then
				_die "Cannot move the old OPEW installation to link to the old OPEW installation path. Can't continue... "
	                	else
					echo "Symbolic link removed successfully. Can continue the installation process..."
				fi
				break
                        fi
              		done
		else
			_die "Can't continue. Move or delete the old OPEW installation from '/opt/opew' to continue... "
		fi
	elif [ -f "/opt/opew" ]; then 
		echo " "
		echo "NOTICE:"
		echo "Seems already file exists in /opt/opew. OPEW needs this path to work properly "
		read -p "The file will should be deleted or moved. Do you want to deleted the file automatically: (y/n)" response
		if [ $response = "y" ] || [ $response = "Y"]; then
                        if [ ! `rm -f /opt/opew` ]; then
                        	_die "ERROR: can't delete the file '/opt/opew'. Delete or move it manually before continue and try again the installation... "
			else 
				echo "OK: '/opt/opew' file removed succesfully. Continuing the installation process... "
                        fi 
                else
                        _die "Can't continue. Move or delete '/opt/opew' manually before continue and try again the installation... "
                fi
	else
		echo "OK: don't found confluency with old OPEW installations"
		echo "OK: the installation path is available to be used by default"
	fi

	echo " "
	echo "All requirements passed succesully "
	echo " "
	read -p "Press enter to continue... "
}

#
# Check free available space partition 
# @param {string} Path to check free space 
# @return {integer} Partition freespace in MegaBytes @todo
# @todo Improve validating partition of alternative manual path
#
function _checkspace(){
	# force to / if not path defined
	if [ $# -eq 0 ]; then 
		$1="/"
	fi

	_PATH=""
	_FOUND=0

	# check complete path
	_CHECK=$(df -P | grep "$1"'$' | awk '{print $6}')
	if [ ! -z $_CHECK ]; then
		echo "The partition exists > $1"
		_PATH="$1"
	else
	# explore the path by directory
	for val in $(echo "$1" | tr "/" "\n"); do
		_PATH="$_PATH/$val"
		# check if exists partition
		_CHECK=$(df -P | grep "$_PATH"'$' | awk '{print $6}')
		if [ ! -z $_CHECK ]; then
			echo "FOUND PARTITION $_PATH"
			_FOUND=1
			break
		fi
	done
	fi

	# if not found as indepent partition
	if [ $_FOUND -eq 0 ]; then
		_PATH="/"
	fi

	SPACE=$(df -P | grep "$_PATH"'$' | awk '{print $4}')
	PERCEN=$(df -P | grep "$_PATH"'$' | awk '{print $5}')
	DISK=$(df -P | grep "$_PATH"'$' | awk '{print $1}')
	TOTAL=$(df -P | grep "$_PATH"'$' | awk '{print $3}')
	
	echo " " 
	echo "Checking available disk space: "
	echo "You have "$((${SPACE} / 1024))" MB ($PERCEN free) from total "$((${TOTAL} / 1024))" MB available space at the OPEW target installation partition ($DISK)."
	echo " "
	# check is lower than 786MB
	if [ $SPACE -lt 524288 ]; then
	        echo "ERROR:"
		echo "OPEW needs at once 512MB of free space available."
		echo "You only have "$((${SPACE} / 1024))" MB of free available space at the target installation partition." 
		_die "Cannot continue with the installation process..."
        else 
		echo "OK:"
		echo "You have more than 512MB of free space available."
		echo "After the OPEW installation you will have approximately about "$(((${SPACE}/1024)-512))" MB of free space available at $DISK partition."
	fi
	echo " "
}

function _preinstall(){
	echo " "
	echo "##############################################"
	echo "Installation step - 1. Installation path "
	echo " "
	echo "OPEW will be installed by default in  '/opt/opew'"
	echo "NOTE: be sure you have more than 512MB of free available space at the OPEW installation location partition, however, the installer checks it and notifies you if something went wrong."
	echo " "
	read -p "If you want to install OPEW in a diferent path (not in '/opt/opew'), enter 'y' (y/N): " response
	case $response in
		y|Y|yes|Yes|YES)
		while : ; do
			read -p "Please, enter the absolute path (/home or /usr): " newpath
			if [ -z "$newpath/opew" ] && [ -d "$newpath/opew" ]; then
				echo "Invalid path o the directory already exists. Enter a new path... (CTRL+C to exit from the installer)"
                               	echo " "
			else 
				OPEW=$newpath"/"
				# check free avaiable space
				_checkspace $PARTITION

				break
			fi 
		done 
		;;
	 	*)
		echo " "
		echo "OK: OPEW will be installed in the default path: '/opt/opew'"
		echo " "
		;;
	esac
	read -p "Press enter to continue..." 
	sleep 1
}

function _usersinstall(){
	echo " "
	echo "##############################################"
	echo "Installation step - 3. OPEW users and groups"
	echo " "
	echo "OPEW include servers like Apache HTTP Server, MySQL and PostgreSQL that by technical requirements and security stuffs need its respective user and group with custom OS privileges."
	echo "In order to work properly with these packages, OPEW installer will create the following users and groups at this system:"
	echo " "
	echo "opew (general purpose OPEW user and group)"
	echo "opew_postgres (PostgreSQL DBMS user and group) "
	echo "opew_mysql (MySQL DBMS user and group)"
	echo "opew_httpd (Apache HTTP server user and group)"
	echo " "

	echo "Installing users:"
	# installing groups
	for i in $(echo "opew;opew-httpd;opew-mysql;opew-postgres" | tr ";" "\n")
	do
		# check group exists
                grep -i "^$i" /etc/group >> $LOG
                if [ $? -eq 0 ]; then
                echo "NOTE: The group '$i' already exists."
                else
                echo "OK: The group '$i' is available."
		echo -n "Creating $i system group... "
			groupadd $i >> $LOG
			if [ $? -eq 0 ]; then
			 	sleep 0.5
			 	echo "created!"
			else
			 	sleep 0.5
				echo "cannot create the group. See $LOG file."
				echo "ERROR: cannot create the system group $i -> $0" >> $LOG
			fi 
			fi

		sleep 1

		# check if user exists
		grep -i "^$i" /etc/passwd >> $LOG
		if [ $? -eq 0 ]; then
		echo "NOTE: The user '$i' already exists."
		else
		echo "OK: The user '$i' is available."
		echo -n "Creating $i system user... "

		# postgresql user 
		if [ $i == 'opew-postgres' ]; then
		useradd "$i" -d /opt/opew/stack/postgresql -g "$i" -s /bin/sh -M >> $LOG
                sleep 0.5
                if [ $? -eq 0 ]; then
                        echo "created!"
			passwd -l opew-postgres >> $LOG # lock login access
                        users[((c++))]=$i
                else
                        echo "cannot create the user. An error ocurred."
                        _die "Can't continue with the installation. See $LOG file and try again."
                fi
		else
		# in other cases
		#read -p "You can define a user password for security reasons. You want to do it? (y/n): " response
		useradd "$i" -d /opt/opew/stack -g "$i" -s /bin/false -M >> $LOG 
		sleep 0.5
		if [ $? -eq 0 ]; then
			echo "created!"
			users[((c++))]=$i
		else
			echo "cannot create the user. An error ocurred."
			_die "Can't continue with the installation. See $LOG file and try again."
		fi
		fi

		fi
		echo " "
	done

	read -p "Process completed. Press enter for continue... "

	echo " "

	if [ ! -z $users ]; then

	echo "Detailed information about the users and groups created:"
	for i in "${users[@]}"; do
                c=0
                for x in $(grep "${i}:" /etc/passwd | tr ":" "\n"); do
                        ((c++))
                        case $c in
                        1)
                        echo "Username: $x"
                        ;;
			2)
			echo "Group: $i"
			;;
                        3)
                        echo "UID: $x"
                        ;;
			4)
			echo "GID: $x"
			;;
			5)
			echo "Home directory: $x"
			;;
			6)
			echo "Shell: $x"
			;;
                        esac
                done
        echo " "
        done
	read -p "Press enter to continue... "
	fi 
}

function _license(){
	echo " "
	echo "##############################################"
	echo "Installation step - 2. License agreement"
	echo " "
	echo "OPEW include a lot of diferent packages and programming languages with his respective license."
	echo "You can see the all packages licenses at $OPEW/licenses/ once OPEW will be installed. "
	echo "OPEW project and his native code included of the authors or contributors is licensed under the GNU GPL 3.0 public license (if not see the code header). "
	echo "You can read it at $OPEW/licenses"
	echo " "
	read  -p "You accept the respetive packages licenses and the OPEW license?: (y/n) " response
	 case $response in
                y|Y|yes|Yes|YES)
                	echo "OK: continuning with the next installation step..."
			echo " "
                ;;
                *)
                echo " "
                echo "You must accept the terms. Can't continue. "
                echo " "
		exit 1
                ;;
        esac
	echo " "
	# TODO
}

function _doinstall(){
	echo " "
	echo "##############################################"
	echo "Installation step - 4. Install data." 
	echo " " 
	echo "OPEW is ready to be installed."
	echo " " 
	read -p "Do you want to proceed to install OPEW at this system? (y/n): " response
	case $response in
                y|Y|yes|Yes|YES)
		        echo "OK: loading data..."
			sleep 1
                ;;
                *)
                echo " "
                echo "You select NO. Exiting from the installer. "
                echo " "
                exit 0 
                ;;
        esac
	echo " "
	echo "Installing OPEW (this process may take some minutes depeding of the hardware resources)"
	echo " "

	# get final line with regex
	skip=`awk '/^###DATA###/ {print NR + 1; exit 0; }' $0`
	if [ ! -d $OPEW ]; then
	mkdir $OPEW
	fi
	# tail from final and start uncompress
	tail -n +$skip $0 | tar xvz -C $OPEW >> $FILES &

	# process percentage info
	perbar="#"
	nlines=`wc -l $FILES | awk '{ print $1; }'`
	pernumlast=-1

	while : ; do
		pernum=`awk 'BEGIN { rounded = sprintf("%.0f", '$((${nlines}*50/${LINES}))'); print rounded }'`
		count=0

		while [ $count -lt $pernum ]; do
			count=`expr $count + 1`
			perbar="$perbar#"
		done

		if [ $pernum -ne $pernumlast ]; then
			echo -n "$perbar ($((${pernum}*2+1))%)" 
			echo -n R | tr 'R' '\r'
		fi

		sleep 2
		perbar=""
		pernumlast=$pernum
		nlines=`wc -l $FILES | awk '{ print $1; }'`
		if [ $nlines -ge $LINES ]; then
                        break
                fi
	done

	sleep 1
	echo " "
	echo "OPEW was installed succesfully!"
}

function _postinstall(){
	echo " "
	echo "############################################"
	echo "Installation step - 4. Post-install process."
	echo " "
	sleep 2
	# make symbolic link
	if [ $OPEW != '/opt/' ]; then
		echo -n "Post-install process: "
       		sleep 1
		ln -s $OPEW"/opew" /opt/opew
		echo "done!"
		echo " "
	fi
	echo "Assingning permissions:"
	# global permissions
	# TODO
	# opew
	chown -R root:root /opt/opew/scripts >> $LOG
	chmod -R +x /opt/opew/scripts/ >> $LOG
	if [ $? -eq 0 ]; then
	echo "Assiged execution permissions..."
	else
	echo "Error assigning OPEW user permissions"
	echo "Run manually 'chown -R root:root /opt/opew/scripts'"
	echo " "
	sleep 2
	fi
	sleep 0.5
	# apache 
	chown -R opew-httpd:opew-httpd /opt/opew/stack/apache2/htdocs >> $LOG
	chown -R opew-httpd:opew-httpd /opt/opew/stack/apache2/logs/fastcgi >> $LOG
	if [ $? -eq 0 ]; then
	echo "Assigned permisssion to opew-httpd user and group..."
	else
        echo "Error assigning opew-httpd user permissions"
        echo "Run manually 'chown -R opew-httpd:opew-httpd /opt/opew/stack/apache2/logs/fastcgi'"
        echo " "
        sleep 2
        fi
	sleep 0.5
	# mysql
	chown -R opew-mysql:opew-mysql /opt/opew/stack/mysql/data >> $LOG
	chown -R opew-mysql:opew-mysql /opt/opew/stack/mysql/tmp >> $LOG
	if [ $? -eq 0 ]; then
	echo "Assigned permissions to opew-mysql user and group..."
	else
        echo "Error assigning MysQL permissions to /opt/opew/stack/mysql/data"
        echo "Run manually 'chown -R opew-mysql:opew-mysql /opt/opew/stack/mysql/data'"
	echo "And 'chown -R opew-mysql:opew-mysql /opt/opew/stack/mysql/tmp'"
        echo " "
        sleep 2
        fi
	sleep 0.5
	# postgresql
	chown -R opew-postgres:opew-postgres /opt/opew/stack/postgresql/data >> $LOG
	chown opew-postgres:opew-postgres /opt/opew/stack/postgresql/ >> $LOG
	if [ $? -eq 0 ]; then
	echo "Assigned permissions to opew-postgres user and group..."
	else
        echo "Error assigning PostgreSQL permissions"
        echo "Run manually 'chown -R opew-postgres:opew-postgres /opt/opew/stack/postgres/data'"
	echo "And 'chown opew-postgres:opew-postgres /opt/opew/stack/postgresql/'"
        echo " "
        sleep 2
        fi
	sleep 1

	echo " "
	echo "Take a look the README file located in $OPEW for getting started."
        echo "The complete OPEW documentation is online available at:"
        echo "<http://opew.sourceforge.net/docs>"
        echo " "

	read -p "Do you want to start the Apache HTTP server? (y/n): " response
	case $response in
                y|Y|yes|Yes|YES)
			# check if port TCP 80 is available
			netstat -ltp --numeric-ports | grep ":80$" >> $LOG
			if [ $? -eq 0 ]; then
			sleep 1
			echo " "
			echo "Seem the port TCP 80 is already used by another server application."
			echo "Stop the service and try again or change the Apache HTTP server default port to another via /opt/opew/stack/apache/conf/httpd.conf"
			echo "After that, run manually: "
			echo "/opt/opew/scripts/opew start apache"
			echo " "
			else
			/opt/opew/scripts/opew start apache >> $LOG
			sleep 1
			echo " "
			echo "The HTTP server was started successfully! Try it with your web browser typing http://localhost or http://your-ip"
			#echo "Also, you can see the documentation typing http://localhost/docs"
			fi
                ;;
                *)
		echo " "
		;;
	esac
		echo " "
		echo "You can start the OPEW services through the following script:"
		echo "/opt/opew/scripts/opew (start|stop|restart|status) <service>"
		echo " "
		echo "List of available services: "
		echo " "
		echo "apache - Apache HTTP Server"
		echo "mysql - MySQL Server"
		echo "postgresql - PostgreSQL Server"
		echo "mondodb - MongoDB Server"
		echo "git - Git server daemon"
		echo " "
		echo "Also you get the help message typing:"
		echo "/opt/opew/stack/opew help"
		echo " "
		echo "If you wanna use the OPEW environment variables, simply run:"
		echo "/opt/opew/scripts/env_opew"
		echo " "
		echo "See README at '$OPEW/opew/' for more information and basic usage." 
		echo " "

        echo "Thanks to try to use OPEW. Enjoy it!"

}

# welcome message
_welcome
# show requirements message and other stuff
_requirements
# run a basic test requirements environment to prepare the OPEW installation
_testenv
# run the preinstall process
_preinstall
# show license agregement
_license
# run usersinstall process
_usersinstall
# finally install data
_doinstall
# postinstall process
_postinstall

exit 0

###DATA###
