#!/bin/bash
#
# OPEW auto-installer bash script
# This is a part of the OPEW project <http://opew.sourceforge.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	1.2 beta - 20/12/2011
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
# THIS CODE IS NOT ENDED AND STILL BETA
#

# config variables
LOG="$PWD/opew-install.log"
FILES="$PWD/opew-files.log"
OPEW="/opt/-opewtest"
LINES=72810
ERROR=0

# check PATH environment variable
if [ -z $PATH ]; then
	echo "The PATH environment variable is empty. Cannot continue with the installation process..."
	echo "Must be define it. Please, ejecute this: " 
	echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
	exit 1
fi

function _debuglog(){
	if [ -s $LOG; then
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
	echo "##############################################"
	echo "     OPEW - Open Web Development Stack " 
	echo "##############################################"
	echo " "
	echo "OPEW is a complete, independent and extensible open distribution stack for GNU/Linux based OS."
        echo "Its goal is to provides an easy and portable ready-to-run development environment focused on modern web programming languages. "
        echo "You can read more at the project page: http://opew.sourceforge.net"
	echo " "
	echo "This script (1.0 beta) will install OPEW in this system ("`hostname`")" 
	echo "This installer will check and prepare the system properly before install"
	echo " "
	echo "* You can take a look at the script code behind this installer typing on the shell: "
	echo "$ vi $0 | head -n 395"
	echo "Or via web from the public Git repository: "
	echo "https://github.com/h2non/OPEW/blob/master/bash/installer.sh "
	echo " "
	echo "* Also, if you experiment any issue during the execution, please report it here:"
	echo "http://github.com/h2non/opew/issues"
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
	echo "* Minimum of 768 MB of hard disk free space (so 1GB is recommended)"
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
		echo "The installer must be ran like root user. Can't continue..."
        	exit 1
	fi
	echo "OK: running as root"

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
	DISK=`df -P --sync | grep '/opt'`
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
# Check free available space 
# @param {integer} 1 for check '/opt' or 0 for '/' partition 
# @return {none}
#
function _checkspace(){
	# force to 0 if not isset
	if [ $# -eq 0 ]; then 
		1=0 
	fi
	if [ $1 -eq 0 ]; then
		SPACE=$(df -P | grep '/$' | awk '{print $4}')
                PERCEN=$(df -P | grep '/$' | awk '{print $5}')
		DISK=$(df -P | grep '/$' | awk '{print $1}')
		TOTAL=$(df -P | grep '/$' | awk '{print $3}')
	else
		TOTAL=$(df -P | grep '/opt$' | awk '{print $3}')
		SPACE=$(df -P | grep '/opt$' | awk '{print $4}')
                PERCEN=$(df -P | grep '/opt$' | awk '{print $5}')
		DISK=$(df -P | grep '/opt$' | awk '{print $1}')
	fi

	echo " " 
	echo "Checking available disk space: "
	echo "You have "$(($SPACE / 1024))" MB ($PERCEN free) from total "$(($TOTAL / 1024))" MB available space at the OPEW target installation partition ($DISK)."
	echo " "
	# check is lower than 786MB
	if [ $SPACE -lt 798720 ]; then
	        echo "ERROR:"
		echo "OPEW needs at once 786MB of free space available."
		echo "You only have "$(($SPACE / 1024))" MB of free available space at the target installation partition." 
		_die "Cannot continue with the installation process..."
        else 
		echo "OK:"
		echo "You have more than 786MB of free space available."
		echo "After the OPEW installation you will have approximately about "$((($SPACE/1024)-786))" MB of free space available at $DISK partition."
	fi
	echo " "
}

function _preinstall(){
	echo " "
	echo "##############################################"
	echo "Installation steps - 1. Installation path "
	echo " "
	echo "OPEW will be installed by default in '/opt/opew'"
	echo "NOTE: if install in /opt/opew, be sure have more than 1024MB of free space at /opt (maybe are inside in a separete disk partition)"
	echo " "
	read -p "You wanna define an alternative installation path? (y/n): " response
	case $response in
		y|Y|yes|Yes|YES)
		while : ; do
			read -p "Please, enter the absolute new path: " newpath
			if [ -z $newpath ] && [ -d $newpath ]; then
				echo "Invalid path o the directory already exists. Enter a new path... (CTRL+C to exit)"
                               	echo " "
			else 
			
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
}

function _usersinstall(){
	echo " "
	echo "##############################################"
	echo "Installation step - 3. System users and groups"
	echo " "
	echo "OPEW includes packages like Apache HTTP Server, MySQL and PostgreSQL DBMS thats by technical requirements and security recomendations needs to works with custom OS users with his own privileges."
	echo "In order to work properly with these packages, OPEW installer will create the following users and groups at this system:"
	echo " "
	echo "opew (general purpose OPEW user and group name)"
	echo "opew_postgres (PostgreSQL DBMS user and group) "
	echo "opew_mysql (MySQL DBMS user and group)"
	echo "opew_httpd (Apache HTTP server user and group)"
	echo " "

	echo "Installing users:"
	# installing groups
	for i in $(echo "opew;opew-httpd;opew-mysql;opew-postgres" | tr ";" "\n")
	do
		# check if user exists
		grep -i "^$i" /etc/passwd >> $LOG
		if [ $? -eq 0 ]; then
        	echo "NOTE: The user '$i' already exists."
		else
        	echo "OK: The user '$i' don't exists."
		fi
		# check group exists
		grep -i "^$i" /etc/group >> $LOG
		if [ $? -eq 0 ]; then
                echo "NOTE: The group '$i' already exists."
                else
                echo "OK: The group '$i' don't exists. "
                fi
	done

	# TODO
}

function _license(){
	echo " "
	echo "##############################################"
	echo "Installation step - 2. License agreement"
	echo " "
	echo "OPEW include a lot of diferent packages and programming languages with his respective license."
	echo "You can see the all packages licenses at /opt/opew/licenses/ once OPEW will be installed. "
	echo "OPEW project and his native code included of the authors or contributors is licensed under the GNU GPL 3.0 public license (if not see the code header). You can read it at /opt/opew/LICENSE"
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
	echo "Installation step - 4. Install files." 
	echo " " 
	echo "OPEW is ready to be installed."
	echo " " 
	read -p "Do you want to proceed finally installing OPEW in this system? (y/n): " response
	case $response in
                y|Y|yes|Yes|YES)
		        echo "OK: continuning with the next installation step..."
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

	echo "Assingning permissions:"
	# opew
	chown -R opew /opt/opew/stack/
	# apache 

	# mysql
	
	# postgresql

	echo " "
	echo "Take a look the README file located in $OPEW for getting started."
        echo "The complete OPEW documentation is online available at:"
        echo "http://opew.sourceforge.net/docs"
        echo " "
	
	read -p "Do you want to start the Apache HTTP server? (y/n): " response
	case $response in
                y|Y|yes|Yes|YES)
			 /opt/opew/scripts/services start apache
                ;;
                *)
		echo "You can start the OPEW services running the 'services' script."
		echo "./opt/opew/scripts/services start <service>"
		echo " "
		echo "List of services: "
		echo "apache - Apache HTTP Server"
		echo "mysql - MySQL Server"
		echo "postgresql - PostgreSQL Server"
		echo "mondodb - MongoDB Server"
		echo " "
		echo "See README at '/opt/opew/' for more information an basic usage." 
                ;;
        esac

        echo "Enjoy it!"
	# TODO...
}

# run welcome function
_welcome
# show requirements message and other stuff
#_requirements
# run a basic test requirements environment to prepare the new OPEW installation
#_testenv
# run the preinstall process
#_preinstall
# show license agregement
#_license
# run usersinstall process
_usersinstall
# finally install
_doinstall
# TODO
_postinstall

exit 0

###DATA###
