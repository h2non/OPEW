#!/bin/bash
#
# OPEW installer shell script
# This is a part of OPEW project <http://opew.sourceforge.net>
#
# @license	GNU GPL 3.0
# @author	Tomas Aparicio <tomas@rijndael-project.com>
# @version	1.0 - 04/12/2011
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
LOG="/opt/opew.log"
OPEW="/opt/opew"

function _welcome(){
	clear
	echo "########################################"
	echo "             WELCOME TO OPEW "
	echo "########################################"
	echo " "
	echo "This script will be install OPEW on this machine"
	echo "You can take a look at the code behing at: "
	echo "http://github.com/h2non/opew/installer.sh "
	echo " "
	echo "OPEW is a complete, independent and extensible open distribution stack for GNU/Linux based OS."
	echo "Its goal is to provides an easy and portable ready-to-run development environment focused on modern web programming languages. " 
	echo "You can read more from project page: http://opew.sourceforge.net"
	echo " "
	echo " "
}

function _die(){
	echo "ERROR: $1"
	exit 1
}

function _requeriments(){
	echo " ENVIRONMENT REQUERIMENTS:"
	echo " "
	echo "* x64 based (64 bits) compatible processor"
	echo "* Minimum of 256 MB of RAM"
	echo "* Minimum of 1024 MB of hard disk capacity"
	echo "* At once a mininal GNU/Linux based OS"
	echo "* TCP/IP protocol support" 
	echo "* Root access level"
	echo " "
	echo " "
	read -p "Press any key to continue... "
}

function _testenv(){
	echo " "
	echo "#######################################"
	echo "Testing environment requeriments..."
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

	# check if opew native path is valid
	if [ -d "/opt/opew" ] && [ -d "/opt/opew/stack" ] ; then
		echo "NOTE: "
		echo "Detected another OPEW installation located in '/opt/opew' "
		echo "The new OPEW installation needs '/opt/opew' path free to work "
		echo "You should move the old OPEW stack to other location to continue with the new installation"
		echo " "
		read -p "Do you want to stop all the services running at the OPEW old installation?: (y/n)" response
		if [ $response = "y" ] || [ $response = "Y" ]; then
			if [ ! -x "/opt/opew/scripts/opew" ]; then
				_die "Can't ejecute the OPEW script to stop the services. Can't continue... "
			fi
			echo "Stoping old OPEW installation services..."
			/opt/opew/scripts/opew stop >> "$0.debug.log"
			STOPED=1
		fi
		
		echo " "
		read -p "You wanna move the old OPEW to new location (p.e '/opt/opew_old'): (y/n) " response
		if [ $response = "y" ] && [ $response = "Y"]; then
			if [ test ! `rm /opt/opew` ]; then
				_die "Cannot remove the symbolic link to the old OPEW installation path. Can't continue... "
			else 
				echo "Symbolic link removed successfully. Can continue the installation process..."
			fi
		else
			echo " "
		fi
	else
		echo "OK: the installation path is available to be used by default"
	fi
	 
	# check if symbolic link already exists
	if [ -h "/opt/opew" ]; then
		echo "NOTE: "
		echo "Seems already exists another OPEW installation with a custom path: " 
		echo `ls -ali /opt/ | grep "opew ->"`
		echo "Take into account the new installation will make non-operative the old OPEW installation."
		echo "Is recomendable to stop all the services running at the old OPEW stack before continue with the new installation. "
		echo " "
                read -p "Do you want to stop all the services running at the OPEW old installation: (y/n)" response
                if [ $response = "y" ] || [ $response = "Y" ]; then
                        if [ ! -x "/opt/opew/scripts/opew" ]; then
                                _die "Can't ejecute the OPEW script to stop the services. Can't continue... "
                        fi
                        echo "Stoping old OPEW installation services..."
                        /opt/opew/scripts/opew stop >> "$PWD/opew-install-debug.log"
                fi

		echo " "
                read -p "Do you wanna remove the symbolic link to the old OPEW installation (just the symbolic link)?: (y/n) " response
                if [ $response = "y" ] && [ $response = "Y"]; then
                        if [ test ! `rm /opt/opew` ]; then
                                _die "Cannot remove the symbolic link to the old OPEW installation path. Can't continue... "
                        else
                                echo "Symbolic link removed successfully. Can continue the installation..."
                        fi
                fi
		OLD=1
	fi
	echo " "
	echo "All test passed succesully "
	echo "########################################"
	echo " "
	read -p "Press any key to continue... "
}

function _preinstall(){
	echo " "
	echo "#######################################"
	echo "Pre-installation steps - 1. Installation path "
	echo " "
	echo "OPEW will be installed by default in '/opt/opew'"
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
	
		;;
	esac
}


function _usersinstall(){
	echo " "
	# TODO
}

function _license(){
	echo "######################################"
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
