#!/bin/bash
#
# OPEW installer shell script
# This is a part of OPEW project <http://opew.sourceforge.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	1.0 - 06/12/2011
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
OPEW="/opt/opew"

# check PATH environment variable
if [ -z $PATH ]; then
	echo "The PATH environment variable is empty. Cannot continue with the installation process..."
	echo "Should define it correctly. Please, ejecute this: " 
	echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
	exit 1
fi


function _debuglog(){
	if [ -s $LOG; then
		rm -f $LOG
		touch $LOG
	fi
}

function _welcome(){
	clear
	echo "#############################################"
	echo "     OPEW - Open Web Development Stack " 
	echo "#############################################"
	echo " "
	echo "This script will install OPEW in this system ("`hostname`")" 
	echo "This installer will check and prepare the system properly"
	echo " "
	echo "You can take a look at the shell script code of this installer at: "
	echo "http://github.com/h2non/opew/installer.sh "
	echo " "
	echo "OPEW is a complete, independent and extensible open distribution stack for GNU/Linux based OS."
	echo "Its goal is to provides an easy and portable ready-to-run development environment focused on modern web programming languages. " 
	echo "You can read more at the project page: http://opew.sourceforge.net"
	echo " "
}

function _die(){
	echo "ERROR: $1"
	exit 1
}

function _cexists () {
    type "$1" &> /dev/null ;
}

function _requeriments(){
	echo "OPEW minimal requeriments:"
	echo " "
	echo "* x64 based (64 bits) compatible processor"
	echo "* Minimum of 256 MB of RAM"
	echo "* Minimum of 1024 MB of hard disk available space"
	echo "* At once a mininal GNU/Linux (64 bits) based OS"
	echo "* TCP/IP protocol support" 
	echo "* Root access level"
	echo " "
	read -p "Press any key to continue... "
}

function _testenv(){
	echo " "
	echo "############################################"
	echo "Testing requeriments..."
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
	if test "`id -u`" -ne 0
	then
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

	# 

	# check system RAM capacity
	# hash foo 2>&- || { echo >&2 'not exists'; exit 1; }
	if _cexists free && _cexists awk ; then
	if [ $(free -t -m | grep 'Mem:' | awk '{ print $2 }') -le 255 ]; then
		echo " "
		echo "ALERT:"
		echo "Seems you have less than 256MB of RAM in this system." 
		echo "OPEW needs at once 256 MB of RAM capacity to work properly, so 512MB is recomended."
		echo "You can continue with the installation process, but take that into account."
		echo " "
		read -p "Press any key to continue... "
	else
		echo "OK: this system have more than 256MB of RAM capatity"
	fi
	fi

	# check if exists a symbolic link
	if [ -h "/opt/opew" ]; then
        	echo " "
	        echo "NOTICE: "
                echo "Seems already exists another OPEW installation with a custom path: "
                echo `ls -ali /opt/ | grep "opew ->"`
		echo " "
                echo "Take into account the new installation will make inoperative the old OPEW installation."
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

	echo " "
	echo "All test passed succesully "
	echo " "
	echo "###########################################"
	echo " "
	read -p "Press any key to continue... "
}

function _preinstall(){
	echo " "
	echo "##########################################"
	echo "Installation steps - 1. Installation path "
	echo " "
	echo "OPEW will be installed by default in '/opt/opew'"
	echo "NOTE: if install in /opt/opew, be sure have more than 1024MB of free space at /opt (maybe are inside in a separete disk partition)"
	read -p "You wanna define an alternative installation path: (y/n) " response
	case $response in
		y|Y)
		while : ; do
			read -p "Please, enter the absolute new path: " newpath
			if [ -z $newpath ] && [ -d $newpath ]; then
				echo "Invalid path o the directory already exists. Enter a new path... (CTRL+C to exit)"
                               	echo " "
			else 
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
	echo "##########################################"
}

function _usersinstall(){
	echo "Installation step - 2. Creating system users and groups"
	echo " "
	echo "OPEW includes packages like Apache HTTP Server, MySQL and PostgreSQL DBMS thats by technical requeriments and security recomendations"
	echo "needs to works with custom OS users with his own privileges."
	echo "Is order to work properly with these packages, OPEW installer will create the following users and groups at this system:"
	echo " "
	echo "opew (general purpose OPEW user and group name)"
	echo "opew_postgres (PostgreSQL DBMS user and group) "
	echo "opew_mysql (MySQL DBMS user and group)"
	echo "opew_httpd (Apache HTTP server user and group)"
	echo " "

	echo "##########################################"
	# TODO
}

function _license(){
	echo "#########################################"
	echo " "
	echo "OPEW is licensed under the GNU GPL 3.0 public license: "
	echo " "
	# TODO
}

# run welcome function
_welcome
# show requeriments message and other stuff
_requeriments
# run a basic test requeriments environment to prepare the new OPEW installation
_testenv
# run the preinstall process
_preinstall
# run usersinstall process
_usersinstall
# show license agregement
_license
# finally install
_doinstall
# TODO
